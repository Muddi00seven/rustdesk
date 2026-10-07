#!/usr/bin/env python3
"""Inspect development tooling without dumping credentials or device serials."""
import argparse
import datetime
import json
import os
import platform
import plistlib
import re
import shutil
import subprocess
from pathlib import Path
from zoneinfo import ZoneInfo

ROOT = Path(__file__).resolve().parents[2]
TOOLS = {
    "Xcode": ["xcodebuild", "-version"],
    "Developer directory": ["xcode-select", "-p"],
    "Clang": ["clang", "--version"],
    "Homebrew": ["brew", "--version"],
    "Git": ["git", "--version"],
    "Rustup": ["rustup", "--version"],
    "Rust": ["rustc", "--version"],
    "Cargo": ["cargo", "--version"],
    "Flutter": ["flutter", "--version"],
    "FVM": ["fvm", "--version"],
    "CocoaPods": ["pod", "--version"],
    "Python": ["python3", "--version"],
    "CMake": ["cmake", "--version"],
    "Ninja": ["ninja", "--version"],
    "NASM": ["nasm", "-v"],
    "Yasm": ["yasm", "--version"],
    "pkg-config": ["pkg-config", "--version"],
}


def run(args: list[str], timeout: int = 30) -> tuple[bool, str]:
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
        output = re.sub(r"\x1b\[[0-9;]*m", "", (result.stdout + result.stderr).strip())
        return result.returncode == 0, output
    except (OSError, subprocess.TimeoutExpired) as error:
        return False, str(error)


def inventory() -> dict:
    pins = dict(line.split("=", 1) for line in (ROOT / "scripts/macpilot/toolchain.env").read_text().splitlines() if line and not line.startswith("#"))
    items = {}
    for name, args in TOOLS.items():
        executable = shutil.which(args[0])
        ok, output = run(args) if executable else (False, "Not installed")
        if not ok and "license" in output.lower():
            output = "Installed; blocked by incomplete Xcode license/setup"
        if name == "Xcode" and ok:
            output = "; ".join(output.splitlines())
        items[name] = {"available": ok, "path": executable, "version": output.splitlines()[0] if output else "No output"}
    ok, clt = run(["/usr/bin/env", "DEVELOPER_DIR=/Library/Developer/CommandLineTools", "clang", "--version"])
    items["Command Line Tools Clang"] = {"available": ok, "path": "/Library/Developer/CommandLineTools/usr/bin/clang", "version": clt.splitlines()[0] if clt else "Unavailable"}
    vcpkg = Path(os.environ.get("VCPKG_ROOT", "")) / "vcpkg"
    ok, output = run([str(vcpkg), "version"]) if vcpkg.is_file() else (False, "Not installed")
    items["vcpkg"] = {"available": ok, "path": str(vcpkg) if vcpkg.is_file() else None, "version": output.splitlines()[0] if output else "No output"}
    _, os_version = run(["sw_vers", "-productVersion"])
    _, os_build = run(["sw_vers", "-buildVersion"])
    _, toolchains = run(["rustup", "toolchain", "list"])
    _, submodules = run(["git", "-C", str(ROOT), "submodule", "status"])
    _, upstream = run(["git", "-C", str(ROOT), "rev-parse", "upstream/master"])
    _, fork = run(["git", "-C", str(ROOT), "remote", "get-url", "origin"])
    teams = []
    prefs = Path.home() / "Library/Preferences/com.apple.dt.Xcode.plist"
    try:
        data = plistlib.loads(prefs.read_bytes()) if prefs.exists() else {}
        for value in data.get("IDEProvisioningTeamByIdentifier", {}).values():
            if isinstance(value, dict):
                teams.append(value.get("teamName", "Cached team (name unavailable)"))
    except (OSError, plistlib.InvalidFileException, AttributeError):
        teams = ["Cached team metadata could not be read"]
    identity_ok, identity_metadata = run(["security", "find-identity", "-v", "-p", "codesigning"])
    identity_count = re.search(r"(\d+) valid identities found", identity_metadata)
    signing_count = int(identity_count.group(1)) if identity_ok and identity_count else None
    signing_team_ids = sorted(set(re.findall(r"\(([A-Z0-9]{10})\)", identity_metadata))) if identity_ok else []
    # The full USB report can contain serial numbers; emit only product labels.
    physical = []
    ok, usb = run(["system_profiler", "SPUSBDataType", "-json"], timeout=20)
    if ok:
        try:
            def visit(value):
                if isinstance(value, dict):
                    name = str(value.get("_name", ""))
                    if "ipad" in name.lower() or "iphone" in name.lower():
                        physical.append(name)
                    for child in value.values():
                        visit(child)
                elif isinstance(value, list):
                    for child in value:
                        visit(child)
            visit(json.loads(usb))
        except json.JSONDecodeError:
            pass
    sdk_ok, sdk_error = run(["xcrun", "--sdk", "iphoneos", "--show-sdk-path"])
    mac_sdk_ok, mac_sdk_error = run(["xcrun", "--sdk", "macosx", "--show-sdk-path"])
    blockers = []
    if not items["Xcode"]["available"]:
        blockers.append("Full Xcode is missing or not selected; macOS/iOS compilation and development-device discovery are blocked.")
    if not sdk_ok:
        blockers.append("The iOS SDK is unavailable.")
    if not mac_sdk_ok:
        blockers.append("The selected Xcode's macOS SDK is unavailable.")
    if "license agreements" in sdk_error + mac_sdk_error:
        blockers.append("Apple reports that Xcode license agreements have not been accepted. Complete Xcode's first-launch setup before compilation.")
    for name in ["Flutter", "CocoaPods", "CMake", "Ninja", "NASM", "Yasm", "pkg-config", "vcpkg"]:
        if not items[name]["available"]:
            blockers.append(f"{name} is unavailable.")
    for pin in ["MACPILOT_MACOS_RUST_VERSION", "MACPILOT_IOS_RUST_VERSION"]:
        ok, _ = run(["rustup", "run", pins[pin], "rustc", "--version"])
        if not ok:
            blockers.append(f"Pinned Rust {pins[pin]} is missing.")
    if items["NASM"]["available"] and pins["MACPILOT_NASM_VERSION"] not in items["NASM"]["version"]:
        blockers.append("NASM must be 2.16.03 to match upstream macOS CI.")
    if items["CMake"]["available"] and pins["MACPILOT_CMAKE_VERSION"] not in items["CMake"]["version"]:
        blockers.append(f"CMake must be {pins['MACPILOT_CMAKE_VERSION']} for the pinned vcpkg tool manifest.")
    if submodules.startswith(("-", "+", "U")):
        blockers.append("Required submodules are uninitialized or differ from the pinned commit.")
    cache = Path(os.environ.get("MACPILOT_CACHE_ROOT", str(Path.home() / "Library/Caches/MacPilot")))
    for directory, expected, label in [(cache / "toolchains" / f"flutter-{pins['MACPILOT_FLUTTER_VERSION']}", pins["MACPILOT_FLUTTER_SHA"], "Flutter"), (Path(os.environ.get("VCPKG_ROOT", str(cache / 'toolchains' / f"vcpkg-{pins['MACPILOT_VCPKG_SHA']}"))), pins["MACPILOT_VCPKG_SHA"], "vcpkg")]:
        ok, revision = run(["git", "-C", str(directory), "rev-parse", "HEAD"])
        if not ok or revision != expected:
            blockers.append(f"{label} checkout does not match the pinned revision.")
    for name in ["cargo-expand", "flutter_rust_bridge_codegen"]:
        if not shutil.which(name):
            blockers.append(f"{name} is missing; complete bootstrap after installing Xcode.")
    return {
        "audited_at": datetime.datetime.now(ZoneInfo("Asia/Kolkata")).isoformat(timespec="seconds"),
        "macOS": os_version, "os_build": os_build, "architecture": platform.machine(),
        "free_disk_gib": round(shutil.disk_usage(ROOT).free / 1024**3, 1),
        "tools": items, "rust_toolchains": toolchains.splitlines(),
        "upstream_sha": upstream, "fork": fork, "submodules": submodules,
        "signing_teams": teams, "usb_apple_mobile_devices": physical,
        "valid_code_signing_identities": signing_count, "signing_team_ids": signing_team_ids,
        "device_discovery": "Use --devices with full Xcode" if items["Xcode"]["available"] and sdk_ok else "Unavailable until Xcode setup and iOS SDK access are complete; USB labels alone cannot establish development readiness",
        "blockers": blockers, "pins": pins,
    }


def markdown(data: dict) -> str:
    lines = ["# Development environment", "", f"Audited: {data['audited_at']} (Asia/Kolkata).", "", f"macOS {data['macOS']} ({data['os_build']}), {data['architecture']}; {data['free_disk_gib']} GiB free.", "", "| Tool | Detected version |", "| --- | --- |"]
    for name, item in data["tools"].items():
        lines.append(f"| {name} | {item['version'].replace('|', '/')} |")
    lines += ["", "## Installed Rust toolchains", "", *[f"- {item}" for item in data["rust_toolchains"]], "", "## Apple device and signing status", "", f"Physical USB mobile-device labels: {', '.join(data['usb_apple_mobile_devices']) or 'none discovered'}. This does not verify pairing, trust, or signing.", "", data["device_discovery"] + ".", "", f"Cached signing team names: {', '.join(data['signing_teams']) or 'none discovered'}.", "", f"Valid code-signing identities: {data['valid_code_signing_identities'] if data['valid_code_signing_identities'] is not None else 'unavailable'}; signing team IDs: {', '.join(data['signing_team_ids']) or 'none discovered'}. Only identity counts and team metadata are retained; no certificate material, private keys or Keychain secrets are read.", "", "## Baseline prerequisite blockers", "", *[f"- {item}" for item in data["blockers"]], "", "## Reproduction", "", "Run `scripts/bootstrap_macos.sh --tools-only` for non-Xcode tools. Install and launch full Xcode, then run `scripts/bootstrap_macos.sh` and `scripts/doctor.sh --check`.", "", "Run `scripts/doctor.sh --report docs/ENVIRONMENT.md` to refresh this report. This report contains only tool metadata; credentials, typed input, clipboard contents, and screen contents are never collected.", ""]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Exit nonzero if baseline prerequisites are missing")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--report", type=Path)
    parser.add_argument("--devices", action="store_true", help="List Xcode devices (explicitly includes development device identifiers)")
    args = parser.parse_args()
    data = inventory()
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(markdown(data))
        print(f"Wrote environment report: {args.report}")
    if args.json:
        print(json.dumps(data, indent=2))
    else:
        print(markdown(data))
    if args.devices:
        if not data["tools"]["Xcode"]["available"]:
            print("Device discovery requires full Xcode.")
            return 1
        ok, devices = run(["xcrun", "xctrace", "list", "devices"])
        print(devices)
        if not ok:
            return 1
    return int(args.check and bool(data["blockers"]))


if __name__ == "__main__":
    raise SystemExit(main())
