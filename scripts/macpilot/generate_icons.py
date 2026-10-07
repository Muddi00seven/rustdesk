#!/usr/bin/env python3
"""Render the opaque development icon into Apple's existing icon containers."""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def run(*args: str) -> None:
    subprocess.run(args, check=True, stdout=subprocess.DEVNULL)


def generate() -> None:
    config = json.loads((ROOT / "macpilot/product.json").read_text())
    master = (ROOT / "flutter" / config["APP_ICON"]).resolve()
    if not master.is_relative_to(ROOT / "flutter/assets") or not master.is_file():
        raise ValueError("APP_ICON must reference a local Flutter asset")
    metadata = subprocess.check_output(["sips", "-g", "pixelWidth", "-g", "pixelHeight", "-g", "hasAlpha", str(master)], text=True)
    if "pixelWidth: 1024" not in metadata or "pixelHeight: 1024" not in metadata or "hasAlpha: no" not in metadata:
        raise ValueError("APP_ICON must be an opaque 1024×1024 PNG")
    ios = ROOT / "flutter/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    entries = json.loads((ios / "Contents.json").read_text())["images"]
    resized = set()
    for entry in entries:
        filename = entry["filename"]
        if filename in resized:
            continue
        resized.add(filename)
        points = float(entry["size"].split("x")[0])
        pixels = str(int(points * float(entry["scale"].rstrip("x"))))
        run("sips", "-z", pixels, pixels, str(master), "--out", str(ios / filename))
    launch = ROOT / "flutter/ios/Runner/Assets.xcassets/LaunchImage.imageset"
    for entry in json.loads((launch / "Contents.json").read_text())["images"]:
        pixels = str(128 * int(entry["scale"].rstrip("x")))
        run("sips", "-z", pixels, pixels, str(master), "--out", str(launch / entry["filename"]))
    iconset = ROOT / "target/macpilot-icons/MacPilot.iconset"
    iconset.mkdir(parents=True, exist_ok=True)
    for points in (16, 32, 128, 256, 512):
        for scale in (1, 2):
            pixels = str(points * scale)
            filename = f"icon_{points}x{points}{'@2x' if scale == 2 else ''}.png"
            run("sips", "-z", pixels, pixels, str(master), "--out", str(iconset / filename))
    run("iconutil", "-c", "icns", str(iconset), "-o", str(ROOT / "flutter/macos/Runner/AppIcon.icns"))


if __name__ == "__main__":
    try:
        generate()
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"MacPilot: icon generation failed: {error}")
