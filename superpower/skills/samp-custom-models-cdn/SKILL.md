---
name: samp-custom-models-cdn
description: Custom Models (Skins, Vehicles, Objects) & FastDL HTTP CDN Asset Streaming for open.mp and SA-MP 0.3.DL — models/artconfig.txt syntax, AddSimpleModel, AddCharModel, CRC calculation, and Nginx CDN offloading.
---

# SA-MP / open.mp Custom Models & FastDL CDN Skill

## Overview
open.mp natively supports SA-MP 0.3.DL custom artwork streaming, allowing servers to stream custom 3D skins, vehicles, objects, and textdraw textures directly to connecting clients without replacing default GTA SA files.

---

## 1. Server Configuration

### In `config.json` (`open.mp`):
```json
{
  "artwork": {
    "enable": true,
    "models_path": "models"
  }
}
```

### In `server.cfg` (Legacy format):
```ini
useartwork 1
artpath models
```

---

## 2. Directory Layout & File Formats
Place all custom model assets inside the `models/` directory:
```
server/
├── models/
│   ├── artconfig.txt            # Asset registration file
│   ├── skin_police_chief.dff    # 3D Mesh
│   ├── skin_police_chief.txd    # Textures
│   ├── vehicle_lamborghini.dff
│   └── vehicle_lamborghini.txd
```

---

## 3. `models/artconfig.txt` Syntax

### Custom Objects: `AddSimpleModel`
Maps a virtual world, base object model, new virtual model ID, `.dff`, and `.txd` file:
```text
; Syntax: AddSimpleModel(virtual_world, base_model_id, new_model_id, "dff_name", "txd_name")
AddSimpleModel(-1, 19379, -2001, "custom_atm.dff", "custom_atm.txd")
```
- Virtual World `-1`: Available in all virtual worlds.
- Base Model `19379`: Inherits collision/properties from default GTA object.
- New Model ID `-2001`: Must be negative for custom objects.

### Custom Skins (Char Models): `AddCharModel`
Maps a base skin ID to a new virtual skin ID:
```text
; Syntax: AddCharModel(base_skin_id, new_skin_id, "dff_name", "txd_name")
AddCharModel(280, 20001, "police_chief.dff", "police_chief.txd")
AddCharModel(305, 20002, "special_forces.dff", "special_forces.txd")
```
- In Pawn, assign custom skin with `SetPlayerSkin(playerid, 20001);`.

---

## 4. FastDL / HTTP CDN Offloading (Crucial for Bandwidth)
Streaming 50–200MB of custom assets directly over the SA-MP game UDP port causes game tick lag, timeouts, and player disconnects. Always offload downloads to an external Nginx / Cloudflare CDN mirror.

### Pawn Download Redirection Callback:
```pawn
#define CDN_DOWNLOAD_URL "https://assets.myserver.com/models/"

public OnPlayerRequestDownload(playerid, type, crc) {
    if (!IsPlayerConnected(playerid)) return 0;

    new fileName[64], redirectUrl[256];
    
    // Redirect client to fetch file directly via high-speed HTTP/HTTPS
    format(redirectUrl, sizeof(redirectUrl), "%s", CDN_DOWNLOAD_URL);
    RedirectDownload(playerid, redirectUrl);
    return 1;
}
```

### Nginx FastDL Server Block (`/etc/nginx/sites-available/fastdl`):
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name assets.myserver.com;

    root /var/www/samp_models;
    autoindex off;

    # Enable aggressive client caching for .dff and .txd assets
    location ~* \.(dff|txd|col)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
        add_header Access-Control-Allow-Origin *;
        tcp_nopush on;
        sendfile on;
    }
}
```

## Production Verification Checklist
1. Inspect server console on boot: ensure CRC32 hashes are computed without error:
   ```text
   [artwork:crc] police_chief.dff CRC = 0x8F3A2B11
   [artwork:crc] police_chief.txd CRC = 0x1A4C90FF
   ```
2. Verify file case-sensitivity: Linux file systems are strictly case-sensitive.
3. Keep individual `.txd` texture files compressed (DXT1 / DXT5) to prevent client VRAM crashes.

## Runtime (open.mp)

- **open.mp server**: v1.6.7.3218 (latest stable, Oct 2026)
- **pawncc**: 3.10.10+ (open.mp compiler, `-Z` for warnings-as-errors)
- **Streamer Plugin**: v2.9.6+ (Incognito) for dynamic objects/areas/pickups
- **MySQL Plugin**: R41-4 (BlueG) or `mysql` component (open.mp native)
- **YSI 5.x**: y_commands, y_hooks, y_iterate, y_bit, y_inline, y_timers, y_groups
- **ColAndreas**: v1.5.0+ for collision/raycasting
- **SA-MP Legacy**: 0.3.7-R2 / 0.3.DL (backward compat)

### Compile Check (Gate)
```bash
# open.mp
pawncc -i. -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn

# legacy (0.3.7)
pawncc -i. -i/tmp/sampstdlib -i/home/aegisx/samp-sdk/omp-stdlib -d3 -o/tmp/test.amx file.pwn
```
Zero warnings, zero errors required.

