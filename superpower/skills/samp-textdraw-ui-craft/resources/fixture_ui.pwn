/* Compile gate fixture for samp_td_kit.inc
 * Build: pawncc fixture_ui.pwn -i<includes> -i. -d3 -o/tmp/fixture.amx
 * It must compile with zero warnings; anything else means the kit regressed. */

#include <open.mp>
#include "samp_td_kit.inc"

new PlayerText:gCard[6];
new PlayerText:gTrack;
new PlayerText:gFill;
new PlayerText:gLabel;
new PlayerText:gHit;

public OnPlayerConnect(playerid)
{
	new count = TD_RoundedCard(playerid, gCard, 470.0, 20.0, 150.0, 64.0, 6.0, TD_C_SURFACE);
	TD_Bar(playerid, gTrack, gFill, 480.0, 60.0, 130.0, 6.0, TD_C_ELEVATED, TD_C_OK);
	TD_BarSet(playerid, gFill, 480.0, 60.0, 130.0, 6.0, 130.0, 0.42);
	gLabel = TD_Text(playerid, 480.0, 26.0, "GARAGE", TD_C_TEXT, 0.22, 0.95);
	gHit = TD_Sprite(playerid, 596.0, 24.0, 18.0, 18.0, "LD_BEAT:cross", TD_C_TEXT_DIM, true);
	TD_BoxedText(playerid, 480.0, 40.0, 130.0, 14.0, "vehicle stored", TD_C_TEXT_DIM, TD_C_TRANSPARENT);

	new remaining;
	if (!TD_HasBudget(playerid, count + 4, remaining))
		TD_DestroyAll(playerid, gCard, 6);

	if (TD_InTouchDeadZone(470.0, 20.0, 150.0, 64.0))
		TD_Destroy(playerid, gLabel);

	TD_FadeIn(playerid, gLabel, TD_C_TEXT, 60);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	TD_DestroyAll(playerid, gCard, 6);
	TD_Destroy(playerid, gTrack);
	TD_Destroy(playerid, gFill);
	TD_Destroy(playerid, gLabel);
	TD_Destroy(playerid, gHit);
	return 1;
}

/* Preview mirror: bin/samp-td-preview.js only understands INLINE
 * CreatePlayerTextDraw calls, so the same layout is repeated here verbatim.
 * Compiled only when TD_PREVIEW_MIRROR is defined, so it never ships. */
#if defined TD_PREVIEW_MIRROR

new PlayerText:pvCard;
new PlayerText:pvFill;
new PlayerText:pvLabel;
new PlayerText:pvHit;

public OnGameModeInit()
{
	pvCard = CreatePlayerTextDraw(0, 470.0, 20.0, "LD_SPAC:white");
	PlayerTextDrawFont(0, pvCard, TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawTextSize(0, pvCard, 150.0, 64.0);
	PlayerTextDrawColor(0, pvCard, TD_C_SURFACE);

	pvFill = CreatePlayerTextDraw(0, 480.0, 60.0, "LD_SPAC:white");
	PlayerTextDrawFont(0, pvFill, TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawTextSize(0, pvFill, 54.6, 6.0);
	PlayerTextDrawColor(0, pvFill, TD_C_OK);

	pvLabel = CreatePlayerTextDraw(0, 480.0, 26.0, "GARAGE");
	PlayerTextDrawAlignment(0, pvLabel, TEXT_DRAW_ALIGN_LEFT);
	PlayerTextDrawLetterSize(0, pvLabel, 0.22, 0.95);
	PlayerTextDrawColor(0, pvLabel, TD_C_TEXT);
	PlayerTextDrawBackgroundColor(0, pvLabel, TD_C_TRANSPARENT);

	pvHit = CreatePlayerTextDraw(0, 596.0, 24.0, "LD_BEAT:cross");
	PlayerTextDrawFont(0, pvHit, TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawTextSize(0, pvHit, 18.0, 18.0);
	PlayerTextDrawColor(0, pvHit, TD_C_TEXT_DIM);
	PlayerTextDrawSetSelectable(0, pvHit, 1);
	return 1;
}

#endif
