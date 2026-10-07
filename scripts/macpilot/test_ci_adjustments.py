import importlib.util
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("ci_adjustments", Path(__file__).with_name("ci_adjustments.py"))
ci = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ci)


class CIAdjustmentsTests(unittest.TestCase):
    def test_arm64_checkout_matches_upstream_ci_and_is_repeatable(self):
        files = {
            "build.py": "MACOSX_DEPLOYMENT_TARGET=10.14 cargo build\n",
            "flutter/macos/Podfile": "platform :osx, '10.14'\n",
            "Cargo.toml": 'osx_minimum_system_version = "10.14"\n',
            "flutter/macos/Runner.xcodeproj/project.pbxproj": "MACOSX_DEPLOYMENT_TARGET = 10.14;\n",
        }
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, content in files.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)
            ci.adjust(root, "macos-arm64")
            ci.adjust(root, "macos-arm64")
            for name, content in files.items():
                self.assertEqual((root / name).read_text(), content.replace("10.14", "12.3"))

    def test_bridge_downgrade_and_unknown_upstream_pattern(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "flutter/pubspec.yaml"
            path.parent.mkdir()
            path.write_text("extended_text: 14.0.0\n")
            ci.adjust(root, "bridge")
            self.assertEqual(path.read_text(), "extended_text: 13.0.0\n")
            path.write_text("extended_text: 15.0.0\n")
            with self.assertRaisesRegex(ValueError, "Expected upstream CI pattern missing"):
                ci.adjust(root, "bridge")
            self.assertEqual(path.read_text(), "extended_text: 15.0.0\n")


if __name__ == "__main__":
    unittest.main()
