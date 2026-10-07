# Input system: existing flow and extension contract

Status: milestone 1 does not change input. Pointer/keyboard improvements require the physical session gate in milestone 2.

| Input | Existing source flow |
| --- | --- |
| Pointer/touch | `flutter/lib/common/widgets/remote_input.dart` and mobile `remote_page.dart` → `flutter/lib/models/input_model.dart` → Flutter FFI mouse calls → Rust Session/protocol → host input service → macOS Enigo/CGEvent |
| Hardware keys | `InputModel.handleKeyEvent` / key handlers → `session_input_key` → Rust `KeyEvent` → host input service and Enigo |
| Committed text | Mobile text/composition handling → `session_input_string` → existing host Unicode path |
| Modifiers | `input_modifier_utils.dart` and InputModel modifier state → protocol modifiers → macOS event flags |
| Software keyboard | Mobile remote page owns input controller/focus and explicit Keyboard actions. Existing iOS hardware-keyboard workaround remains intact |
| Relative mouse | Existing InputModel relative-mouse state plus native platform channels; preserve feature-off behavior |

## Planned feature boundaries

Pointer mapping belongs in an iPad feature module beside existing input widgets/models, with one selected direct/relative path into the existing transport. Preserve left/right/middle identity, horizontal/vertical scroll and pressed-button drag state. Coordinate conversion must use the current canvas/display transform. Physical hardware determines which events iPadOS exposes; simulator mouse events are insufficient evidence.

Hardware key mapping must preserve down/up, repeat, modifiers and composition; committed text must not duplicate raw key events. Track one-shot and locked touch modifiers explicitly and release them on disconnect, backgrounding, permission loss and keyboard detach. Reserved iPadOS shortcuts require a visible fallback rather than an interception promise.

Smart keyboard needs a feature-owned host AXObserver and metadata protocol extension with capability negotiation. Client text input must integrate the actual UIKit/Flutter APIs available in the selected SDK. Required secure-context behavior is suppressing automatic text features without recording field values. Manual Keyboard remains available when metadata is absent, unsupported or denied. No AX focus monitor or new UIKit input bridge exists yet.

Reconnect must stop outbound input when transport/authentication is invalid, release tracked pressed keys/buttons and avoid replaying queued input. Extend existing session rounds; do not add another transport or competing reconnect timer.

## Physical test evidence required

Record iPad/iPadOS, keyboard/trackpad model, Mac/macOS, route, view mode and display geometry. Test typing, IME/emoji, drag, both scroll axes, right/middle click, common Command shortcuts, hardware attach/detach, software-keyboard transitions, app background/lock and network interruption. `TEST_PLAN.md` contains MVP workflows A–D. None has passed yet.
