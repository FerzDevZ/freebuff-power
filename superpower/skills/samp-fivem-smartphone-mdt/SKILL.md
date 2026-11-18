---
name: samp-fivem-smartphone-mdt
description: FiveM LB-Phone/iPhone Smartphone + Police MDT/CAD + EMS Medical Architecture for open.mp & SA-MP — sleek phone UI apps (Calls/SMS, M-Banking, Marketplace/Ads, GPS/Garage Tracker, Darkweb), Police MDT (Warrants, BOLO, Plate Lookup, 911 Live Blips, Citations), and EMS Downed/Bleeding/Bodypart Damage/Revive Minigame systems.
---

# FiveM Smartphone, Police MDT & EMS Medical Architecture (open.mp 2026)

Modern 2026 RP servers turn the **Smartphone** into the player's central life hub, **Police MDT** into a real-time tactical command tablet, and **EMS Medical** into dramatic injury roleplay instead of instant hospital respawns.

---

## 1. Modern Smartphone System (LB-Phone / iPhone Style)

### Physical Immersion & Pool Strategy
- Opening phone (`[H]` / `/phone` / Mobile `[PHN]` button) checks `CanPlayerInteract(playerid)`, attaches phone prop (`SetPlayerAttachedObject(playerid, 8, 18867, 6)`), and plays `SPECIAL_ACTION_USECELLPHONE`.
- **UI Layout (`x = 465.0..615.0, y = 135.0..445.0`):** Right-docked sleek bezel (`Global TextDraws`: rounded outer chassis, notch/Dynamic Island, bottom home bar = `0` PlayerTDs!), dynamic app grid & screen content (`<= 75 PlayerTDs`, destroyed cleanly on close!).

### Core 2026 Phone Apps (MySQL-Backed)
| App | Core Features & Schema |
|---|---|
| **Contacts & Messages** | Threaded SMS history (`phone_messages(id, sender_num, target_num, body, created_at, is_read)`), unread badge dot, live voice/text call ringtone (`PlayerPlaySound(20600)`). |
| **M-Banking** | Instant transfer by Bank Account or Phone Number, balance card, last 10 transactions (`bank_logs`), atomic SQL deduction + toast alert to recipient (`+ $15,000 from Alex`). |
| **Marketplace / Ads** | Post vehicles, houses, or items with price & 1-click `Call Seller` / `Set GPS`. Auto-expires after 2 hours. |
| **Garage & GPS** | List all owned vehicles with status (`Parked`, `Out`, `Impounded`), 1-click GPS tracker blip (`SetPlayerCheckpoint`), pay impound fee remotely. |
| **911 Emergency & Taxi/Mech** | Sends structured dispatch ticket with live player XYZ + street zone name directly to **Police MDT**, **EMS**, or **Mechanic Dispatch**! |
| **Darkweb (Encrypted)** | Accessible only with `VPN Chip` / `Burner SIM` item; shows black-market contracts & heist intel (invisible to Police on duty). |

---

## 2. Police MDT (Mobile Data Terminal) & Dispatch CAD

Accessible inside Police cruisers (`IsPoliceVehicle`) or PD HQ via `[Y]` / `/mdt`:

```pawn
enum E_DISPATCH_CALL
{
    bool:callActive,
    callId,
    callType,          // 1 = 911 Citizen, 2 = Store/Bank Alarm, 3 = Shots Fired, 4 = Officer Panic
    callCallerName[24],
    callDesc[96],
    Float:callX, Float:callY, Float:callZ,
    callTimestamp,
    callAssignedOfficerId
};
new gDispatchQueue[MAX_DISPATCH_CALLS][E_DISPATCH_CALL];
```

### Mandatory MDT Modules
1. **Live Dispatch Feed:** Auto-triggers on 911 calls, **Heist Silent Alarms**, and **Officer Panic Button** (`[F4]` -> loud alert SFX + flashing red map icon `SetPlayerMapIcon` for all on-duty officers). 1-click `Respond` sets GPS & notifies other units `Unit #4 Responding`.
2. **Citizen Profile Lookup:** Search by Name or Citizen ID -> shows Mugshot (Font 5 skin preview), Licenses (Driver/Weapon), Active Warrants, Past Arrests, and Fine History.
3. **Vehicle Plate & BOLO Lookup:** Enter license plate (`LS-8821`) -> returns Registered Owner, Vehicle Model, Stolen/BOLO flag, and Impound status.
4. **Citations, Warrants & Jail:** Issue digital fines (deducted from bank or added to unpaid debt with interest), file arrest reports stored in `police_records`, and log evidence serial numbers from `ox_inventory` weapon metadata!

---

## 3. EMS Medical & Downed/Last-Stand System (Zero Instant Respawn)

Replace arcade instant death with FiveM-style **Downed / Last-Stand**:
1. **Localized Bodypart Injury Tracking (`OnPlayerTakeDamage`):**
   - Store injury bitflags (`INJURY_HEAD`, `INJURY_TORSO`, `INJURY_LEFT_ARM`, `INJURY_RIGHT_ARM`, `INJURY_LEGS`) and `bleedingRate`.
   - Leg shots apply limp/stumble; torso/head trauma increases bleeding tick.
2. **Last-Stand State (`PSTATE_LAST_STAND`):**
   - When HP drops `<= 15.0` (or fatal hit intercepted), set `SetPlayerHealth(playerid, 20.0)`, set `PSTATE_LAST_STAND`, apply `"SWEET", "Sweet_injuredloop"`, show sleek bottom-center FiveM bleeding timer (`BLEEDING OUT: 04:32 | [G] Call EMS | Wait for Respawn`).
   - Block inventory/phone/weapons via `CanPlayerInteract(playerid)`.
3. **Interactive EMS Revive:**
   - Medic walks up, uses `ox_target` -> `Inspect Injuries` (shows exact damaged bodyparts + needed `Bandage` / `First Aid Kit` / `Defibrillator`).
   - `Revive Patient` runs `Ox_ProgressBar` (6s CPR anim) + `Ox_SkillCheck` -> restores player safely with hospital bill invoice.
4. **Automatic Hospital Fallback:** If zero EMS are online (or bleedout hits `00:00`), player can hold `[E]` to airlift to Pillbox/All Saints Hospital with fair medical fee (configurable item-loss rule).
