# Migrasi Gamemode SA-MP 0.3.7 → open.mp (End-to-End)

Panduan praktis memindahkan gamemode legacy 0.3.7/0.3.DL ke open.mp tanpa kehilangan perilaku, dengan verifikasi dual-target di setiap langkah.

## 0. Prasyarat

- `pawncc` (open.mp) + stdlib legacy (`/tmp/sampstdlib`) + stdlib open.mp (`$HOME/samp-sdk/omp-stdlib`).
- `bin/ysi-ensure.sh` jika pakai YSI.
- Baca `docs/NATIVE-PARITY.md` sebelum menyentuh native apa pun.

## 1. Deteksi target (audit awal)

```bash
node bin/samp-detect.js gamemode.pwn
node bin/samp-claim-audit.js gamemode.pwn
```

Catat verdict (LEGACY/MODERN/COMPAT/DUAL/MIXED/UNKNOWN). Jangan ubah dulu — ini baseline.

## 2. Checklist perubahan

- [ ] Ganti include: `<a_samp>` → `<open.mp>` (atau guard `#if defined _INC_open_mp`).
- [ ] Branching lintas target untuk native legacy-only / reshaped (lihat `docs/NATIVE-PARITY.md` § "Migrating legacy natives").
- [ ] Pool iteration: hapus `for (new i; i < MAX_PLAYERS; i++)` dan `GetPlayerPoolSize()`; pakai `foreach (new i : Player)` atau `SetTimerEx` per-player.
- [ ] `OnPlayerDeath` third param: branch tag `WEAPON:` (open.mp) vs untagged (0.3.7).
- [ ] DB: `db_query` → `DB_ExecuteQuery`, `db_get_field_*` → `DB_GetField*`, `db_next_row` → `DB_SelectNextRow`.
- [ ] Object editing: `EditObject`/`CancelEdit`/`SelectObject` → `BeginObjectEditing`/`EndObjectEditing`/`BeginObjectSelecting`.
- [ ] YSI: jalankan `bin/ysi-ensure.sh`; include dengan `-i.sdk/ysi -;+`.
- [ ] Hapus shim deprecated (`GetPlayerPoolSize` stock shim → warning 234).
- [ ] Semua `PlayerText:` strict tags (jangan bandingkan dengan `Text:` sentinel).
- [ ] TextDraw: destroy on close/death/disconnect; budget ≤ 200 live.

## 3. Pola branching

```pawn
#if defined _INC_open_mp
    DB_ExecuteQuery(db, query);
#else
    db_query(db, query);
#endif
```

## 4. Verifikasi dual-target (wajib)

```bash
# open.mp
pawncc -i. -i$HOME/samp-sdk/omp-stdlib -d3 -o/tmp/out_omp.amx gamemode.pwn
# legacy
pawncc -i. -i/tmp/sampstdlib -i$HOME/samp-sdk/omp-stdlib -d3 -o/tmp/out_legacy.amx gamemode.pwn
```

Kedua harus 0 warning + `.amx` non-empty. Jalankan juga:

```bash
./bin/self-test.sh
node bin/samp-audit.sh .
node bin/samp-lint.js
```

## 5. Commit contoh

```bash
git add -A
git commit -m "migrate: port gamemode from SA-MP 0.3.7 to open.mp (dual-target)

- swap <a_samp> for <open.mp> with _INC_open_mp guards
- replace GetPlayerPoolSize with foreach (Player)
- migrate db_* to DB_* natives
- YSI via bin/ysi-ensure.sh (0 warning)
- verified: both targets compile, 0 warning, .amx emitted

🤖 Generated with Codebuff
Co-Authored-By: Codebuff <noreply@codebuff.com>"
```

## 6. Gate akhir

- `bin/self-test.sh` all green.
- `bin/samp-detect.js` verdict MODERN atau DUAL (bukan LEGACY).
- Tidak ada legacy hacks tersisa (`OnNPCModeInit`, `GetMyPos`, dsb.).
EOF
echo done