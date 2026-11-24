/* Compile gate example: modern retextured interior (MLO-style)
 * Build: pawncc example_retextured_interior.pwn -i<includes> -i. -d3 -o/tmp/interior.amx
 * Must compile with zero warnings on both open.mp and legacy targets. */

#include <open.mp>
#include <streamer>

/* ---------- Area anchor ---------- */

#define MEDIC_X     (1220.0)
#define MEDIC_Y     (-1350.0)
#define MEDIC_Z     (11.0)
#define MEDIC_WORLD (0)
#define MEDIC_INT   (0)

/* ---------- Texture presets (ARGB: 0xAARRGGBB) ---------- */

#define TEX_WHITE_CONCRETE  0xFFE8E8E8
#define TEX_DARK_MARBLE     0xFF2B313C
#define TEX_WARM_OAK        0xFFD9C2A3
#define TEX_FROSTED_GLASS   0x88CFE8FF
#define TEX_INVISIBLE       0x00000000

/* ---------- Object data table ---------- */

enum E_INTERIOR_OBJ
{
    ioModel,
    Float:ioX, Float:ioY, Float:ioZ,
    Float:ioRX, Float:ioRY, Float:ioRZ,
    ioMaterialIdx,
    ioTxdModel,          /* modelid that owns the TXD */
    ioTextureName[32],
    ioColor
};

/* Base shapes: 18765 = flat plane, 18766 = wall panel, 18981 = ground plane */
static const gInteriorObjs[][E_INTERIOR_OBJ] =
{
    /* Floors (priority structure) */
    {18981, 1220.0, -1370.0, 10.9, 0.0, -90.0, 0.0, 0, 10765, "white", TEX_WHITE_CONCRETE},
    {18981, 1230.0, -1370.0, 10.9, 0.0, -90.0, 0.0, 0, 10765, "white", TEX_WHITE_CONCRETE},
    {18981, 1220.0, -1360.0, 10.9, 0.0, -90.0, 0.0, 0, 10765, "white", TEX_WHITE_CONCRETE},
    {18981, 1230.0, -1360.0, 10.9, 0.0, -90.0, 0.0, 0, 10765, "white", TEX_WHITE_CONCRETE},
    /* Walls (priority structure) */
    {18766, 1210.5, -1370.0, 14.5, -90.0, 0.0, 0.0, 0, 16640, "plaintarmac1", TEX_DARK_MARBLE},
    {18766, 1240.5, -1370.0, 14.5, -90.0, 0.0, 0.0, 0, 16640, "plaintarmac1", TEX_DARK_MARBLE},
    /* Glass partition (frosted) */
    {18765, 1225.0, -1355.0, 15.0, 0.0, 0.0, 45.0, 0, 1649, "glass01", TEX_FROSTED_GLASS},
    /* Hidden part (invisible texture) */
    {18766, 1215.0, -1365.0, 12.0, 0.0, -90.0, 0.0, 0, 19297, "invisible", TEX_INVISIBLE}
};

/* ---------- Streaming priority ---------- */

#define MAP_PRIO_STRUCTURE   (10)

/* ---------- Build functions ---------- */

stock MedicInterior_Build()
{
    new STREAMER_TAG_OBJECT:obj;
    for (new i = 0; i < sizeof(gInteriorObjs); i++)
    {
        obj = CreateDynamicObject(
            gInteriorObjs[i][ioModel],
            gInteriorObjs[i][ioX],
            gInteriorObjs[i][ioY],
            gInteriorObjs[i][ioZ],
            gInteriorObjs[i][ioRX],
            gInteriorObjs[i][ioRY],
            gInteriorObjs[i][ioRZ],
            MEDIC_WORLD, MEDIC_INT, -1,
            250.0, 250.0, -1, MAP_PRIO_STRUCTURE
        );
        SetDynamicObjectMaterial(
            obj,
            gInteriorObjs[i][ioMaterialIdx],
            gInteriorObjs[i][ioTxdModel],
            gInteriorObjs[i][ioTextureName],
            gInteriorObjs[i][ioColor]
        );
    }
    return 1;
}

stock MedicInterior_RemoveBuildings(playerid)
{
    /* Remove vanilla GTA buildings in the area */
    RemoveBuildingForPlayer(playerid, 620, 1222.660, -1374.609, 12.296, 0.250);
    RemoveBuildingForPlayer(playerid, 620, 1240.920, -1374.609, 12.296, 0.250);
    RemoveBuildingForPlayer(playerid, 620, 1240.920, -1356.550, 12.296, 0.250);
    RemoveBuildingForPlayer(playerid, 620, 1222.660, -1356.550, 12.296, 0.250);
    RemoveBuildingForPlayer(playerid, 739, 1231.140, -1341.849, 12.734, 0.250);
    RemoveBuildingForPlayer(playerid, 5812, 1230.890, -1337.979, 12.539, 0.250);
    return 1;
}

stock MedicInterior_TeleportPlayer(playerid)
{
    /* Anti-fall-through: stream floors before gravity applies */
    SetPlayerVirtualWorld(playerid, MEDIC_WORLD);
    SetPlayerInterior(playerid, MEDIC_INT);
    Streamer_UpdateEx(playerid, MEDIC_X, MEDIC_Y, MEDIC_Z, MEDIC_WORLD, MEDIC_INT, STREAMER_TYPE_OBJECT, 600, 1);
    SetPlayerPos(playerid, MEDIC_X, MEDIC_Y, MEDIC_Z + 0.15);
    SetPlayerFacingAngle(playerid, 0.0);
    SetCameraBehindPlayer(playerid);
    return 1;
}

/* ---------- Hooks ---------- */

public OnGameModeInit()
{
    MedicInterior_Build();
    return 1;
}

public OnPlayerConnect(playerid)
{
    MedicInterior_RemoveBuildings(playerid);
    return 1;
}

/* ---------- Preview (no preview mirror needed for mapping) ---------- */