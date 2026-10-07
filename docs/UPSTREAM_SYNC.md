# Upstream synchronization

The current base and submodule are recorded in `UPSTREAM.md` and `scripts/macpilot/toolchain.env`. `origin` is the user's fork, `upstream` is RustDesk, and `workspace-origin` preserves the original workspace remote. `macpilot-baseline` is the verified initial checkpoint.

## Review before merging

```sh
git status --short
git fetch upstream
git log --oneline macpilot-baseline..upstream/master
git diff --stat macpilot-baseline..upstream/master
git diff macpilot-baseline..upstream/master -- .github/workflows Cargo.toml Cargo.lock flutter/pubspec.yaml flutter/pubspec.lock
```

Use the actual upstream default branch if it changes. Inspect security fixes, protocol/capability changes, Flutter bridge APIs, Apple targets, native dependency pins, capture/input/session/authentication and the exact `hbb_common` commit range. Do not silently bump the submodule to its remote tip.

## Merge policy

Prefer a reviewed merge onto a clean integration branch created from the current development branch. Preserve published milestone commits and tags. Do not destructively rebase published work, force-push, reset user edits or resolve conflicts by wholesale accepting either side. If local work is present, commit or preserve it with the user's chosen workflow first.

Keep feature logic in `flutter/lib/macpilot/` and platform-owned modules. Resolve the thin `main.dart` hooks against upstream's current entry paths. Review branding xcconfigs, bundle metadata, icons and Apple CI deployment substitutions individually. Regenerate Flutter Rust Bridge with newly audited pins rather than editing generated output.

## Validation and checkpoint

Update pin/audit documents only after reviewing the new CI/dependencies. Build both Apple clients sequentially with `--working-tree`, run relevant unit/widget/native tests, then physical input/reconnect/permission/trust acceptance with features both enabled and disabled. Confirm signed bundle identities and service behavior after Apple changes. Inspect the complete regression surface and record new limitations.

Commit the merge and its reviewed compatibility fixes separately where practical. Never move `macpilot-baseline` to a new base. Keep a new annotated checkpoint only after its documented validation succeeds. Push normally to the fork; no future destructive synchronization is automated.
