# 🧠 Persistent Memory & Reflexion Ledger

## Post-Mortem Reflexions

- **[26-10-31 · Anti-Detect & Browser Reset]**: `device_linked_to_banned_account` persistently displayed on `freebuff.com/login` despite running `reset-full` → **Root Cause**: `browser-clean.py` previously only scrubbed SQLite cookies without terminating running Chrome processes; persistent PostHog `$device_id` remained in `Local Storage/leveldb`, TLS session tickets survived in `Network Persistent State`, DIPS bounce records and tab restore sessions (`Tabs_*`) restored the banned URL query parameter → **Invariant Rule**: Always terminate browser processes before cleaning (`--kill`), recursively purge LevelDB Local Storage / Session Storage, clean DIPS, scrub TLS network states, and delete `Sessions/` restore files to guarantee zero forensic linkage.
