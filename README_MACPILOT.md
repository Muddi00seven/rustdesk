# MacPilot development

MacPilot is the working name for an iPad-first remote Mac controller built on RustDesk. The upstream engine, protocol, license, attribution, and platform implementations are preserved. The product name has not been cleared for trademark use.

**Status: baseline preparation; product features have not been implemented.** Xcode 27 and the pinned toolchain are installed. Baseline compilation is in progress. The specification requires successful unmodified macOS and iOS builds before changes to application behavior. No successful build, remote session, or MVP acceptance test is claimed.

- Fork: https://github.com/Muddi00seven/rustdesk
- Upstream: https://github.com/rustdesk/rustdesk
- Base: `9f9585ce155a6558f0625eaf8fabfe8827c9a552`
- Development branch: `macpilot/main`
- Checkout: the existing `iDesk` workspace; its original remote is retained as `workspace-origin`.

## Start development

```sh
scripts/bootstrap_macos.sh --tools-only
# Install full Xcode and launch it to complete Apple setup.
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/bootstrap_macos.sh
scripts/doctor.sh --check
scripts/build_macos.sh
scripts/build_ios.sh
```

The default build scripts compile a separate checkout of the exact upstream base under `target/macpilot-baseline/`. Upstream CI's deployment-target substitutions and generated files stay there. `--working-tree` explicitly builds the development checkout instead. Scripts fail on missing dependencies and check output artifacts, rather than reporting success from a packaging command alone.

Use [DEVELOPMENT](docs/DEVELOPMENT.md), [IOS_SETUP](docs/IOS_SETUP.md), and [MACOS_SETUP](docs/MACOS_SETUP.md). The [environment report](docs/ENVIRONMENT.md) and [upstream audit](docs/UPSTREAM.md) record real detected versions and blockers. [ROADMAP](docs/ROADMAP.md) tracks the gated milestones; [MACPILOT_REQUIREMENTS](docs/MACPILOT_REQUIREMENTS.md) retains the requested specification.

Create `macpilot-baseline` only after both baseline builds and runnable baseline checks succeed. This tag does not exist yet. Next comes isolated branding configuration and the device dashboard, followed by input, keyboard, and reconnect work.
