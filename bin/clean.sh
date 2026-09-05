#!/usr/bin/env bash
# ==============================================================================
# 🛡️ FREEBUFF-POWER SUPREME ANTI-BAN & IDENTITY HARDWARE SPOOFER (DEEP PURGE)
# ==============================================================================
set -euo pipefail

MANICODE_DIR="$HOME/.config/manicode"
mkdir -p "$MANICODE_DIR"

# 1. Kill only zombie freebuff/manicode backend binaries (EXACT process match, NEVER kill self)
pkill -9 -x "freebuff" 2>/dev/null || true
pkill -9 -x "manicode" 2>/dev/null || true
pgrep -f "node.*bin/freebuff" | grep -v "$$" | xargs -r kill -9 2>/dev/null || true

# 2. Hapus seluruh session state, stale sockets, dan temporary locks
rm -f "$MANICODE_DIR"/*.lock 2>/dev/null || true
rm -f "$MANICODE_DIR"/*.sock 2>/dev/null || true
rm -f "$MANICODE_DIR"/session-state*.json 2>/dev/null || true
rm -f "$MANICODE_DIR"/telemetry-queue*.json 2>/dev/null || true
rm -f "$MANICODE_DIR"/device-lock*.json 2>/dev/null || true
rm -f "$MANICODE_DIR"/freebuff-instance-owner.json 2>/dev/null || true

# 3. Generate Hardware & Machine Signature Spoofing (Deep UUIDs & Hashes)
NEW_ANON_ID="$(cat /proc/sys/kernel/random/uuid 2>/dev/null || od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')"
NEW_MACHINE_ID="$(od -vN "16" -An -tx1 /dev/urandom | tr -d " \n")"
NEW_DEVICE_HASH="$(od -vN "32" -An -tx1 /dev/urandom | tr -d " \n")"
NEW_SESSION_SALT="$(od -vN "8" -An -tx1 /dev/urandom | tr -d " \n")"
FAKE_MAC="52:54:00:$(printf '%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))"

# 4. Tulis file konfigurasi identitas baru (Zero Tracking Profile)
cat << STATE_EOF > "$MANICODE_DIR/anonymous-id.json"
{
  "anonymousId": "$NEW_ANON_ID",
  "machineId": "$NEW_MACHINE_ID",
  "deviceHash": "$NEW_DEVICE_HASH",
  "virtualMac": "$FAKE_MAC",
  "salt": "$NEW_SESSION_SALT",
  "spoofedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "telemetryEnabled": false,
  "crashReporting": false,
  "analyticsOptOut": true
}
STATE_EOF
chmod 600 "$MANICODE_DIR/anonymous-id.json" 2>/dev/null || true

# Update analytics-id.json (Crucial for Freebuff binary hardware mapping)
echo "{\"anonymousId\": \"anon_$NEW_ANON_ID\", \"deviceHash\": \"$NEW_DEVICE_HASH\"}" > "$MANICODE_DIR/analytics-id.json"
chmod 600 "$MANICODE_DIR/analytics-id.json" 2>/dev/null || true

# 5. Jika credentials.json ada, sinkronkan hardware fingerprint & tracking flags
if [ -f "$MANICODE_DIR/credentials.json" ]; then
  node -e "
    const fs = require('fs');
    const path = '$MANICODE_DIR/credentials.json';
    try {
      const data = JSON.parse(fs.readFileSync(path, 'utf8'));
      data.deviceHash = '$NEW_DEVICE_HASH';
      data.machineId = '$NEW_MACHINE_ID';
      data.anonymousId = '$NEW_ANON_ID';
      data.telemetryOptOut = true;
      data.lastSessionReset = '$(date -u +"%Y-%m-%dT%H:%M:%SZ")';
      if (data.default) {
        data.default.deviceHash = '$NEW_DEVICE_HASH';
        data.default.machineId = '$NEW_MACHINE_ID';
        data.default.anonymousId = '$NEW_ANON_ID';
      }
      fs.writeFileSync(path, JSON.stringify(data, null, 2));
    } catch(e) {}
  " >/dev/null 2>&1 || true
fi

# 6. Bersihkan temporary files di /tmp
rm -rf /tmp/manicode-* /tmp/codebuff-* /tmp/freebuff-* 2>/dev/null || true

echo -e "\033[0;32m✅ Identitas perangkat, machine ID & analytics fingerprint berhasil disegarkan secara independen!\033[0m"
