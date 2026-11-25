/* HUD overlay — health / armor / money / wanted
 *
 * Official example for samp-textdraw-ui-craft: 16 PlayerTD following the
 * FiveM-style blueprint (health/armor bars, money, wanted stars, labels).
 * Proven on open.mp and legacy 0.3.7 with 0 warnings; see bin/self-test.sh.
 *
 * Define TD_PREVIEW_MIRROR before compiling to emit the literal
 * CreatePlayerTextDraw calls that bin/samp-td-preview.js renders.
 */

#include <open.mp>
#include "samp_td_kit.inc"

#define HUD_TOTAL_TD        (16)
#define HUD_UPDATE_MS       (250)
#define HUD_STAR_COUNT      (6)

new PlayerText:gHudHealthTrack;
new PlayerText:gHudHealthFill;
new PlayerText:gHudArmorTrack;
new PlayerText:gHudArmorFill;
new PlayerText:gHudHealthValue;
new PlayerText:gHudArmorValue;
new PlayerText:gHudMoney;
new PlayerText:gHudStars[HUD_STAR_COUNT];
new PlayerText:gHudHealthLabel;
new PlayerText:gHudArmorLabel;
new PlayerText:gHudDivider;

static bool:gHudShown[MAX_PLAYERS];
static gHudWanted[MAX_PLAYERS];
static gHudTimer[MAX_PLAYERS];

forward Hud_Tick(playerid);

stock PlayerText:Hud_Number(playerid, Float:x, Float:y, const text[], color, Float:letterW, Float:letterH)
{
	new PlayerText:td = TD_Text(playerid, x, y, text, color, letterW, letterH);
	PlayerTextDrawFont(playerid, td, TEXT_DRAW_FONT_2);
	PlayerTextDrawShow(playerid, td);
	return td;
}

stock bool:Hud_Show(playerid)
{
	if (gHudShown[playerid])
		return false;

	new remaining;
	if (!TD_HasBudget(playerid, HUD_TOTAL_TD, remaining))
		return false;

	TD_Bar(playerid, gHudHealthTrack, gHudHealthFill, 20.0, 440.0, 120.0, 6.0, TD_C_ELEVATED, TD_C_DANGER);
	TD_Bar(playerid, gHudArmorTrack, gHudArmorFill, 20.0, 428.0, 120.0, 6.0, TD_C_ELEVATED, TD_C_INFO);

	gHudHealthValue = Hud_Number(playerid, 146.0, 436.0, "100", TD_C_TEXT, 0.18, 0.85);
	gHudArmorValue  = Hud_Number(playerid, 146.0, 424.0, "0", TD_C_TEXT, 0.18, 0.85);

	gHudMoney = Hud_Number(playerid, 20.0, 390.0, "$0", TD_C_OK, 0.26, 1.15);

	for (new i = 0; i < HUD_STAR_COUNT; i++)
		gHudStars[i] = TD_Sprite(playerid, 20.0 + (i * 14.0), 410.0, 12.0, 12.0, "LD_SPAC:white", TD_C_TEXT_MUTED);

	gHudHealthLabel = TD_Text(playerid, 20.0, 448.0, "HEALTH", TD_C_TEXT_MUTED, 0.14, 0.60);
	gHudArmorLabel  = TD_Text(playerid, 75.0, 448.0, "ARMOR", TD_C_TEXT_MUTED, 0.14, 0.60);
	gHudDivider     = TD_Sprite(playerid, 150.0, 390.0, 1.0, 56.0, "LD_SPAC:white", TD_C_HAIRLINE);

	gHudShown[playerid] = true;
	gHudWanted[playerid] = 0;
	gHudTimer[playerid] = SetTimerEx("Hud_Tick", HUD_UPDATE_MS, true, "i", playerid);
	return true;
}

stock Hud_Hide(playerid)
{
	if (!gHudShown[playerid])
		return 0;

	if (gHudTimer[playerid] != -1)
	{
		KillTimer(gHudTimer[playerid]);
		gHudTimer[playerid] = -1;
	}

	TD_Destroy(playerid, gHudHealthTrack);
	TD_Destroy(playerid, gHudHealthFill);
	TD_Destroy(playerid, gHudArmorTrack);
	TD_Destroy(playerid, gHudArmorFill);
	TD_Destroy(playerid, gHudHealthValue);
	TD_Destroy(playerid, gHudArmorValue);
	TD_Destroy(playerid, gHudMoney);
	for (new i = 0; i < HUD_STAR_COUNT; i++)
		TD_Destroy(playerid, gHudStars[i]);
	TD_Destroy(playerid, gHudHealthLabel);
	TD_Destroy(playerid, gHudArmorLabel);
	TD_Destroy(playerid, gHudDivider);

	gHudShown[playerid] = false;
	return 1;
}

public Hud_Tick(playerid)
{
	if (!gHudShown[playerid])
	{
		if (gHudTimer[playerid] != -1)
		{
			KillTimer(gHudTimer[playerid]);
			gHudTimer[playerid] = -1;
		}
		return 0;
	}
	return 1;
}

public OnGameModeInit()
{
#if defined TD_PREVIEW_MIRROR
	new PlayerText:pv;

	pv = CreatePlayerTextDraw(0, 20.0, 440.0, "LD_SPAC:white");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawTextSize(0, pv, 120.0, 6.0);
	PlayerTextDrawColor(0, pv, TD_C_ELEVATED);

	pv = CreatePlayerTextDraw(0, 20.0, 440.0, "LD_SPAC:white");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawTextSize(0, pv, 84.0, 6.0);
	PlayerTextDrawColor(0, pv, TD_C_DANGER);

	pv = CreatePlayerTextDraw(0, 20.0, 428.0, "LD_SPAC:white");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawTextSize(0, pv, 120.0, 6.0);
	PlayerTextDrawColor(0, pv, TD_C_ELEVATED);

	pv = CreatePlayerTextDraw(0, 20.0, 428.0, "LD_SPAC:white");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawTextSize(0, pv, 48.0, 6.0);
	PlayerTextDrawColor(0, pv, TD_C_INFO);

	pv = CreatePlayerTextDraw(0, 146.0, 436.0, "84");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_2);
	PlayerTextDrawAlignment(0, pv, TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawLetterSize(0, pv, 0.18, 0.85);
	PlayerTextDrawColor(0, pv, TD_C_TEXT);
	PlayerTextDrawBackgroundColor(0, pv, TD_C_TRANSPARENT);

	pv = CreatePlayerTextDraw(0, 146.0, 424.0, "40");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_2);
	PlayerTextDrawAlignment(0, pv, TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawLetterSize(0, pv, 0.18, 0.85);
	PlayerTextDrawColor(0, pv, TD_C_TEXT);
	PlayerTextDrawBackgroundColor(0, pv, TD_C_TRANSPARENT);

	pv = CreatePlayerTextDraw(0, 20.0, 390.0, "$12450");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_2);
	PlayerTextDrawAlignment(0, pv, TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawLetterSize(0, pv, 0.26, 1.15);
	PlayerTextDrawColor(0, pv, TD_C_OK);
	PlayerTextDrawBackgroundColor(0, pv, TD_C_TRANSPARENT);

	for (new i = 0; i < 6; i++)
	{
		pv = CreatePlayerTextDraw(0, 20.0 + (i * 14.0), 410.0, "LD_SPAC:white");
		PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_SPRITE_DRAW);
		PlayerTextDrawTextSize(0, pv, 12.0, 12.0);
		PlayerTextDrawColor(0, pv, (i < 3) ? TD_C_WARN : TD_C_TEXT_MUTED);
	}

	pv = CreatePlayerTextDraw(0, 20.0, 448.0, "HEALTH");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_1);
	PlayerTextDrawLetterSize(0, pv, 0.14, 0.60);
	PlayerTextDrawColor(0, pv, TD_C_TEXT_MUTED);
	PlayerTextDrawBackgroundColor(0, pv, TD_C_TRANSPARENT);

	pv = CreatePlayerTextDraw(0, 75.0, 448.0, "ARMOR");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_1);
	PlayerTextDrawLetterSize(0, pv, 0.14, 0.60);
	PlayerTextDrawColor(0, pv, TD_C_TEXT_MUTED);
	PlayerTextDrawBackgroundColor(0, pv, TD_C_TRANSPARENT);

	pv = CreatePlayerTextDraw(0, 150.0, 390.0, "LD_SPAC:white");
	PlayerTextDrawFont(0, pv, TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawTextSize(0, pv, 1.0, 56.0);
	PlayerTextDrawColor(0, pv, TD_C_HAIRLINE);
#endif

	return 1;
}

public OnPlayerConnect(playerid)
{
	gHudShown[playerid] = false;
	gHudWanted[playerid] = 0;
	gHudTimer[playerid] = -1;
	Hud_Show(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	Hud_Hide(playerid);
	return 1;
}

#if defined _INC_open_mp
public OnPlayerDeath(playerid, killerid, WEAPON:reason)
#else
public OnPlayerDeath(playerid, killerid, reason)
#endif
{
	#pragma unused killerid, reason
	Hud_Hide(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	Hud_Show(playerid);
	return 1;
}
