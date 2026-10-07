# Build troubleshooting

## Errors actually observed during baseline preparation

| Error | Cause | Resolution / current state |
| --- | --- | --- |
| `xcodebuild requires Xcode` | Only Command Line Tools were selected at the first audit | Full Xcode 27 subsequently became available |
| `You have not agreed to the Xcode license agreements` | Xcode first-launch/license setup was incomplete | Xcode was opened; SDK access subsequently cleared. Scripts now provide explicit setup remediation |
| NASM configure reports missing standard headers and `cannot make gcc report undeclared builtins` | Apple compiler began rejecting invocations during Xcode setup; this was not a NASM source bug | Tools-only bootstrap uses existing Command Line Tools through process-local `DEVELOPER_DIR` when full Xcode is not usable. NASM 2.16.03 then compiled successfully |
| Bridge generator panics with `only allow "debug" and "info"` | Installed generator 1.80.1 accepts only those two `RUST_LOG` values; the shell inherited `warn` | Set `RUST_LOG=info` for the generator invocation only; application logging policy is unchanged |
| vcpkg downloads CMake 4.4.0 despite CI's `VCPKG_CMAKE_VERSION=4.3.0` | Pinned vcpkg's own `scripts/vcpkg-tools.json` requires 4.4.0 on macOS | Allow its verified tool download. CI's environment value is not the complete tool requirement; record both values |

## Dependency resolution

The bridge uses Flutter 3.22.3 and temporarily resolves `extended_text` 13.0.0 as upstream CI does. Application resolution returns to Flutter 3.24.5 and `extended_text` 14.0.0. Different dependency selections during these two resolutions are expected. Keep application resolution and bridge resolution separate; do not update the main project's lockfiles just to suppress a warning.

First-time Flutter package resolution and Cargo metadata can download substantial dependency graphs and Git forks without regular console output. Check the owning build process and network/download progress before declaring a hang. Avoid simultaneous mutations of the same SDK, installed native package database or build checkout. `target/macpilot-baseline/` checkouts are disposable build artifacts, but the scripts do not delete or reset them automatically.

## Diagnostic hygiene

Use `scripts/doctor.sh --check` for prerequisites. Build logs may include source paths and public dependency names. Never export environment dumps, credential-helper output, signing material, typed input, screen contents or clipboard contents. Keep technical details separate from user-facing remediation. Session/network troubleshooting will be added only after actual runtime validation.
