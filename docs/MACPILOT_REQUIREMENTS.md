You are acting as the principal engineer, Apple-platform engineer, Rust engineer,
Flutter engineer, UX architect, QA engineer, and DevOps engineer for this project.

PROJECT WORKING NAME
---
MacPilot

This is a working name only. Do not assume trademark availability.
Internally use "MacPilot" for bundle/display naming where convenient, but keep
all branding changes isolated so the product can easily be renamed later.

MISSION
---
I want to fork the open-source RustDesk project and turn it into a substantially
better iPad-first remote Mac controller.

My primary workflow is:

    iPad / iPad Pro
          ↓
    Internet / LAN
          ↓
    MacBook / Mac mini / future Macs

The Mac may be physically somewhere else.

I want to be able to use the Mac from the iPad for extended periods as if the
iPad were a thin client for the Mac.

This is NOT just a cosmetic RustDesk rebrand.

The main product differentiation is the interaction experience:
- excellent iPad touch support
- excellent Magic Keyboard / Bluetooth keyboard support
- excellent trackpad / mouse support
- automatic software keyboard behavior
- Apple-like UX
- extremely reliable unattended remote access
- reconnection
- good network degradation handling
- multiple Macs
- self-hosting
- privacy
- minimal friction

The existing RustDesk remote-desktop/video/networking engine should be reused
where appropriate. Do NOT rewrite mature remote-desktop infrastructure from
scratch unless there is a clear technical reason.

UPSTREAM
---
Official upstream repository:

https://github.com/rustdesk/rustdesk

IMPORTANT:
Before installing tools or changing source code, inspect the CURRENT upstream
repository.

Do not blindly trust version numbers from tutorials.

Inspect at minimum:
- README.md
- Cargo.toml
- Cargo.lock
- build.py
- vcpkg.json / vcpkg configuration
- flutter/pubspec.yaml
- flutter/ios/
- flutter/macos/
- .github/workflows/flutter-build.yml
- any current development/build documentation
- relevant platform-specific input modules
- relevant clipboard modules
- relevant connection/session modules

Use the versions and build procedure used by CURRENT upstream CI whenever
possible.

LEGAL / OPEN-SOURCE REQUIREMENTS
---
RustDesk is open source.

Do not remove or hide required copyright notices, license files, attribution,
or third-party notices.

Create:

    docs/OPEN_SOURCE_COMPLIANCE.md

Document:
- upstream repository
- upstream commit SHA used
- license
- our modifications
- third-party dependencies
- obligations that apply if the modified software is distributed

Do not make changes intended to evade AGPL/open-source obligations.

SAFETY RULES WHILE MODIFYING MY MACHINE
---
You have permission to inspect this project, install ordinary development
dependencies where appropriate, create files, build software, and run tests.

However:

1. Never delete unrelated files.
2. Never use destructive git commands such as:
       git reset --hard
       git clean -fdx
   unless I explicitly authorize it.
3. Never erase signing identities, certificates, provisioning profiles,
   Keychain data, Xcode settings, or other system configuration.
4. Do not expose secrets in logs.
5. Never commit passwords, tokens, signing certificates, API keys, server
   private keys, or Apple credentials.
6. Before a command requiring sudo, explain why it is necessary.
7. Preserve upstream as a git remote.
8. Commit work in logical checkpoints.
9. If the baseline upstream build does not work, diagnose that first.
   Do not start product modifications on top of a broken baseline.

---
PHASE 0 — AUDIT THE DEVELOPMENT MACHINE
---

First inspect the local machine and report:

- macOS version
- CPU architecture
- Xcode version
- xcode-select path
- clang version
- Homebrew status
- Git version
- Rust/rustup/cargo status
- Flutter/FVM status
- CocoaPods status
- Python version
- cmake
- ninja
- nasm
- yasm
- pkg-config
- vcpkg status
- available disk space
- connected physical iOS/iPadOS development devices if discoverable
- Apple signing teams visible to Xcode where safely inspectable

Do not reveal sensitive certificate material.

Create:

    docs/ENVIRONMENT.md

Record detected development versions.

---
PHASE 1 — FORK / CLONE / BASELINE
---

If no repository exists yet:

1. Fork rustdesk/rustdesk to my GitHub account if GitHub authentication and
   authorization are already available.

If automatic forking is not available:
- tell me the exact one-time GitHub action I need to perform
- then continue once the fork exists

Clone MY fork, not a disconnected copy.

Suggested local directory:

    ~/Developer/MacPilot

Configure remotes:

    origin    = my fork
    upstream  = https://github.com/rustdesk/rustdesk.git

Initialize all required submodules.

Create development branch:

    macpilot/main

Record upstream commit SHA.

Create:

    docs/UPSTREAM.md

Include:
- fork URL
- upstream URL
- base SHA
- date
- important build/toolchain observations

----------------------------------------------------------------------
BASELINE BUILD
----------------------------------------------------------------------

Before changing application behavior:

1. Build current RustDesk macOS Flutter client.
2. Build the iOS/iPadOS client.
3. Run macOS client.
4. Install/run iPad client on a physical iPad if one is connected and signing
   allows it.
5. Establish a baseline Mac-to-iPad/iPad-to-Mac remote session.
6. Record any upstream bugs separately.

Do not rebrand anything until baseline compilation succeeds.

Use CURRENT `.github/workflows/flutter-build.yml` and current upstream code as
the source of truth for:
- Rust versions
- Flutter version
- targets
- bridge generation
- feature flags
- vcpkg triplets
- build commands

Create reproducible bootstrap scripts:

    scripts/bootstrap_macos.sh
    scripts/build_macos.sh
    scripts/build_ios.sh
    scripts/run_ios.sh
    scripts/doctor.sh

Scripts must:
- be idempotent where practical
- use `set -euo pipefail`
- give readable errors
- verify dependencies instead of silently assuming them
- never store secrets

---
PHASE 2 — UNDERSTAND THE EXISTING ARCHITECTURE
---

Before implementing new features, trace these paths through the project:

1. remote video frame pipeline
2. pointer input
3. mouse buttons
4. scroll events
5. keyboard events
6. modifier keys
7. clipboard
8. file transfer
9. session state
10. authentication
11. unattended access
12. rendezvous/relay transport
13. reconnect behavior
14. iOS Flutter/native integration
15. macOS native integration
16. display/monitor switching
17. audio transport if supported
18. hardware codec path

Create:

    docs/ARCHITECTURE.md

Show:

iPad UI
    ↓
Flutter input/session layer
    ↓
Rust FFI
    ↓
RustDesk protocol/session
    ↓
transport
    ↓
Mac host
    ↓
macOS input / display / Accessibility APIs

For each custom feature described below, identify precisely which existing
components should be extended rather than duplicated.

---
PHASE 3 — PRODUCT EXPERIENCE
---

The new product should feel like an Apple-native remote computer experience.

DO NOT make the interface visually busy.

Design philosophy:
- iPad-first
- edge-to-edge remote display
- almost no permanent chrome during a session
- progressive disclosure
- SF-style iconography where legally/technically appropriate
- native-feeling animations
- large touch targets
- dark/light appearance
- excellent landscape mode
- portrait mode still usable
- keyboard users should rarely need to touch the screen
- touch-only users must still be productive

Do not copy Apple's proprietary UI pixel-for-pixel.

----------------------------------------------------------------------
HOME SCREEN
----------------------------------------------------------------------

Create an Apple-like device dashboard.

Header:

    MacPilot

Sections:

    My Macs
    Recent
    Add Mac

Each Mac card should show:
- friendly computer name
- machine/device icon
- online/offline
- LAN / Internet indication
- last seen
- latency when known
- favorite indicator
- optional thumbnail/snapshot if privacy setting permits
- current connection status

Example:

    ┌─────────────────────────────────┐
    │ 🖥 Mac Studio                  ● │
    │ Online · 28 ms                  │
    │ Home                            │
    └─────────────────────────────────┘

Quick actions:
- Connect
- Wake (when supported)
- Settings
- Rename
- Remove
- Diagnostics

Never display confusing RustDesk IDs as the dominant UX.
IDs may remain available under Advanced / Technical Info.

----------------------------------------------------------------------
SESSION SCREEN
----------------------------------------------------------------------

Remote screen should occupy essentially the entire iPad display.

Default controls should auto-hide.

Top/bottom floating pill or compact toolbar can expose:

- Disconnect
- Keyboard
- Touch/Trackpad mode
- Modifier keys
- Display
- Resolution
- Quality
- Clipboard
- Files
- Connection stats
- Settings

Toolbar fades away after inactivity.

Single tap near designated edge can restore controls.

Support Stage Manager/window resizing gracefully.

Respect iPad safe areas.

---
PHASE 4 — INPUT MODES
---

Implement two explicit pointer modes.

MODE A — DIRECT TOUCH
---------------------

The remote screen behaves like a giant touch surface.

Mapping:

single tap
    left click at touched remote coordinate

double tap
    double click

long press
    right click

touch + hold + move
    drag

two-finger vertical/horizontal movement
    scroll

pinch
    local viewport zoom

two-finger tap
    right click alternative

Allow these mappings to be configurable.

Provide subtle haptic feedback where useful and supported.

Never add noticeable artificial latency.

MODE B — TRACKPAD MODE
----------------------

Touch movement controls a cursor relatively, like a trackpad.

Mapping:

one finger move
    move pointer

tap
    left click

two finger tap
    right click

two finger drag
    scroll

tap + drag
    drag object

Optional:
three-finger configurable actions.

Trackpad mode must work even if the iPad does not have a hardware trackpad.

----------------------------------------------------------------------
HARDWARE MOUSE / MAGIC KEYBOARD TRACKPAD
----------------------------------------------------------------------

When iPadOS reports a hardware pointer:

- use natural pointer input
- preserve button identity
- support left click
- support right click
- support middle click if available
- smooth scrolling
- horizontal scrolling
- drag
- hover
- cursor positioning
- pointer acceleration behavior should feel predictable

Avoid treating every pointer event like a touchscreen event.

---
PHASE 5 — KEYBOARD EXPERIENCE
---

THIS IS ONE OF THE MOST IMPORTANT FEATURES.

Current remote desktop tools often make iPad software keyboard interaction
annoying.

I want the following behavior:

User taps/clicks a text field inside the remote Mac.

Mac detects that the currently focused macOS accessibility element is editable.

Mac sends an INPUT_CONTEXT event to the iPad.

iPad automatically activates its local text input system.

If no hardware keyboard is attached:
    iPad software keyboard opens automatically.

If a hardware keyboard is attached:
    focus stays ready for hardware typing without showing an unnecessary
    software keyboard.

When the remote editable field loses focus:
    input context ends appropriately.

----------------------------------------------------------------------
MAC ACCESSIBILITY FOCUS DETECTION
----------------------------------------------------------------------

Investigate using macOS Accessibility APIs such as:

    AXUIElement
    AXObserver
    kAXFocusedUIElementAttribute

Detect editability without reading or transmitting the user's text.

Potential roles/subroles include:
- text field
- text area
- search field
- editable web field
- secure/password text field
- document editor
- other accessibility-editable controls

Do NOT depend solely on role names.

Build robust detection.

Prefer event-based AXObserver notifications over high-frequency polling.

The Mac host should send something conceptually like:

    InputContextChanged {
        editable: true/false,
        secure: true/false,
        multiline: true/false,
        source: accessibility
    }

Do not transmit the actual remote field contents merely to decide whether the
keyboard should appear.

Password/secure inputs require special privacy handling.

If Accessibility does not expose enough information for a particular app,
fall back gracefully to the manual Keyboard button.

Do not make the remote connection unusable just because smart keyboard
detection failed.

----------------------------------------------------------------------
IPAD TEXT INPUT BRIDGE
----------------------------------------------------------------------

Investigate the best implementation using:
- Flutter TextInputClient/TextInputConnection
and/or
- a small native UIKit text-input bridge

Requirements:

1. Calling the bridge must reliably invoke iPadOS text input.
2. Hardware keyboard input must also work.
3. It must not place a visible fake text box over the remote desktop.
4. It must not steal pointer events.
5. It must support:
   - ordinary typing
   - Shift
   - Control
   - Option
   - Command
   - arrows
   - Return
   - Escape
   - Tab
   - Backspace/Delete
   - Home/End equivalents where available
   - Unicode
   - emoji where practical
   - common IME input where architecture permits
6. It must correctly terminate input when remote focus changes.

Add manual keyboard button regardless of auto-detection.

----------------------------------------------------------------------
KEYBOARD SHORTCUTS
----------------------------------------------------------------------

External keyboard behavior must be excellent.

Support remote equivalents of:

Command+C
Command+V
Command+X
Command+A
Command+Z
Command+Shift+Z
Command+S
Command+F
Command+T
Command+W
Command+Q
Command+Space
Command+Tab
Option+Tab where meaningful
Control combinations
Function keys where hardware exposes them

Be aware that iPadOS can intercept some shortcuts.

Investigate available APIs and document shortcuts that cannot reliably be
forwarded.

Create an optional compact shortcut row for touch users:

    esc | ⌘ | ⌥ | ⌃ | ⇧ | tab | arrows | ⌘C | ⌘V

Modifier buttons should support:
- one-shot press
- locked state
- visual indication

---
PHASE 6 — CLIPBOARD
---

Clipboard should feel close to local use.

Support where technically appropriate:
- iPad text → Mac
- Mac text → iPad
- URLs
- rich text if supported by existing engine
- images if existing RustDesk protocol supports it safely
- files through explicit file transfer, not accidental giant clipboard sync

Handle iPadOS clipboard privacy requirements correctly.

Avoid repeatedly reading the clipboard in the background.

Provide setting:

    Clipboard Sync
        Automatic
        Ask
        Off

Default should favor privacy and platform rules.

---
PHASE 7 — DISPLAY AND RESOLUTION
---

Remote session display settings:

Resolution:
- Auto
- Native
- 2560×1440
- 1920×1080
- 1600×900
- 1280×720
- custom if upstream supports it

Scaling:
- Fit
- Fill
- 1:1
- Smart

Quality:
- Auto
- Data Saver
- Balanced
- High
- Maximum

FPS:
- Auto
- 30
- 60
- higher only where existing architecture actually supports it

Codec:
- Auto
- expose advanced codec settings only if meaningful

Auto mode should react to:
- RTT
- packet loss
- decoder performance
- bandwidth
- render backlog

Do not switch quality so aggressively that the screen visibly oscillates.

Use hysteresis/debouncing.

---
PHASE 8 — MULTI-MONITOR MACS
---

If the Mac has multiple displays:

Provide:
- Display 1
- Display 2
- All Displays if supported
- quick swipe/switch gesture
- keyboard shortcut
- display selector from toolbar

Remember preference per Mac.

---
PHASE 9 — CONNECTION EXPERIENCE
---

Connection should use clear stages:

    Finding Mac…
    Connecting…
    Securing connection…
    Starting display…
    Connected

Do not leave the user staring at a spinner with no explanation.

Session HUD should optionally show:

    24 ms
    60 FPS
    18 Mbps
    H.265

Only show technical stats when requested.

----------------------------------------------------------------------
RECONNECTION
----------------------------------------------------------------------

Transient Internet loss must not immediately destroy the session.

Implement state machine roughly:

CONNECTED
    ↓
DEGRADED
    ↓
RECONNECTING
    ↓
CONNECTED

or after timeout:

RECONNECT_FAILED

Use reasonable exponential backoff.

Example sequence:

0 sec
1 sec
2 sec
4 sec
8 sec
15 sec

Cap appropriately.

During reconnect:
- retain last remote frame with dim overlay
- show "Reconnecting…"
- preserve session UI state
- do not duplicate keyboard/pointer events
- stop sending input until transport is valid

Offer:
    Retry
    Disconnect

When connection returns, recover without requiring user login again if the
existing authenticated session can safely resume.

---
PHASE 10 — UNATTENDED ACCESS
---

This product is intended for my OWN trusted Macs.

I need true unattended access.

Mac host should support:

- start automatically at login
- appropriate background/service architecture inherited from RustDesk
- persistent trusted-device authentication
- no person required at the Mac for ordinary connection
- optional device PIN/password
- key stored in Keychain where appropriate
- trusted iPad pairing
- ability to revoke an iPad
- connection audit history

Do not weaken macOS security boundaries.

macOS permissions onboarding must explain:

1. Screen Recording
2. Accessibility
3. Input Monitoring when required

Build an onboarding checklist:

    Screen Recording       ✓
    Accessibility          ✓
    Input Monitoring       ✓ / not required
    Background Service     ✓
    Ready for Remote Access ✓

Provide buttons that open the appropriate macOS System Settings pane when
possible.

After permission changes, detect whether restart/relaunch is required and
explain it clearly.

---
PHASE 11 — WAKE / SLEEP BEHAVIOR
---

Do not pretend software can remotely control a Mac that is fully powered off
unless appropriate hardware/platform support exists.

Investigate legitimate Apple/macOS mechanisms for:

- Wake for network access
- Wake-on-LAN where available
- sleeping Mac wake behavior
- Apple Silicon limitations
- MacBook closed-lid behavior
- Mac mini behavior

Implement only what can reliably work.

UI must clearly distinguish:

    Online
    Sleeping / Wake available
    Offline
    Unknown

If Wake-on-LAN is supported on LAN, implement it carefully.

If remote wake over the public Internet requires another always-on node or VPN,
document that rather than claiming magic wake capability.

---
PHASE 12 — MULTIPLE MACS
---

Architecture must support multiple machines from day one.

Example:

My Macs

    Mac Studio
    MacBook Pro
    Office Mac mini
    Render Mac mini

Store per-machine:
- ID
- friendly name
- trusted key reference
- last connection
- settings
- display preference
- resolution preference
- input preference

Sensitive authentication data belongs in Keychain, not plaintext preferences.

---
PHASE 13 — LOCAL NETWORK FAST PATH
---

When iPad and Mac are on the same LAN:

Prefer a direct local connection when safe and supported.

Goal:
- lower latency
- higher bitrate
- less relay usage

When away from home:
- direct peer-to-peer if possible
- otherwise relay

Expose connection type only under diagnostics:

    Direct LAN
    Direct Internet
    Relay

Do not force ordinary users to understand NAT traversal.

---
PHASE 14 — SELF-HOSTING
---

I eventually want complete infrastructure control.

Preserve compatibility with RustDesk self-hosting where practical.

Create:

    docs/SELF_HOSTING.md

Document:
- rendezvous component
- relay component
- ports
- encryption/key setup
- DNS
- TLS where applicable
- firewall considerations
- Docker deployment if supported upstream
- updating safely
- backing up configuration
- client configuration

For development, local self-hosting can be tested first.

Do NOT embed public server credentials.

Provide configuration screen:

Server:
    Automatic / Custom

Custom:
    ID/Rendezvous server
    Relay server
    API server where applicable
    public key / trusted key configuration where applicable

Keep advanced server options out of the normal user path.

---
PHASE 15 — SECURITY
---

Remote desktop software has a large security surface.

Required principles:

- authenticated connections
- encryption
- never log plaintext passwords
- never log clipboard contents
- never log typed keystrokes
- protect persistent secrets with OS secure storage
- verify server keys where architecture supports it
- rate-limit authentication attempts
- sensible lockout behavior
- clear remote-session indicator on host
- revoke trusted device
- audit session start/end
- no silent privilege escalation

Add a security review document:

    docs/SECURITY.md

Threat-model:
- stolen iPad
- malicious relay
- MITM
- compromised local network
- brute-force password
- replay
- malicious pairing attempt
- stale trusted device
- accidental clipboard leak

---
PHASE 16 — PRIVACY
---

Do not add analytics or telemetry by default.

Create privacy controls:

Diagnostics:
    Off
    Local logs
    Anonymous diagnostics (future only, opt-in)

Logs should redact:
- passwords
- keys
- tokens
- clipboard content
- text entered
- private screen contents

---
PHASE 17 — ERROR HANDLING
---

Implement typed/structured errors, not random strings scattered through UI.

Major categories:

NetworkError
AuthenticationError
PermissionError
ServerError
CodecError
DecoderError
DisplayCaptureError
InputPermissionError
ClipboardError
FileTransferError
ConfigurationError
VersionMismatchError
PairingError
WakeError

Each user-visible failure needs:

1. human-readable title
2. short explanation
3. action
4. technical details expandable separately
5. machine-readable error code
6. diagnostic log entry with no secrets

Examples:

"No Internet Connection"
"Mac is Offline"
"MacPilot needs Screen Recording permission"
"MacPilot cannot control this Mac until Accessibility is enabled"
"Relay server unavailable"
"Connection timed out"
"Authentication failed"
"Decoder could not start"
"Remote display changed"
"Session ended on the Mac"
"Version mismatch"
"Server identity changed"

For server identity/key changes, do NOT silently trust the new identity.

Warn the user.

---
PHASE 18 — NETWORK EDGE CASES
---

Explicitly test:

- Wi-Fi → cellular transition
- cellular → Wi-Fi
- VPN enabled/disabled
- high packet loss
- 500+ ms latency
- temporary DNS failure
- relay outage
- rendezvous outage
- Mac changes IP
- iPad locks/unlocks
- app goes background/foreground
- iPad rotation
- Stage Manager resize
- Mac display sleeps
- Mac user switches account
- Mac screen locks
- remote app crashes
- remote helper/service restarts

The app should fail gracefully.

---
PHASE 19 — UX FOR NETWORK PROBLEMS
---

Use subtle status notifications.

Examples:

    Network quality reduced
    Switching to lower quality…

    Connection interrupted
    Reconnecting…

    Direct connection unavailable
    Using relay

Avoid modal popups for transient issues.

Use modal alerts only when user action is truly required.

---
PHASE 20 — PERFORMANCE
---

Measure instead of guessing.

Add development diagnostics for:

- RTT
- capture FPS
- encoded FPS
- decoded FPS
- displayed FPS
- encode latency
- decode latency
- frame queue
- bitrate
- packet loss
- dropped frames
- CPU
- GPU where observable
- memory

Do not permanently show these to ordinary users.

Optimize for perceived input latency.

Prioritize:
1. pointer responsiveness
2. typing responsiveness
3. smooth scrolling
4. frame quality

A 4K image that feels delayed is worse than a slightly softer image with
responsive input.

---
PHASE 21 — IPAD EXPERIENCE DETAILS
---

Support:

- landscape
- portrait
- rotation while connected
- split view if platform permits
- Stage Manager
- external display scenarios where practical
- hardware keyboard attach/detach during session
- trackpad attach/detach during session
- software keyboard
- Apple Pencil as pointer if practical

If Apple Pencil support is implemented:
- tap = click
- hover if exposed by API
- do not over-engineer pressure unless there is a meaningful use case

---
PHASE 22 — TOUCH KEYBOARD ACCESSORY
---

When software keyboard is visible, optionally show a small accessory strip:

    esc  ⌘  ⌥  ⌃  ⇧  tab  ← ↑ ↓ →  hide keyboard

It should be configurable.

Do not consume half of the screen.

---
PHASE 23 — SESSION GESTURES
---

Build a Settings → Controls page.

Presets:

Touch
Trackpad
Custom

Allow remapping:

Single tap
Double tap
Long press
Two finger tap
Two finger scroll
Pinch
Three finger swipe

Avoid gestures that conflict badly with system-level iPad gestures.

Show an interactive tutorial the first time.

---
PHASE 24 — ONBOARDING
---

First launch on iPad:

Screen 1
    Your Mac, anywhere.

Screen 2
    Add your Mac

Screen 3
    Securely pair

Screen 4
    Controls tutorial

Then device dashboard.

First launch on Mac:

    Make this Mac available remotely

Checklist:
    Screen Recording
    Accessibility
    Input access
    Start MacPilot automatically
    Pair an iPad

Avoid long paragraphs.

---
PHASE 25 — REBRANDING ARCHITECTURE
---

Branding must be centralized.

Create configuration/constants for:

PRODUCT_NAME
BUNDLE_DISPLAY_NAME
APP_ICON
LOGO
SUPPORT_URL
PRIVACY_URL
DEFAULT_SERVER_POLICY

Avoid replacing thousands of arbitrary strings manually.

Keep upstream protocol compatibility unless there is a compelling reason to
change it.

Do not rename low-level protocol identifiers simply for branding.

---
PHASE 26 — APP ICON / VISUAL PLACEHOLDERS
---

Do not spend excessive engineering time on final artwork.

Create clean development placeholders.

UI style:
- black/white/neutral
- glass/material only when performance is acceptable
- Apple-like spacing
- rounded cards
- readable typography
- strong accessibility contrast

Avoid:
- neon gamer UI
- giant gradients
- excessive shadows
- dashboard clutter

---
PHASE 27 — ACCESSIBILITY
---

Our iPad UI itself must support:

- VoiceOver labels
- Dynamic Type where appropriate
- sufficient contrast
- meaningful accessibility identifiers
- keyboard navigation
- reduced-motion behavior where possible

---
PHASE 28 — TESTING
---

Create automated tests wherever practical.

At minimum:

UNIT TESTS
- connection state machine
- reconnect backoff
- input-context state
- modifier state
- settings serialization
- device storage abstraction
- error mapping

WIDGET/UI TESTS
- device list
- connecting state
- reconnect overlay
- toolbar behavior
- keyboard state
- settings

NATIVE TESTS where practical
- macOS accessibility editable-element classification
- keyboard bridge state

INTEGRATION TEST CHECKLIST
- connect iPad to Mac
- tap Safari address field
- iPad keyboard appears
- enter URL
- Return
- use Command+L
- use Command+T
- use Command+W
- click text editor
- type
- select text
- copy/paste
- scroll
- drag window
- right click
- reconnect after Wi-Fi interruption

Create:

    docs/TEST_PLAN.md

---
PHASE 29 — MANUAL ACCEPTANCE TEST
---

The MVP is NOT complete until this workflow works:

TEST A — TOUCH ONLY

1. Open MacPilot on iPad.
2. Tap saved Mac.
3. Connect.
4. Navigate macOS using touch.
5. Open Safari.
6. Tap address bar.
7. Software keyboard appears automatically.
8. Type URL.
9. Press Return.
10. Scroll webpage.
11. Long press / right click.
12. Open another application.
13. Type into a text field.
14. Disconnect.

TEST B — MAGIC KEYBOARD / TRACKPAD

1. Connect iPad Magic Keyboard.
2. Connect to Mac.
3. Trackpad moves remote pointer naturally.
4. Left/right click work.
5. Two-finger scroll works.
6. Hardware typing works.
7. Cmd+C/V/A/Z work where platform allows.
8. Cmd+Tab handling is documented/tested.
9. No unwanted iPad software keyboard appears.

TEST C — INTERNET INTERRUPTION

1. Connect.
2. Disable network for 5 seconds.
3. UI enters Reconnecting state.
4. Re-enable network.
5. Session resumes without restarting manually where possible.

TEST D — PERMISSIONS

Remove Accessibility permission.

App must:
- detect it
- explain exact issue
- provide remediation
- not misleadingly show "connected and working"

---
PHASE 30 — OBSERVABILITY
---

Create a local diagnostics screen:

Connection
-----------
Transport:
Relay/direct
RTT
FPS
Bitrate
Codec
Resolution

Host
----
Screen capture permission
Accessibility permission
Input permission

Client
------
decoder
render FPS
input mode
keyboard mode

Provide:

    Export Diagnostics

It must redact sensitive information.

---
PHASE 31 — DOCUMENTATION
---

Create:

README_MACPILOT.md

docs/
    ARCHITECTURE.md
    ENVIRONMENT.md
    UPSTREAM.md
    DEVELOPMENT.md
    IOS_SETUP.md
    MACOS_SETUP.md
    SELF_HOSTING.md
    SECURITY.md
    OPEN_SOURCE_COMPLIANCE.md
    INPUT_SYSTEM.md
    TROUBLESHOOTING.md
    TEST_PLAN.md
    ROADMAP.md

DEVELOPMENT.md must allow me to reproduce the environment from a clean Mac.

IOS_SETUP.md must explain:
- Xcode signing
- developer team
- bundle ID
- physical iPad build
- simulator limitations
- device trust
- common CocoaPods failures

MACOS_SETUP.md must explain:
- development build
- permissions
- launch-at-login/service behavior
- code signing
- running unsigned local development builds

---
PHASE 32 — DEVELOPMENT ROADMAP
---

Do NOT attempt every feature simultaneously.

Use milestones.

MILESTONE 0
Baseline upstream build.

MILESTONE 1
Rebrand architecture + clean device dashboard.

MILESTONE 2
Stable iPad → Mac remote session.

MILESTONE 3
Excellent pointer/touch/trackpad handling.

MILESTONE 4
Excellent hardware keyboard.

MILESTONE 5
Automatic remote editable-field detection + software keyboard.

MILESTONE 6
Reconnect/network-quality handling.

MILESTONE 7
Unattended access and permission onboarding.

MILESTONE 8
Multiple Macs.

MILESTONE 9
Self-hosted infrastructure.

MILESTONE 10
Production hardening/testing.

After EACH milestone:
- build macOS
- build iOS
- run relevant tests
- document result
- create git commit

---
PHASE 33 — CODE QUALITY
---

Do not build one enormous patch.

Follow existing RustDesk conventions unless there is a strong reason not to.

For custom code use clear module boundaries.

Possible conceptual modules:

macOS:
    input_context_monitor
    permission_monitor
    wake_support

iOS:
    remote_text_input
    touch_mapper
    pointer_mapper
    keyboard_mapper
    modifier_state

shared:
    connection_state
    diagnostics
    device_profile

Actual paths should follow the existing project structure after you inspect it.

Avoid:
- god classes
- global mutable state
- random boolean flags
- platform checks scattered everywhere
- duplicated connection logic

---
PHASE 34 — FEATURE FLAGS
---

For risky new functionality, use internal feature flags during development:

smart_remote_keyboard
new_ipad_pointer
new_reconnect_ui
mac_permission_onboarding

This lets us compare against upstream behavior.

---
PHASE 35 — UPSTREAM MAINTAINABILITY
---

I want to continue receiving RustDesk fixes.

Therefore:

- minimize unnecessary modifications to upstream core
- isolate MacPilot-specific features
- preserve upstream remote
- document merge procedure

Create:

    docs/UPSTREAM_SYNC.md

Procedure should cover:

    git fetch upstream
    review upstream changes
    merge/rebase strategy
    rebuild
    run tests
    resolve MacPilot platform changes carefully

Do not automatically perform future destructive rebases.

---
PHASE 36 — KNOWN LIMITATIONS
---

Never hide platform limitations.

Maintain:

    docs/KNOWN_LIMITATIONS.md

Examples may include:
- iPadOS-reserved keyboard shortcuts
- Mac sleep/wake limitations
- App Store/background restrictions
- secure text field limitations
- clipboard permission behavior
- closed-lid MacBook constraints
- simulator vs physical-device differences

---
PHASE 37 — APP STORE READINESS, BUT NOT YET SUBMISSION
---

Keep architecture compatible with future distribution.

Check:
- bundle identifier isolation
- privacy manifests
- permission descriptions
- entitlements
- background modes
- local network permission descriptions
- cryptography declarations where applicable
- App Store restrictions related to remote desktop apps

Do not submit anything.

Do not change my Apple Developer account.

Create:

    docs/APP_STORE_READINESS.md

---
PHASE 38 — DO NOT OVER-PROMISE
---

For every requested feature classify it as:

A. straightforward
B. possible but platform constrained
C. experimental
D. not reliably possible

If something is impossible because of iPadOS/macOS restrictions, say so and
design the best fallback.

Never fake functionality.

---
HOW I WANT YOU TO WORK
---

Do not merely give me a tutorial.

You are working on the repository.

Use this loop:

1. Inspect.
2. Explain briefly what you found.
3. Implement.
4. Compile.
5. Test.
6. Fix.
7. Document.
8. Commit.
9. Continue.

Do not stop after generating boilerplate.

If a compile error occurs:
- inspect the real error
- identify root cause
- fix it
- rerun the build

Do not disable important checks just to obtain a green build.

Do not comment broken code out unless it is genuinely obsolete.

Do not invent APIs.

Check the actual SDK/project APIs available on this machine.

---
INITIAL EXECUTION — START NOW
---

Start with ONLY the following initial sequence:

STEP 1
Audit the Mac development environment.

STEP 2
Clone/fork current RustDesk and initialize submodules.

STEP 3
Inspect current upstream CI and determine exact required toolchain.

STEP 4
Create `docs/ENVIRONMENT.md` and `docs/UPSTREAM.md`.

STEP 5
Install any missing non-destructive build dependencies.

STEP 6
Successfully compile the unmodified macOS Flutter build.

STEP 7
Successfully compile the unmodified iOS/iPadOS build.

STEP 8
Run the baseline app where possible.

STEP 9
Create a baseline git commit/tag:

    macpilot-baseline

STEP 10
Produce a concise report containing:

- upstream commit
- installed toolchain
- macOS build status
- iOS build status
- physical iPad status
- blockers
- next milestone

ONLY THEN begin Milestone 1.

---
TOP PRODUCT PRIORITIES
---

If priorities ever conflict, use this order:

1. reliability
2. security
3. low input latency
4. keyboard experience
5. trackpad/touch experience
6. reconnect behavior
7. visual polish
8. advanced extras

The ultimate standard is:

I should be able to leave my Mac/Mac mini at home, take only my iPad and
keyboard/trackpad, and perform long real work sessions remotely without
constantly fighting the remote-desktop software.

Start by auditing the environment and upstream repository now.
Do not start rewriting the remote desktop engine.