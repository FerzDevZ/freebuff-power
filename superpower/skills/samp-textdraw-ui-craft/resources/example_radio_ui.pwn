/* Compile gate example: modern radio/phone TextDraw UI
 * Build: pawncc example_radio_ui.pwn -i<includes> -i. -d3 -o/tmp/radio.amx
 * Must compile with zero warnings on both open.mp and legacy targets. */

#include <open.mp>
#include "samp_td_kit.inc"

/* ---------- Radio UI state ---------- */

#define RADIO_SIGNAL_BARS   (3)
#define RADIO_TOTAL_TD      (14)   /* frame 6 + signal 3 + text 2 + buttons 2 + close 1 */

new PlayerText:gRadioFrame[6];   /* rounded card */
new PlayerText:gRadioSignal[RADIO_SIGNAL_BARS];
new PlayerText:gRadioTitle;
new PlayerText:gRadioFreq;
new PlayerText:gRadioPower;
new PlayerText:gRadioRefresh;
new PlayerText:gRadioClose;

static gRadioOpen[MAX_PLAYERS];

/* ---------- Lifecycle ---------- */

stock RadioUI_Open(playerid)
{
    if (gRadioOpen[playerid])
        return 0;

    new remaining;
    if (!TD_HasBudget(playerid, RADIO_TOTAL_TD, remaining))
    {
        SendClientMessage(playerid, TD_C_DANGER, "UI budget habis");
        return 0;
    }

    /* Frame: rounded card 180x120 at x=230, y=180 */
    TD_RoundedCard(playerid, gRadioFrame, 230.0, 180.0, 180.0, 120.0, 6.0, TD_C_SURFACE);

    /* Signal bars: 3 vertical bars, increasing height */
    gRadioSignal[0] = TD_Sprite(playerid, 245.0, 200.0, 4.0,  8.0,  "LD_BUM:blkdot", TD_C_OK);
    gRadioSignal[1] = TD_Sprite(playerid, 252.0, 196.0, 4.0, 12.0, "LD_BUM:blkdot", TD_C_OK);
    gRadioSignal[2] = TD_Sprite(playerid, 259.0, 192.0, 4.0, 16.0, "LD_BUM:blkdot", TD_C_OK);

    /* Title + frequency */
    gRadioTitle = TD_Text(playerid, 280.0, 192.0, "Central", TD_C_TEXT, 0.22, 1.00);
    gRadioFreq  = TD_Text(playerid, 280.0, 208.0, "FREQ: 911", TD_C_TEXT_DIM, 0.18, 0.80);

    /* Power + refresh buttons */
    gRadioPower   = TD_Sprite(playerid, 245.0, 260.0, 24.0, 24.0, "LD_BEAT:chit", TD_C_DANGER, true);
    gRadioRefresh = TD_Sprite(playerid, 275.0, 260.0, 24.0, 24.0, "LD_BEAT:chit", TD_C_INFO, true);

    /* Close button */
    gRadioClose = TD_Sprite(playerid, 390.0, 185.0, 16.0, 16.0, "LD_BEAT:cross", TD_C_TEXT_DIM, true);

    SelectTextDraw(playerid, TD_C_INFO);
    gRadioOpen[playerid] = 1;
    return 1;
}

stock RadioUI_Close(playerid)
{
    if (!gRadioOpen[playerid])
        return 0;

    TD_DestroyAll(playerid, gRadioFrame, 6);
    for (new i = 0; i < RADIO_SIGNAL_BARS; i++)
        TD_Destroy(playerid, gRadioSignal[i]);
    TD_Destroy(playerid, gRadioTitle);
    TD_Destroy(playerid, gRadioFreq);
    TD_Destroy(playerid, gRadioPower);
    TD_Destroy(playerid, gRadioRefresh);
    TD_Destroy(playerid, gRadioClose);

    CancelSelectTextDraw(playerid);
    gRadioOpen[playerid] = 0;
    return 1;
}

stock RadioUI_SetSignal(playerid, level)
{
    if (!gRadioOpen[playerid])
        return 0;
    for (new i = 0; i < RADIO_SIGNAL_BARS; i++)
    {
        if (i < level)
            TD_SetColor(playerid, gRadioSignal[i], TD_C_OK);
        else
            TD_SetColor(playerid, gRadioSignal[i], TD_C_TEXT_MUTED);
        PlayerTextDrawShow(playerid, gRadioSignal[i]);
    }
    return 1;
}

/* ---------- Hooks ---------- */

public OnPlayerConnect(playerid)
{
    gRadioOpen[playerid] = 0;
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason
    RadioUI_Close(playerid);
    return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if (!gRadioOpen[playerid])
        return 1;

    if (playertextid == gRadioClose)
        RadioUI_Close(playerid);
    else if (playertextid == gRadioPower)
        SendClientMessage(playerid, TD_C_WARN, "Radio powered off");
    else if (playertextid == gRadioRefresh)
        RadioUI_SetSignal(playerid, 2);

    return 1;
}

/* Preview mirror for bin/samp-td-preview.js */
#if defined TD_PREVIEW_MIRROR

new PlayerText:pvRadioFrame;
new PlayerText:pvRadioTitle;

public OnGameModeInit()
{
    pvRadioFrame = CreatePlayerTextDraw(0, 230.0, 180.0, "LD_SPAC:white");
    PlayerTextDrawFont(0, pvRadioFrame, TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawTextSize(0, pvRadioFrame, 180.0, 120.0);
    PlayerTextDrawColor(0, pvRadioFrame, TD_C_SURFACE);

    pvRadioTitle = CreatePlayerTextDraw(0, 280.0, 192.0, "Central");
    PlayerTextDrawAlignment(0, pvRadioTitle, TEXT_DRAW_ALIGN_LEFT);
    PlayerTextDrawLetterSize(0, pvRadioTitle, 0.22, 1.00);
    PlayerTextDrawColor(0, pvRadioTitle, TD_C_TEXT);
    PlayerTextDrawBackgroundColor(0, pvRadioTitle, TD_C_TRANSPARENT);
    return 1;
}

#endif