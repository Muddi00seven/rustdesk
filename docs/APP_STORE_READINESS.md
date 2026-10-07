# Distribution readiness audit

Audited against the current repository on 2026-10-07. Development builds only; no submission, account changes, distribution signing or App Store eligibility claim.

| Area | Current finding / required follow-up |
| --- | --- |
| Bundle isolation | Controller `io.github.muddi00seven.macpilot.controller`; host `io.github.muddi00seven.macpilot.host`, centrally generated. Ownership/provisioning by the user's team unverified |
| Signing | No valid signing identities discovered. iOS archive unsigned; Mac local bundle ad-hoc signed. Distribution identity, provisioning and notarization pending |
| Privacy manifests | No app-owned `PrivacyInfo.xcprivacy` found in source. Inventory app/dependency required-reason APIs and archived dependency manifests before declaring collection or tracking practices |
| Purpose strings | iOS inherits QR camera/photo strings. No app-owned local-network purpose string found. Host permission UX remains upstream. Audit actual requested APIs and add accurate product descriptions at the relevant milestone |
| iOS entitlements | Inherited development push and Wi-Fi information entitlements. Justification/team capability support not verified; do not treat inherited entries as granted capabilities |
| macOS entitlements | Inherited sandbox=false and JIT/audio/network entries. Existing service installer/privilege design requires distribution review; current local host is not a Mac App Store package |
| Background | No new background mode added. Continuous remote control while suspended is not implemented or claimed |
| Encryption | Inherited `ITSAppUsesNonExemptEncryption=false`. Validate the final cryptography/dependency configuration and applicable declaration rather than assuming upstream's value is sufficient |
| Metadata | Development icons/names and controller launch artwork present; Advanced/host strings still upstream. Support/privacy URLs unset; privacy policy and accurate store metadata pending |
| Physical testing | Signed iPad launch, long session, input, permission, privacy and reconnect workflows pending |
| Open source | AGPL, attribution and upstream notices preserved. Review distribution obligations with the final shipping architecture; see `OPEN_SOURCE_COMPLIANCE.md` |

Apple distinguishes generic host mirroring from remote clients mirroring specific software/services in guideline 4.2.7. Maintain the generic remote-Mac scope and review the final product against the complete applicable guidelines; this distinction does not guarantee approval. Background modes must match their intended purpose. Mac App Store sandbox/install requirements need a separate host distribution design. [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

Inventory archived privacy manifests and actual data flows before completing labels. Audit local-network access on a physical iPad with permission allowed and denied. [Apple privacy manifest documentation](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [local-network purpose string](https://developer.apple.com/documentation/bundleresources/information-property-list/nslocalnetworkusagedescription)
