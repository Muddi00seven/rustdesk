#!/usr/bin/env python3
"""Check the actual Apple bundle rather than trusting Xcode source settings."""
import argparse
import json
import plistlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("platform", choices=("macos", "ios"))
    parser.add_argument("bundle", type=Path)
    args = parser.parse_args()
    config = json.loads((ROOT / "macpilot/product.json").read_text())
    plist = args.bundle / ("Contents/Info.plist" if args.platform == "macos" else "Info.plist")
    metadata = plistlib.loads(plist.read_bytes())
    expected = {
        "CFBundleName": config["PRODUCT_NAME"],
        "CFBundleDisplayName": config["BUNDLE_DISPLAY_NAME"],
        "CFBundleIdentifier": config[args.platform.upper() + "_BUNDLE_IDENTIFIER"],
    }
    for key, value in expected.items():
        if metadata.get(key) != value:
            raise ValueError(f"{key} differs from canonical product configuration")
    print(f"Verified {args.platform} product bundle identity/display name")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError) as error:
        raise SystemExit(f"MacPilot: bundle branding verification failed: {error}")
