# Open-source compliance record

Upstream: https://github.com/rustdesk/rustdesk. Fork: https://github.com/Muddi00seven/rustdesk. Base commit: `9f9585ce155a6558f0625eaf8fabfe8827c9a552`. The root `LICENCE` retains the GNU Affero General Public License version 3, June 29, 2007. Upstream copyright, authorship, credits, license text, and notices remain intact.

## Current modifications

Only MacPilot development scripts, audit/setup documentation, roadmap status, and retained requirements have been added. No existing application runtime path, display name, bundle ID, protocol identifier, copyright notice, or license has been changed. Build checkouts receive only the deployment-target and bridge-generation adjustments used by upstream CI. Record subsequent product modifications and their dates here as milestones are implemented.

## Distribution and network interaction

The retained license is the governing text. Before distributing a modified binary, preserve required notices and provide the applicable Corresponding Source, including modifications and the scripts/configuration needed to build the covered work, through a license-compliant method. Mark modified work appropriately and retain the applicable license terms. AGPL section 13 addresses offering Corresponding Source to users who interact remotely with a modified version over a network. A rename or private relay does not remove that obligation. Do not remove upstream attribution or add restrictions intended to evade the license.

A public source fork alone does not verify that the precise source, dependency versions, build scripts and required notices for a particular distributed binary are available. No binary distribution or compliance sign-off has occurred in this milestone.

## Third-party inventory

Dependency sources and pins are retained in `Cargo.toml`, `Cargo.lock`, `flutter/pubspec.yaml`, `vcpkg.json`, `.gitmodules`, individual `libs/*/Cargo.toml` manifests and native platform projects. Important categories include:

- RustDesk shared `hbb_common` at `229b904508364c8997aad0fb5af57effac859f60`; vendored capture, input, clipboard, transfer and platform crates.
- Flutter/Dart and Flutter plugins, including RustDesk's pinned Git forks; `flutter_rust_bridge` and its generated bindings.
- vcpkg native multimedia dependencies, including libvpx, libyuv, Opus, AOM, libjpeg-turbo, and platform-dependent FFmpeg features.
- Rust networking, encryption, transport, serialization and platform dependencies recorded in the lockfile; Git dependencies must retain their resolved revisions.
- Apple SDKs and frameworks used for the Apple builds, under their applicable Apple development/distribution terms.
- Build-only tools: Rust, CMake, LLVM, NASM, Yasm, Ninja and CocoaPods.

Do not assign the root AGPL license to every dependency without inspecting its own license. A resolved package/license inventory and bundled notices must be generated after successful dependency resolution, for the exact distributed configuration. Pay particular attention to codec/FFmpeg features and any additional patent/distribution obligations. No third-party notice file has been removed.

Reference: [retained upstream license](https://github.com/rustdesk/rustdesk/blob/9f9585ce155a6558f0625eaf8fabfe8827c9a552/LICENCE), especially sections 4–6 and 13.
