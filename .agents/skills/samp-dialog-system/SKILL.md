---
name: samp-dialog-system
description: SA-MP & open.mp Dialog Architecture — ShowPlayerDialog styles (MSGBOX, INPUT, LIST, PASSWORD, TABLIST, TABLIST_HEADERS), safeDialog exploit prevention, OnDialogResponse state machine patterns, and form validation.
---

# SA-MP / open.mp Dialog System Skill

## Overview
Dialogs are the primary interactive UI elements in SA-MP and open.mp without client modification.

## Dialog Styles
| Constant | Style | Best Used For |
|---|---|---|
| `DIALOG_STYLE_MSGBOX` (0) | Simple modal box with title, message, and 2 buttons | Alerts, confirmations, rules |
| `DIALOG_STYLE_INPUT` (1) | Text input field | Registration, withdrawal amounts, reports |
| `DIALOG_STYLE_LIST` (2) | Selectable item list | Menus, job selection, teleports |
| `DIALOG_STYLE_PASSWORD` (3) | Masked text input field | Login passwords, PIN codes |
| `DIALOG_STYLE_TABLIST` (4) | Columns separated by `\t` | Structured tables, inventory |
| `DIALOG_STYLE_TABLIST_HEADERS` (5) | Tablist with locked header row | Leaderboards, dynamic car dealerships |

## Dialog IDs Definition
Centralize dialog IDs in an enumerator or defined constants to avoid collision:
```pawn
// constants/dialogs.inc
enum {
    DIALOG_NONE = 0,
    DIALOG_AUTH_REGISTER,
    DIALOG_AUTH_LOGIN,
    DIALOG_BANK_MENU,
    DIALOG_BANK_WITHDRAW,
    DIALOG_BANK_DEPOSIT,
    DIALOG_INVENTORY,
    DIALOG_HELP_MENU
};
```

## Anti-Exploit Security (`safeDialog`)
Vulnerabilities in naive dialog handling:
1. **Dialog Spoofing / Packet Injection:** Malicious clients can send fake `OnDialogResponse` RPCs with arbitrary `dialogid` and response values without opening the dialog.
2. **Crash on Long String Injection:** Unescaped strings in format string bugs.

### Secure Dialog State Tracking Pattern
```pawn
new gActivePlayerDialog[MAX_PLAYERS];

stock ShowSecureDialog(playerid, dialogid, style, const caption[], const info[], const button1[], const button2[]) {
    gActivePlayerDialog[playerid] = dialogid;
    return ShowPlayerDialog(playerid, dialogid, style, caption, info, button1, button2);
}

// In OnPlayerConnect
public OnPlayerConnect(playerid) {
    gActivePlayerDialog[playerid] = DIALOG_NONE;
    return 1;
}

// In OnDialogResponse
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    // 1. Packet spoofing check: Was this dialog actually shown by the server?
    if (gActivePlayerDialog[playerid] != dialogid) {
        printf("[SECURITY] Player %d attempted dialog spoofing (dialog: %d, expected: %d).",
            playerid, dialogid, gActivePlayerDialog[playerid]);
        return 0; // Drop packet
    }
    
    // Reset active dialog
    gActivePlayerDialog[playerid] = DIALOG_NONE;

    switch (dialogid) {
        case DIALOG_AUTH_REGISTER: {
            if (!response) {
                SendClientMessage(playerid, 0xFF0000FF, "Anda harus mendaftar untuk bermain.");
                Kick(playerid);
                return 1;
            }
            if (strlen(inputtext) < 6 || strlen(inputtext) > 32) {
                SendClientMessage(playerid, 0xFF0000FF, "[ERROR] Password harus antara 6 - 32 karakter!");
                ShowSecureDialog(playerid, DIALOG_AUTH_REGISTER, DIALOG_STYLE_PASSWORD,
                    "Registrasi Akun", "Masukkan password baru (6-32 karakter):", "Daftar", "Keluar");
                return 1;
            }
            // Proceed to hashing & database insert
            Auth_RegisterAccount(playerid, inputtext);
            return 1;
        }

        case DIALOG_BANK_MENU: {
            if (!response) return 1; // User closed dialog
            switch (listitem) {
                case 0: ShowSecureDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "Bank", "Jumlah setor:", "Setor", "Batal");
                case 1: ShowSecureDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT, "Bank", "Jumlah tarik:", "Tarik", "Batal");
            }
            return 1;
        }
    }
    return 0;
}
```

## TABLIST_HEADERS Example (Dynamic Car Dealership)
```pawn
stock ShowDealershipMenu(playerid) {
    new dialogContent[512];
    format(dialogContent, sizeof(dialogContent),
        "Kendaraan\tHarga\tKecepatan\n\
        Infernus\t$150,000\t220 km/h\n\
        Turismo\t$120,000\t200 km/h\n\
        Sultan\t$65,000\t170 km/h\n\
        Elegy\t$55,000\t165 km/h"
    );
    ShowSecureDialog(playerid, DIALOG_DEALERSHIP, DIALOG_STYLE_TABLIST_HEADERS,
        "Dealer Kendaraan Mewah", dialogContent, "Beli", "Batal");
}
```

## Form Input Validation Checklist
- Check `strlen(inputtext)` against min/max bounds.
- Validate integer fields with `strval(inputtext)` and ensure `val > 0`.
- Strip unwanted characters (e.g. `%`, control characters) if rendering into client messages.
- Always check `!response` (user clicked cancel or pressed ESC) before accessing `inputtext`.
