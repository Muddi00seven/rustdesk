import importlib.util
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("ci_adjustments", Path(__file__).with_name("ci_adjustments.py"))
ci = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ci)


class CIAdjustmentsTests(unittest.TestCase):
    def test_native_manifests_use_distinct_installations_and_rust_roots(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            pins = dict(line.split("=", 1) for line in Path(__file__).with_name("toolchain.env").read_text().splitlines() if line and not line.startswith("#"))
            tool = root / "toolchains" / f"vcpkg-{pins['MACPILOT_VCPKG_SHA']}" / "vcpkg"
            tool.parent.mkdir(parents=True)
            tool.write_text('#!/bin/bash\nprintf "%s\\n" "$@"\n')
            tool.chmod(0o755)
            common = Path(__file__).with_name("common.sh")
            for name, triplet in [("macos", "arm64-osx"), ("ios", "arm64-ios")]:
                result = subprocess.run(["/bin/bash", "-c", 'source "$1"; install_native_dependencies "$2" "$3"; printf "ROOT=%s\\n" "$VCPKG_ROOT"', "test", str(common), name, triplet], env={**os.environ, "MACPILOT_CACHE_ROOT": directory}, capture_output=True, text=True, check=True)
                self.assertIn(f"--x-install-root={root}/native/{name}/installed", result.stdout)
                self.assertIn(f"ROOT={root}/native/{name}", result.stdout)

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
