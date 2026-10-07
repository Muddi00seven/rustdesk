#!/usr/bin/env python3
"""Apply only upstream's documented CI substitutions to a build checkout."""
import argparse
import re
from pathlib import Path


def replace(path: Path, pattern: str, replacement: str) -> None:
    original = path.read_text()
    changed, count = re.subn(pattern, replacement, original)
    if not count:
        raise ValueError(f"Expected upstream CI pattern missing in {path.name}")
    if original != changed:
        path.write_text(changed)


def adjust(root: Path, mode: str) -> None:
    if mode == "bridge":
        replace(root / "flutter/pubspec.yaml", r"extended_text: (?:14|13)\.0\.0", "extended_text: 13.0.0")
    elif mode == "macos-arm64":
        replace(root / "build.py", r"MACOSX_DEPLOYMENT_TARGET=[0-9]+\.[0-9]+", "MACOSX_DEPLOYMENT_TARGET=12.3")
        replace(root / "flutter/macos/Podfile", r"platform :osx, '[0-9]+\.[0-9]+'", "platform :osx, '12.3'")
        replace(root / "Cargo.toml", r'osx_minimum_system_version = "[0-9]+\.[0-9]+"', 'osx_minimum_system_version = "12.3"')
        replace(root / "flutter/macos/Runner.xcodeproj/project.pbxproj", r"MACOSX_DEPLOYMENT_TARGET = [0-9]+\.[0-9]+;", "MACOSX_DEPLOYMENT_TARGET = 12.3;")
    elif mode == "scheduler":
        replace(root / "packages/flutter/lib/src/scheduler/binding.dart", r"(?m)^(\s*)_setFramesEnabledState\(false\);", r"\1//_setFramesEnabledState(false);")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["bridge", "macos-arm64", "scheduler"])
    parser.add_argument("root", type=Path)
    args = parser.parse_args()
    try:
        adjust(args.root, args.mode)
    except (ValueError, OSError) as error:
        parser.exit(1, f"MacPilot: {error}\n")
