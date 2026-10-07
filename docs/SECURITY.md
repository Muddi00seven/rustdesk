# Security Policy

## Reporting a Vulnerability

We value security for the project very highly. We encourage all users to report any vulnerabilities they discover to us.
If you find a security vulnerability in the RustDesk project, please report it responsibly by sending an email to info@rustdesk.com.

At this juncture, we don't have a bug bounty program. We are a small team trying to solve a big problem. We urge you to report any vulnerabilities responsibly
so that we can continue building a secure application for the entire community.

---

## MacPilot security boundary and pending verification

The reporting policy above is retained from upstream. The following records the fork's development security boundary.

Status: milestone 1 adds dashboard metadata only. This document records intended controls and current gaps; it is not an independent security audit or a claim of production readiness.

## Current data boundary

`MacDeviceProfile` whitelists connection identifier, friendly name, favorite and last connection-attempt timestamp. It never serializes a full upstream Peer object, password, password hash, pairing key, clipboard, remote frame, field value or keystroke. Dashboard preferences are not secret storage. Technical info is an explicit local dialog limited to identifier/availability/LAN presence. No diagnostics export or telemetry was added.

Existing upstream authentication and encrypted session transport remain in place. New UI code calls existing connection entry points and does not authorize a session. The upstream host configuration and remembered-authentication storage require an explicit Keychain/lifecycle audit before milestone 7 adds trust persistence. Existing encrypted config machinery must not be described as a completed MacPilot Keychain implementation.

## Threat model and acceptance work

| Threat | Required control / current verification |
| --- | --- |
| Stolen iPad or copied preferences | Dashboard contains no new credentials. Future remembered secrets require appropriate Keychain access policy, host-visible trust and remote revocation; pending |
| Malicious rendezvous/relay or MITM | Preserve encryption and server public-key checking; reject changed identity rather than automatically trusting it. Self-hosted wrong-key tests pending |
| Password guessing / replay | Preserve existing authentication deadlines and failure controls. Audit both remote-session and OS-login paths separately; pending |
| Malicious pairing / stale trust | Pairing must be explicit and host visible, bound to device identity and revocable. No new pairing flow implemented |
| Network loss or stale connection | No input replay. Future reconnect must gate outbound input to a current authenticated connection; pending fault-injection tests |
| Sensitive remote fields | Planned AX monitor transmits metadata classifications only, never AXValue/selected text. Secure contexts suppress smart features; not implemented |
| Clipboard / diagnostics leakage | Planned clipboard Off/Ask policy and redacted export require physical consent tests. Upstream clipboard behavior is unchanged |
| Local service misuse | No new service installation/login item. Audit privilege, helper identity, consent and session indicators before unattended access |

## Implementation rules

Keep private keys, authentication tokens and passwords out of Flutter preferences, diagnostic exports, screenshots and logs. Store future secret material through a feature-owned Keychain boundary; handle denial, revocation, migration and failed writes explicitly. Prefer host-authorized sessions with visible connection state. A removed dashboard card only removes its local profile; it does not revoke existing host access.

The proposed smart keyboard must classify role/subrole, focused/editable/settable/multiline/secure capabilities with AXObserver events. It must not read field contents, clipboard, selected text or record typed characters. Observe only for authenticated eligible sessions and tear down observers on termination. These are implementation acceptance requirements, not current behavior.

Before distribution, inspect upstream logs, crash artifacts, dependencies, remembered credentials and authentication limits; test permission removal, server-key changes and revoked trust on physical devices. Do not publish local build logs without reviewing identifiers and machine paths.
