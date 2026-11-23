---
name: mobile-appsec-masvs
description: Mobile application security against OWASP MASVS/MASTG for Android and iOS — secure storage, keychain/keystore, network pinning tradeoffs, exported components and deep links, WebView hardening, secrets in binaries, tamper signals, and privacy data minimisation, including React Native and Flutter specifics.
---

# Mobile app security (MASVS in practice)

Mobile clients are hostile territory: the binary, the storage, and the network are
all reachable by the user. Treat every client check as a speed bump, and every
secret as already published.

## Storage

| Wrong | Right |
|---|---|
| token in `localStorage`/`AsyncStorage`/`SharedPreferences` plain | Keychain (iOS) / EncryptedSharedPreferences + Keystore (Android) |
| API key compiled into the app | key stays on your backend, client sends its own auth token |
| PII cached "for offline" with no expiry | explicit TTL, encrypted at rest, cleared on logout |
| database unencrypted on device | SQLCipher/encrypted Room or platform-encrypted storage |

React Native: `react-native-keychain` or `expo-secure-store`. Flutter:
`flutter_secure_storage`. Both wrap Keychain/Keystore; neither protects against a
fully compromised device.

## Authentication and session

- refresh tokens in secure storage, access tokens short-lived in memory;
- biometrics unlock a key, they do not authenticate the user to your server by
  themselves without a server-verifiable assertion;
- logout must revoke server-side and wipe local caches, not just clear a flag;
- deep link / universal link login callbacks must validate state and PKCE; a
  custom scheme can be claimed by another app.

## Network

- TLS everywhere, including internal staging;
- certificate pinning: useful against user-installed CAs, but plan rotation or you
  brick old app versions — pin a public key and keep a backup pin;
- never disable ATS/cleartext wholesale to fix one endpoint;
- do not log request bodies or auth headers in release builds.

## Platform surface

- Android: audit `android:exported`, intent filters, content providers, and
  `allowBackup`; validate every intent extra as untrusted input;
- iOS: audit URL schemes, `UIActivityViewController` sharing, and keychain
  accessibility classes (`kSecAttrAccessibleAfterFirstUnlock` vs
  `...WhenUnlockedThisDeviceOnly`);
- permissions: request at use, degrade gracefully, never request a permission the
  feature does not use.

## WebView

- allowlist navigation, block `file://` and `javascript:` by default;
- `addJavascriptInterface` (Android) exposes native methods to page JS — only with
  a strict origin check and a minimal API;
- disable debugging in release; sanitize anything injected into the page.

## Tamper and rooting

Root/jailbreak detection, integrity checks, and obfuscation raise cost, they do not
prevent reverse engineering. Never make a security decision (entitlement, payment,
admin) that only the client can observe.

## Privacy

Collect the minimum, disclose it, and delete it on request. Analytics SDKs often
ship identifiers you did not intend; audit third-party SDKs for data collection
and keep a manifest that matches the store listing.

## Verification you can actually run

- `apkanalyzer`/`aapt dump badging` on the release APK: exported components,
  permissions, debuggable flag;
- `strings`/`grep` the release binary for tokens, endpoints, and keys;
- `frida`/objection on a test device to confirm storage is not plaintext;
- proxy with a custom CA to confirm pinning and to prove no auth header leaks;
- a checklist per MASVS category with pass/fail evidence, not a vague "looks secure".

## Limits

- MASVS v2 groups controls differently from v1; cite the version you audit against.
- Pinning and tamper checks are risk tradeoffs, not automatic wins.
- No fixture: results depend on a built artifact and a device/emulator.
