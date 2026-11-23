# Native parity: SA-MP 0.3.7 vs open.mp

Generated from `/tmp/sampstdlib` and `/home/aegisx/samp-sdk/omp-stdlib`.

| | Legacy 0.3.7 | open.mp |
|---|---|---|
| Natives | 512 | 1044 |
| Shared | 463 | 463 |
| Only in this target | 49 | 485 |
| Unverifiable (module absent from legacy copy) | — | 96 |
| Shared but reshaped | 330 | 330 |

## open.mp only — will not compile on 0.3.7

- `bool:AddServerRule(const rule[], const format[], OPEN_MP_TAGS:...)`
- `void:AllowNickNameCharacter(character, bool:allow)`
- `bool:AllowPlayerWeapons(playerid, bool:allow)`
- `bool:AreAllAnimationsEnabled()`
- `bool:AreInteriorWeaponsAllowed()`
- `bool:ArePlayerWeaponsAllowed(playerid)`
- `bool:AttachPlayerObjectToObject(playerid, objectid, parentid, Float:offsetX, Float:offsetY, Float:offsetZ, Float:rotationX, Float:rotationY, Float:rotationZ, bool:syncRotation = true)`
- `bool:BeginObjectEditing(playerid, objectid)`
- `bool:BeginObjectSelecting(playerid)`
- `bool:BeginPlayerObjectEditing(playerid, objectid)`
- ` CarColIndexToColour(index, alpha = 0xFF)`
- `bool:ChatTextReplacementToggled()`
- `bool:ClearBanList()`
- `bool:ClearPlayerWorldBounds(playerid)`
- ` CountRunningTimers()`
- ` CountVehicleOccupants(vehicleid)`
- ` CreatePlayerGangZone(playerid, Float:minx, Float:miny, Float:maxx, Float:maxy)`
- ` CreatePlayerPickup(playerid, model, type, Float:x, Float:y, Float:z, virtualWorld = 0)`
- `bool:DB_Close(DB:db)`
- `DBResult:DB_ExecuteQuery(DB:db, const query[], OPEN_MP_TAGS:...)`
- `bool:DB_FreeResultSet(DBResult:result)`
- ` DB_GetDatabaseConnectionCount()`
- ` DB_GetDatabaseResultSetCount()`
- ` DB_GetFieldCount(DBResult:result)`
- `Float:DB_GetFieldFloat(DBResult:result, field = 0)`
- `Float:DB_GetFieldFloatByName(DBResult:result, const field[])`
- ` DB_GetFieldInt(DBResult:result, field = 0)`
- ` DB_GetFieldIntByName(DBResult:result, const field[])`
- `bool:DB_GetFieldName(DBResult:result, field, output[], size = sizeof (output))`
- `bool:DB_GetFieldString(DBResult:result, field, output[], size = sizeof (output))`
- `bool:DB_GetFieldStringByName(DBResult:result, const field[], output[], size = sizeof (output))`
- ` DB_GetLegacyDBResult(DBResult:result)`
- ` DB_GetMemHandle(DB:db)`
- ` DB_GetRowCount(DBResult:result)`
- `DB:DB_Open(const name[], SQLITE_OPEN:flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)`
- `bool:DB_SelectNextRow(DBResult:result)`
- `bool:DestroyPlayerPickup(playerid, pickupid)`
- `bool:EditPlayerClass(classid, team, skin, Float:spawnX, Float:spawnY, Float:spawnZ, Float:angle, WEAPON:weapon1 = WEAPON_FIST, ammo1 = 0, WEAPON:weapon2 = WEAPON_FIST, ammo2 = 0, WEAPON:weapon3 = WEAPON_FIST, ammo3 = 0)`
- `void:EnableAllAnimations(bool:enable)`
- `bool:EndObjectEditing(playerid)`
- ` GangZoneGetColourForPlayer(playerid, zoneid)`
- ` GangZoneGetFlashColourForPlayer(playerid, zoneid)`
- `bool:GangZoneGetPos(zoneid, &Float:minX, &Float:minY, &Float:maxX, &Float:maxY)`
- `bool:Get3DTextLabelAttachedData(Text3D:textid, &parentPlayerid, &parentVehicleid)`
- ` Get3DTextLabelColor(Text3D:textid)`
- `Float:Get3DTextLabelDrawDistance(Text3D:textid)`
- `bool:Get3DTextLabelLOS(Text3D:textid)`
- `bool:Get3DTextLabelPos(Text3D:textid, &Float:x, &Float:y, &Float:z)`
- `bool:Get3DTextLabelText(Text3D:textid, text[], len = sizeof (text))`
- ` Get3DTextLabelVirtualWorld(Text3D:textid)`
- `bool:GetActorAnimation(actorid, animationLibrary[], librarySize = sizeof (animationLibrary), animationName[], nameSize = sizeof (animationName), &Float:delta, &bool:loop = false, &bool:lockX = false, &bool:lockY = false, &bool:freeze = false, &time = 0)`
- ` GetActors(actors[], size = sizeof (actors))`
- ` GetActorSkin(actorid)`
- `bool:GetActorSpawnInfo(actorid, &skin, &Float:spawnX = 0.0, &Float:spawnY = 0.0, &Float:spawnZ = 0.0, &Float:spawnAngle = 0.0)`
- ` GetAvailableClasses()`
- `Float:GetConsoleVarAsFloat(const cvar[])`
- `bool:GetCustomModelPath(modelid, dffPath[], dffSize = sizeof (dffPath), txdPath[], txdSize = sizeof (txdPath))`
- ` GetDefaultPlayerColour(playerid)`
- `bool:GetGameText(playerid, style, message[], len = sizeof (message), time, remaining)`
- `bool:GetMenuColumnHeader(Menu:menuid, column, header[], len = sizeof (header))`
- ` GetMenuColumns(Menu:menuid)`
- `bool:GetMenuColumnWidth(Menu:menuid, &Float:column1Width, &Float:column2Width = 0.0)`
- `bool:GetMenuItem(Menu:menuid, column, row, cell[], len = sizeof (cell))`
- ` GetMenuItems(Menu:menuid, column)`
- `bool:GetMenuPos(Menu:menuid, &Float:x, &Float:y)`
- `Float:GetModeRestartTime()`
- `bool:GetObjectAttachedData(objectid, &parentVehicle = 0, &parentObject = 0, &parentPlayer = 0)`
- `bool:GetObjectAttachedOffset(objectid, &Float:offsetX = 0.0, &Float:offsetY = 0.0, &Float:offsetZ = 0.0, &Float:rotationX = 0.0, &Float:rotationY = 0.0, &Float:rotationZ = 0.0)`
- `Float:GetObjectDrawDistance(objectid)`
- `bool:GetObjectMaterial(objectid, materialIndex, &modelid, textureLibrary[], textureLibrarySize = sizeof (textureLibrary), textureName[], textureNameSize = sizeof (textureName), &materialColour = 0)`
- `bool:GetObjectMaterialText(objectid, materialIndex, text[], textSize = sizeof (text), &OBJECT_MATERIAL_SIZE:materialSize, fontFace[], fontFaceSize = sizeof (fontFace), &fontSize = 0, &bool:bold = true, &fontColour = 0xFFFFFFFF, &backgroundColour = 0, &OBJECT_MATERIAL_TEXT_ALIGN:textAlignment = OBJECT_MATERIAL_TEXT_ALIGN_LEFT)`
- `Float:GetObjectMoveSpeed(objectid)`
- `bool:GetObjectMovingTargetPos(objectid, &Float:targetX, &Float:targetY, &Float:targetZ)`
- `bool:GetObjectMovingTargetRot(objectid, &Float:rotationX, &Float:rotationY, &Float:rotationZ)`
- `bool:GetObjectSyncRotation(objectid)`
- ` GetObjectType(playerid, objectid)`
- ` GetPickupModel(pickupid)`
- `bool:GetPickupPos(pickupid, &Float:x, &Float:y, &Float:z)`
- ` GetPickupType(pickupid)`
- ` GetPickupVirtualWorld(pickupid)`
- `bool:GetPlayer3DTextLabelAttached(playerid, PlayerText3D:textid, &parentPlayerid, &parentVehicleid)`
- ` GetPlayer3DTextLabelColor(playerid, PlayerText3D:textid)`
- `Float:GetPlayer3DTextLabelDrawDist(playerid, PlayerText3D:textid)`
- `bool:GetPlayer3DTextLabelLOS(playerid, PlayerText3D:textid)`
- `bool:GetPlayer3DTextLabelPos(playerid, PlayerText3D:textid, &Float:x, &Float:y, &Float:z)`
- `bool:GetPlayer3DTextLabelText(playerid, PlayerText3D:textid, text[], len = sizeof (text))`
- ` GetPlayer3DTextLabelVirtualW(playerid, PlayerText3D:textid)`
- ` GetPlayerAnimFlags(playerid)`
- `bool:GetPlayerAttachedObject(playerid, index, &modelid, &bone = 0, &Float:offsetX = 0.0, &Float:offsetY = 0.0, &Float:offsetZ = 0.0, &Float:rotationX = 0.0, &Float:rotationY = 0.0, &Float:rotationZ = 0.0, &Float:scaleX = 0.0, &Float:scaleY = 0.0, &Float:scaleZ = 0.0, &materialColour1 = 0, &materialColour2 = 0)`
- ` GetPlayerBuildingsRemoved(playerid)`
- ` GetPlayerCameraTargetPlayerObj(playerid)`
- ` GetPlayerCameraTargetPlayerObject(playerid)`
- `bool:GetPlayerCheckpoint(playerid, &Float:centreX = 0.0, &Float:centreY = 0.0, &Float:centreZ = 0.0, &Float:radius = 0.0)`
- `bool:GetPlayerClass(classid, &team, &skin = 0, &Float:spawnX = 0.0, &Float:spawnY = 0.0, &Float:spawnZ = 0.0, &Float:angle = 0.0, &WEAPON:weapon1 = WEAPON_FIST, &ammo1 = 0, &WEAPON:weapon2 = WEAPON_FIST, &ammo2 = 0, &WEAPON:weapon3 = WEAPON_FIST, &ammo3 = 0)`
- `bool:GetPlayerDialogData(playerid, &DIALOG_STYLE:style, title[], titleSize = sizeof (title), body[], bodySize = sizeof (body), button1[], button1Size = sizeof (button1), button2[], button2Size = sizeof (button2))`
- ` GetPlayerDialogID(playerid)`
- `bool:GetPlayerGhostMode(playerid)`
- `Float:GetPlayerGravity(playerid)`
- ` GetPlayerHydraReactorAngle(playerid)`
- `LANDING_GEAR_STATE:GetPlayerLandingGearState(playerid)`
- ` GetPlayerMarkerForPlayer(playerid, targetid)`
- `bool:GetPlayerObjectAttachedData(playerid, objectid, &parentVehicle, &parentObject = 0, &parentPlayer = 0)`
- `bool:GetPlayerObjectAttachedOffset(playerid, objectid, &Float:offsetX = 0.0, &Float:offsetY = 0.0, &Float:offsetZ = 0.0, &Float:rotationX = 0.0, &Float:rotationY = 0.0, &Float:rotationZ = 0.0)`
- `Float:GetPlayerObjectDrawDistance(playerid, objectid)`
- `bool:GetPlayerObjectMaterial(playerid, objectid, materialIndex, &modelid, textureLibrary[], textureLibrarySize = sizeof (textureLibrary), textureName[], textureNameSize = sizeof (textureName), &materialColour = 0)`
- `bool:GetPlayerObjectMaterialText(playerid, objectid, materialIndex, text[], textSize = sizeof (text), &OBJECT_MATERIAL_SIZE:materialSize, fontFace[], fontFaceSize = sizeof (fontFace), &fontSize = 0, &bool:bold = true, &fontColour = 0xFFFFFFFF, &backgroundColour = 0, &OBJECT_MATERIAL_TEXT_ALIGN:textAlignment = OBJECT_MATERIAL_TEXT_ALIGN_LEFT)`
- `Float:GetPlayerObjectMoveSpeed(playerid, objectid)`
- `bool:GetPlayerObjectMovingTargetPos(playerid, objectid, &Float:targetX, &Float:targetY, &Float:targetZ)`
- `bool:GetPlayerObjectMovingTargetRot(playerid, objectid, &Float:rotationX, &Float:rotationY, &Float:rotationZ)`
- `bool:GetPlayerObjectSyncRotation(playerid, objectid)`
- ` GetPlayerPickupModel(playerid, pickupid)`
- `bool:GetPlayerPickupPos(playerid, pickupid, &Float:x, &Float:y, &Float:z)`
- ` GetPlayerPickupType(playerid, pickupid)`
- ` GetPlayerPickupVirtualWorld(playerid, pickupid)`
- `bool:GetPlayerRaceCheckpoint(playerid, &Float:centreX = 0.0, &Float:centreY = 0.0, &Float:centreZ = 0.0, &Float:nextX = 0.0, &Float:nextY = 0.0, &Float:nextZ = 0.0, &Float:radius = 0.0)`
- ` GetPlayerRawIp(playerid)`
- `bool:GetPlayerRotationQuat(playerid, &Float:w, &Float:x, &Float:y, &Float:z)`
- ` GetPlayers(players[], size = sizeof (players))`
- `bool:GetPlayerSirenState(playerid)`
- ` GetPlayerSkillLevel(playerid, WEAPONSKILL:skill)`
- ` GetPlayerSpectateID(playerid)`
- ` GetPlayerSpectateType(playerid)`
- `bool:GetPlayerSurfingOffsets(playerid, &Float:offsetX, &Float:offsetY, &Float:offsetZ)`
- ` GetPlayerSurfingPlayerObjectID(playerid)`
- `Float:GetPlayerTrainSpeed(playerid)`
- ` GetPlayerWeather(playerid)`
- `bool:GetPlayerWorldBounds(playerid, &Float:maxX, &Float:minX, &Float:maxY, &Float:minY)`
- `Float:GetPlayerZAim(playerid)`
- `bool:GetRandomCarColPair(modelid, &colour1, &colour2, &colour3 = 0, &colour4 = 0)`
- `bool:GetSpawnInfo(playerid, &team, &skin = 0, &Float:spawnX = 0.0, &Float:spawnY = 0.0, &Float:spawnZ = 0.0, &Float:angle = 0.0, &WEAPON:weapon1 = WEAPON_FIST, &ammo1 = 0, &WEAPON:weapon2 = WEAPON_FIST, &ammo2 = 0, &WEAPON:weapon3 = WEAPON_FIST, &ammo3 = 0)`
- ` GetTimerInterval(timerid)`
- ` GetTimerRemaining(timerid)`
- ` GetVehicleCab(vehicleid)`
- `bool:GetVehicleColor(vehicleid, &color1, &color2)`
- ` GetVehicleDriver(vehicleid)`
- ` GetVehicleHydraReactorAngle(vehicleid)`
- ` GetVehicleInterior(vehicleid)`
- `LANDING_GEAR_STATE:GetVehicleLandingGearState(vehicleid)`
- ` GetVehicleLastDriver(vehicleid)`
- `bool:GetVehicleMatrix(vehicleid, &Float:rightX, &Float:rightY, &Float:rightZ, &Float:upX, &Float:upY, &Float:upZ, &Float:atX, &Float:atY, &Float:atZ)`
- ` GetVehicleModelCount(modelid)`
- ` GetVehicleModelsUsed()`
- `bool:GetVehicleNumberPlate(vehicleid, plate[], len = sizeof (plate))`
- ` GetVehicleOccupant(vehicleid, seatid)`
- ` GetVehicleOccupiedTick(vehicleid)`
- ` GetVehiclePaintjob(vehicleid)`
- ` GetVehicleRespawnDelay(vehicleid)`
- ` GetVehicleRespawnTick(vehicleid)`
- `bool:GetVehicleRotation(vehicleid, &Float:x, &Float:y, &Float:z)`
- ` GetVehicles(vehicles[], size = sizeof (vehicles))`
- ` GetVehicleSeats(vehicleid)`
- `bool:GetVehicleSirenState(vehicleid)`
- `bool:GetVehicleSpawnInfo(vehicleid, &Float:spawnX, &Float:spawnY, &Float:spawnZ, &Float:angle, &colour1 = 0, &colour2 = 0)`
- ` GetVehicleTower(vehicleid)`
- `Float:GetVehicleTrainSpeed(vehicleid)`
- `WEAPON_SLOT:GetWeaponSlot(WEAPON:weaponid)`
- ` GetWeather()`
- ` GetWorldTime()`
- `bool:HasGameText(playerid, style)`
- `bool:HasVehicleBeenOccupied(vehicleid)`
- `bool:HideGameTextForAll(style)`
- `bool:HideGameTextForPlayer(playerid, style)`
- `bool:HidePickupForPlayer(playerid, pickupid)`
- `bool:HidePlayerDialog(playerid)`
- `bool:Is3DTextLabelStreamedIn(playerid, Text3D:textid)`
- `bool:IsAdminTeleportAllowed()`
- `bool:IsBanned(const ipaddress[])`
- `bool:IsGangZoneFlashingForPlayer(playerid, zoneid)`
- `bool:IsGangZoneVisibleForPlayer(playerid, zoneid)`
- `bool:IsMenuDisabled(Menu:menuid)`
- `bool:IsMenuRowDisabled(Menu:menuid, row)`
- `bool:IsNickNameCharacterAllowed(character)`
- ` IsObjectMaterialSlotUsed(objectid, materialIndex)`
- `bool:IsObjectNoCameraCol(objectid)`
- `bool:IsPickupHiddenForPlayer(playerid, pickupid)`
- `bool:IsPickupStreamedIn(playerid, pickupid)`
- `bool:IsPlayerCameraTargetEnabled(playerid)`
- `bool:IsPlayerCheckpointActive(playerid)`
- `bool:IsPlayerControllable(playerid)`
- `bool:IsPlayerCuffed(playerid)`
- `bool:IsPlayerGangZoneFlashing(playerid, zoneid)`
- `bool:IsPlayerGangZoneVisible(playerid, zoneid)`
- `bool:IsPlayerInDriveByMode(playerid)`
- `bool:IsPlayerInGangZone(playerid, zoneid)`
- `bool:IsPlayerInModShop(playerid)`
- `bool:IsPlayerInPlayerGangZone(playerid, zoneid)`
- ` IsPlayerObjectMaterialSlotUsed(playerid, objectid, materialIndex)`
- `bool:IsPlayerObjectNoCameraCol(playerid, objectid)`
- `bool:IsPlayerPickupStreamedIn(playerid, pickupid)`
- `bool:IsPlayerRaceCheckpointActive(playerid)`
- `bool:IsPlayerSpawned(playerid)`
- `bool:IsPlayerTeleportAllowed(playerid)`
- `bool:IsPlayerTextDrawVisible(playerid, PlayerText:textid)`
- `bool:IsPlayerUsingOfficialClient(playerid)`
- `bool:IsPlayerUsingOmp(playerid)`
- `bool:IsPlayerWidescreenToggled(playerid)`
- `bool:IsRepeatingTimer(timerid)`
- `bool:IsTextDrawVisibleForPlayer(playerid, Text:textid)`
- `bool:IsValid3DTextLabel(Text3D:textid)`
- `bool:IsValidCustomModel(modelid)`
- `bool:IsValidGangZone(zoneid)`
- `bool:IsValidNickName(const name[])`
- `bool:IsValidPickup(pickupid)`
- `bool:IsValidPlayer3DTextLabel(playerid, PlayerText3D:textid)`
- `bool:IsValidPlayerGangZone(playerid, zoneid)`
- `bool:IsValidPlayerPickup(playerid, pickupid)`
- `bool:IsValidPlayerTextDraw(playerid, PlayerText:textid)`
- `bool:IsValidServerRule(const rule[])`
- `bool:IsValidTextDraw(Text:textid)`
- `bool:IsValidTimer(timerid)`
- `bool:IsVehicleDead(vehicleid)`
- `bool:IsVehicleOccupied(vehicleid)`
- `bool:IsVehicleSirenEnabled(vehicleid)`
- `bool:NPC_AddPointToPath(pathid, Float:x, Float:y, Float:z, Float:stopRange = 0.2)`
- ` NPC_AimAt(npcid, Float:pointX, Float:pointY, Float:pointZ, bool:shoot = false, shootDelay = -1, bool:updateAngle = true, Float:offsetFromX = 0.0, Float:offsetFromY = 0.0, Float:offsetFromZ = 0.0, NPC_ENTITY_CHECK:checkInBetweenFlags = NPC_ENTITY_CHECK_ALL)`
- ` NPC_AimAtPlayer(npcid, playerid, bool:shoot = false, shootDelay = -1, bool:updateAngle = true, Float:offsetX = 0.0, Float:offsetY = 0.0, Float:offsetZ = 0.0, Float:offsetFromX = 0.0, Float:offsetFromY = 0.0, Float:offsetFromZ = 0.0, NPC_ENTITY_CHECK:checkInBetweenFlags = NPC_ENTITY_CHECK_ALL)`
- ` NPC_ApplyAnimation(npcid, const animlib[], const animname[], Float:delta, bool:loop, bool:lockX, bool:lockY, bool:freeze, time)`
- ` NPC_ChangeNode(npcid, nodeid, linkid)`
- ` NPC_ClearAnimations(npcid)`
- `bool:NPC_ClearPath(pathid)`
- `bool:NPC_CloseNode(nodeid)`
- ` NPC_Create(const name[])`
- ` NPC_CreatePath()`
- ` NPC_Destroy(npcid)`
- `bool:NPC_DestroyAllPath()`
- `bool:NPC_DestroyPath(pathid)`
- `bool:NPC_EnableInfiniteAmmo(npcid, bool:enable = true)`
- `bool:NPC_EnableReloading(npcid, bool:enable = true)`
- `bool:NPC_EnterVehicle(npcid, vehicleid, seatid, NPC_MOVE_TYPE:moveType = NPC_MOVE_TYPE_AUTO)`
- `bool:NPC_ExitVehicle(npcid)`
- ` NPC_GetAll(npcs[], size = sizeof(npcs))`
- ` NPC_GetAmmo(npcid)`
- ` NPC_GetAmmoInClip(npcid)`
- ` NPC_GetAnimation(npcid, &animationId, &Float:delta, &bool:loop, &bool:lockX, &bool:lockY, &bool:freeze, &time)`
- `Float:NPC_GetArmour(npcid)`
- ` NPC_GetCurrentPathPointIndex(npcid)`
- ` NPC_GetCustomSkin(npcid)`
- ` NPC_GetEnteringVehicle(npcid)`
- ` NPC_GetEnteringVehicleID(npcid)`
- ` NPC_GetEnteringVehicleSeat(npcid)`
- ` NPC_GetFacingAngle(npcid, &Float:angle)`
- `FIGHT_STYLE:NPC_GetFightingStyle(npcid)`
- `Float:NPC_GetHealth(npcid)`
- ` NPC_GetInterior(npcid)`
- ` NPC_GetKeys(npcid, &upAnddown, &leftandRight, &keys)`
- `bool:NPC_GetNodeInfo(nodeid, &vehnodes, &pednodes, &navinode)`
- ` NPC_GetNodePointCount(nodeid)`
- `bool:NPC_GetNodePointPosition(nodeid, &Float:x, &Float:y, &Float:z)`
- ` NPC_GetNodeType(nodeid)`
- ` NPC_GetPathCount()`
- `bool:NPC_GetPathPoint(pathid, pointIndex, &Float:x, &Float:y, &Float:z, &Float:stopRange = 0.2)`
- ` NPC_GetPathPointCount(pathid)`
- ` NPC_GetPlayerAimingAt(npcid)`
- ` NPC_GetPlayerMovingTo(npcid)`
- ` NPC_GetPos(npcid, &Float:x, &Float:y, &Float:z)`
- ` NPC_GetPosMovingTo(npcid, &Float:x, &Float:y, &Float:z)`
- ` NPC_GetRecordCount()`
- ` NPC_GetRot(npcid, &Float:x, &Float:y, &Float:z)`
- ` NPC_GetSkin(npcid)`
- `SPECIAL_ACTION:NPC_GetSpecialAction(npcid)`
- ` NPC_GetSurfingObject(npcid)`
- ` NPC_GetSurfingOffsets(npcid, &Float:x, &Float:y, &Float:z)`
- ` NPC_GetSurfingPlayerObject(npcid)`
- ` NPC_GetSurfingVehicle(npcid)`
- ` NPC_GetVehicle(npcid)`
- `LANDING_GEAR_STATE:NPC_GetVehicleGearState(npcid)`
- `Float:NPC_GetVehicleHealth(npcid)`
- ` NPC_GetVehicleHydraThrusters(npcid)`
- ` NPC_GetVehicleID(npcid)`
- `bool:NPC_GetVehiclePos(npcid, &Float:x, &Float:y, &Float:z)`
- `bool:NPC_GetVehicleRot(npcid, &Float:x, &Float:y, &Float:z)`
- ` NPC_GetVehicleSeat(npcid)`
- `Float:NPC_GetVehicleTrainSpeed(npcid)`
- ` NPC_GetVelocity(npcid, &Float:x, &Float:y, &Float:z)`
- ` NPC_GetVirtualWorld(npcid)`
- `WEAPON:NPC_GetWeapon(npcid)`
- `Float:NPC_GetWeaponAccuracy(npcid, WEAPON:weaponid)`
- ` NPC_GetWeaponActualClipSize(npcid, WEAPON:weaponid)`
- ` NPC_GetWeaponActualReloadTime(npcid, WEAPON:weaponid)`
- ` NPC_GetWeaponClipSize(npcid, WEAPON:weaponid)`
- ` NPC_GetWeaponReloadTime(npcid, WEAPON:weaponid)`
- ` NPC_GetWeaponShootTime(npcid, WEAPON:weaponid)`
- ` NPC_GetWeaponSkillLevel(npcid, WEAPONSKILL:skill)`
- `WEAPONSTATE:NPC_GetWeaponState(npcid)`
- `bool:NPC_HasPathPointInRange(pathId, Float:x, Float:y, Float:z, Float:radius)`
- `bool:NPC_IsAiming(npcid)`
- `bool:NPC_IsAimingAtPlayer(npcid, playerid)`
- `bool:NPC_IsAnyStreamedIn(npcid)`
- `bool:NPC_IsDead(npcid)`
- `bool:NPC_IsEnteringVehicle(npcid)`
- `bool:NPC_IsInfiniteAmmoEnabled(npcid)`
- `bool:NPC_IsInvulnerable(npcid)`
- `bool:NPC_IsMeleeAttacking(npcid)`
- `bool:NPC_IsMoving(npcid)`
- `bool:NPC_IsMovingToPlayer(npcid, playerid)`
- `bool:NPC_IsNodeOpen(nodeid)`
- `bool:NPC_IsPlaybackPaused(npcid)`
- `bool:NPC_IsPlayingNode(npcid)`
- `bool:NPC_IsPlayingNodePaused(npcid)`
- `bool:NPC_IsPlayingPlayback(npcid)`
- `bool:NPC_IsReloadEnabled(npcid)`
- `bool:NPC_IsReloading(npcid)`
- `bool:NPC_IsShooting(npcid)`
- `bool:NPC_IsSpawned(npcid)`
- `bool:NPC_IsStreamedIn(npcid, playerid)`
- `bool:NPC_IsValid(npcid)`
- `bool:NPC_IsValidPath(pathid)`
- `bool:NPC_IsValidRecord(recordId)`
- `bool:NPC_IsVehicleSirenUsed(npcid)`
- ` NPC_Kill(npcid, killerid = INVALID_PLAYER_ID, WEAPON:reason = REASON_SUICIDE)`
- ` NPC_LoadRecord(const filePath[])`
- `bool:NPC_MeleeAttack(npcid, time = -1, bool:secondaryAttack = false)`
- ` NPC_Move(npcid, Float:x, Float:y, Float:z, NPC_MOVE_TYPE:moveType = NPC_MOVE_TYPE_AUTO, Float:moveSpeed = NPC_MOVE_SPEED_AUTO, Float:stopRange = 0.2)`
- `bool:NPC_MoveByPath(npcid, pathid, NPC_MOVE_TYPE:moveType = NPC_MOVE_TYPE_AUTO, Float:moveSpeed = NPC_MOVE_SPEED_AUTO, bool:reversed = false)`
- ` NPC_MoveToPlayer(npcid, playerid, NPC_MOVE_TYPE:moveType = NPC_MOVE_TYPE_AUTO, Float:moveSpeed = NPC_MOVE_SPEED_AUTO, Float:stopRange = 0.2, updateDelayMS = 500, autoRestart = false)`
- `bool:NPC_OpenNode(nodeid)`
- `bool:NPC_PausePlayback(npcid, bool:paused = true)`
- `bool:NPC_PausePlayingNode(npcid)`
- `bool:NPC_PlayNode(npcid, nodeid, NPC_MOVE_TYPE:moveType = NPC_MOVE_TYPE_AUTO, Float:speed = NPC_MOVE_SPEED_AUTO, Float:radius = 0.0, bool:setAngle = true)`
- `bool:NPC_PutInVehicle(npcid, vehicleid, seatid)`
- `bool:NPC_RemoveFromVehicle(npcid)`
- `bool:NPC_RemovePointFromPath(pathid, pointIndex)`
- ` NPC_ResetAnimation(npcid)`
- ` NPC_ResetSurfingData(npcid)`
- ` NPC_Respawn(npcid)`
- `bool:NPC_ResumePlayingNode(npcid)`
- ` NPC_SetAmmo(npcid, ammo)`
- ` NPC_SetAmmoInClip(npcid, ammo)`
- ` NPC_SetAngleToPlayer(npcid, playerid)`
- ` NPC_SetAngleToPos(npcid, Float:x, Float:y, Float:z)`
- ` NPC_SetAnimation(npcid, animationId, Float:delta, bool:loop, bool:lockX, bool:lockY, bool:freeze, time)`
- ` NPC_SetArmour(npcid, Float:armour)`
- ` NPC_SetFacingAngle(npcid, Float:angle)`
- ` NPC_SetFightingStyle(npcid, FIGHT_STYLE:style)`
- ` NPC_SetHealth(npcid, Float:health)`
- ` NPC_SetInterior(npcid, interiorid)`
- ` NPC_SetInvulnerable(npcid, bool:toggle = true)`
- ` NPC_SetKeys(npcid, upAndDown, leftAndRight, keys)`
- `bool:NPC_SetNodePoint(nodeid, pointid)`
- ` NPC_SetPos(npcid, Float:x, Float:y, Float:z)`
- ` NPC_SetRot(npcid, Float:x, Float:y, Float:z)`
- ` NPC_SetSkin(npcid, skinid)`
- ` NPC_SetSpecialAction(npcid, SPECIAL_ACTION:actionid)`
- ` NPC_SetSurfingObject(npcid, objectid)`
- ` NPC_SetSurfingOffsets(npcid, Float:x, Float:y, Float:z)`
- ` NPC_SetSurfingPlayerObject(npcid, objectid)`
- ` NPC_SetSurfingVehicle(npcid, vehicleid)`
- ` NPC_SetVehicleGearState(npcid, LANDING_GEAR_STATE:gearState)`
- ` NPC_SetVehicleHealth(npcid, Float:health)`
- ` NPC_SetVehicleHydraThrusters(npcid, direction)`
- `bool:NPC_SetVehiclePos(npcid, Float:x, Float:y, Float:z)`
- `bool:NPC_SetVehicleRot(npcid, Float:x, Float:y, Float:z)`
- ` NPC_SetVehicleTrainSpeed(npcid, Float:speed)`
- ` NPC_SetVelocity(npcid, Float:x, Float:y, Float:z)`
- ` NPC_SetVirtualWorld(npcid, virtualWorld)`
- ` NPC_SetWeapon(npcid, WEAPON:weaponid)`
- ` NPC_SetWeaponAccuracy(npcid, WEAPON:weaponid, Float:accuracy)`
- ` NPC_SetWeaponClipSize(npcid, WEAPON:weaponid, size)`
- ` NPC_SetWeaponReloadTime(npcid, WEAPON:weaponid, time)`
- ` NPC_SetWeaponShootTime(npcid, WEAPON:weaponid, time)`
- `bool:NPC_SetWeaponSkillLevel(npcid, WEAPONSKILL:skill, level)`
- ` NPC_SetWeaponState(npcid, WEAPONSTATE:weaponState)`
- ` NPC_Shoot(npcid, WEAPON:weaponid, hitId, hitType, Float:endPointX, Float:endPointY, Float:endPointZ, Float:offsetX = 0.0, Float:offsetY = 0.0, Float:offsetZ = 0.0, bool:isHit = true, NPC_ENTITY_CHECK:checkInBetweenFlags = NPC_ENTITY_CHECK_ALL)`
- ` NPC_Spawn(npcid)`
- `bool:NPC_StartPlayback(npcid, const recordName[], bool:autoUnload = false, Float:startX = 0.0, Float:startY = 0.0, Float:startZ = 0.0, Float:rotX = 0.0, Float:rotY = 0.0, Float:rotZ = 0.0)`
- `bool:NPC_StartPlaybackEx(npcid, recordId, bool:autoUnload = false, Float:startX = 0.0, Float:startY = 0.0, Float:startZ = 0.0, Float:rotX = 0.0, Float:rotY = 0.0, Float:rotZ = 0.0)`
- `bool:NPC_StopAim(npcid)`
- `bool:NPC_StopMeleeAttack(npcid)`
- `bool:NPC_StopMove(npcid)`
- `bool:NPC_StopPlayback(npcid)`
- `bool:NPC_StopPlayingNode(npcid)`
- `bool:NPC_UnloadAllRecords()`
- `bool:NPC_UnloadRecord(recordId)`
- `bool:NPC_UpdateNodePoint(npcid, pointid)`
- `bool:NPC_UseVehicleSiren(npcid, bool:use = true)`
- ` OnNPCChangeNode(npcid, newnodeid, oldnodeid)`
- ` OnNPCCreate(npcid)`
- ` OnNPCDeath(npcid, killerid, WEAPON:reason)`
- ` OnNPCDestroy(npcid)`
- ` OnNPCFinishMove(npcid)`
- ` OnNPCFinishMovePath(npcid, pathid)`
- ` OnNPCFinishMovePathPoint(npcid, pathid, pointid)`
- ` OnNPCFinishNode(npcid, nodeid)`
- ` OnNPCFinishNodePoint(npcid, nodeid, pointid)`
- ` OnNPCGiveDamage(npcid, damagedid, Float:amount, WEAPON:weaponid, bodypart)`
- ` OnNPCPlaybackEnd(npcid, recordid)`
- ` OnNPCPlaybackStart(npcid, recordid)`
- ` OnNPCRespawn(npcid)`
- ` OnNPCTakeDamage(npcid, issuerid, Float:amount, WEAPON:weaponid, bodypart)`
- ` OnNPCWeaponShot(npcid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)`
- ` OnNPCWeaponStateChange(npcid, newState, oldState)`
- ` OnPickupStreamIn(pickupid, playerid)`
- ` OnPickupStreamOut(pickupid, playerid)`
- ` OnPlayerClickGangZone(playerid, zoneid)`
- ` OnPlayerClickPlayerGangZone(playerid, zoneid)`
- ` OnPlayerEnterGangZone(playerid, zoneid)`
- ` OnPlayerEnterPlayerGangZone(playerid, zoneid)`
- ` OnPlayerLeaveGangZone(playerid, zoneid)`
- ` OnPlayerLeavePlayerGangZone(playerid, zoneid)`
- ` OnPlayerPickUpPlayerPickup(playerid, pickupid)`
- ` OnPlayerPickupStreamIn(pickupid, playerid)`
- ` OnPlayerPickupStreamOut(pickupid, playerid)`
- ` OnScriptLoadPlayer(playerid, bool:isEntryScript)`
- ` OnScriptUnloadPlayer(playerid, bool:isEntryScript)`
- `bool:PlayerGangZoneDestroy(playerid, zoneid)`
- `bool:PlayerGangZoneFlash(playerid, zoneid, flashColour)`
- ` PlayerGangZoneGetColour(playerid, zoneid)`
- ` PlayerGangZoneGetFlashColour(playerid, zoneid)`
- `bool:PlayerGangZoneGetPos(playerid, zoneid, &Float:minX, &Float:minY, &Float:maxX, &Float:maxY)`
- `bool:PlayerGangZoneHide(playerid, zoneid)`
- `bool:PlayerGangZoneShow(playerid, zoneid, colour)`
- `bool:PlayerGangZoneStopFlash(playerid, zoneid)`
- `bool:PlayerHasClockEnabled(playerid)`
- `TEXT_DRAW_ALIGN:PlayerTextDrawGetAlignment(playerid, PlayerText:textid)`
- ` PlayerTextDrawGetBackgroundCol(playerid, PlayerText:textid)`
- ` PlayerTextDrawGetBoxColor(playerid, PlayerText:textid)`
- ` PlayerTextDrawGetColor(playerid, PlayerText:textid)`
- `TEXT_DRAW_FONT:PlayerTextDrawGetFont(playerid, PlayerText:textid)`
- `bool:PlayerTextDrawGetLetterSize(playerid, PlayerText:textid, &Float:width, &Float:height)`
- ` PlayerTextDrawGetOutline(playerid, PlayerText:textid)`
- `bool:PlayerTextDrawGetPos(playerid, PlayerText:textid, &Float:x, &Float:y)`
- ` PlayerTextDrawGetPreviewModel(playerid, PlayerText:textid)`
- `bool:PlayerTextDrawGetPreviewRot(playerid, PlayerText:textid, &Float:rotationX, &Float:rotationY, &Float:rotationZ, &Float:zoom)`
- `bool:PlayerTextDrawGetPreviewVehCol(playerid, PlayerText:textid, &colour1, &colour2)`
- ` PlayerTextDrawGetShadow(playerid, PlayerText:textid)`
- `bool:PlayerTextDrawGetString(playerid, PlayerText:textid, string[], stringSize = sizeof (string))`
- `bool:PlayerTextDrawGetTextSize(playerid, PlayerText:textid, &Float:width, &Float:height)`
- `bool:PlayerTextDrawIsBox(playerid, PlayerText:textid)`
- `bool:PlayerTextDrawIsProportional(playerid, PlayerText:textid)`
- `bool:PlayerTextDrawIsSelectable(playerid, PlayerText:textid)`
- `bool:PlayerTextDrawSetPos(playerid, PlayerText:textid, Float:x, Float:y)`
- `bool:RemovePlayerWeapon(playerid, WEAPON:weaponid)`
- `bool:RemoveServerRule(const rule[])`
- `bool:Set3DTextLabelDrawDistance(Text3D:textid, Float:drawDistance)`
- `bool:Set3DTextLabelLOS(Text3D:textid, bool:enable)`
- `bool:Set3DTextLabelVirtualWorld(Text3D:textid, virtualWorld)`
- `bool:SetActorSkin(actorid, skin)`
- `bool:SetModeRestartTime(Float:seconds)`
- `bool:SetObjectMoveSpeed(objectid, Float:speed)`
- `bool:SetObjectsDefaultCameraCollision(bool:disable)`
- `bool:SetPickupModel(pickupid, model, bool:update = true)`
- `bool:SetPickupPos(pickupid, Float:x, Float:y, Float:z, bool:update = true)`
- `bool:SetPickupType(pickupid, type, bool:update = true)`
- `bool:SetPickupVirtualWorld(pickupid, virtualWorld)`
- `bool:SetPlayer3DTextLabelDrawDist(playerid, PlayerText3D:textid, Float:drawDistance)`
- `bool:SetPlayer3DTextLabelLOS(playerid, PlayerText3D:textid, bool:enable)`
- `bool:SetPlayerAdmin(playerid, bool:admin)`
- `bool:SetPlayerGravity(playerid, Float:gravity)`
- `bool:SetPlayerObjectMoveSpeed(playerid, objectid, Float:speed)`
- `bool:SetPlayerObjectNoCameraCollision(playerid, objectid)`
- `bool:SetPlayerPickupModel(playerid, pickupid, model, bool:update = true)`
- `bool:SetPlayerPickupPos(playerid, pickupid, Float:x, Float:y, Float:z, bool:update = true)`
- `bool:SetPlayerPickupType(playerid, pickupid, type, bool:update = true)`
- `bool:SetPlayerPickupVirtualWorld(playerid, pickupid, virtualWorld)`
- `bool:SetServerRule(const rule[], const format[], OPEN_MP_TAGS:...)`
- `bool:SetVehicleParamsSirenState(vehicleid, bool:enabled)`
- `bool:SetVehicleRespawnDelay(vehicleid, respawnDelay)`
- `bool:SetVehicleSpawnInfo(vehicleid, modelid, Float:spawnX, Float:spawnY, Float:spawnZ, Float:angle, colour1, colour2, respawnDelay = -2, interior = -2)`
- `bool:ShowPickupForPlayer(playerid, pickupid)`
- `TEXT_DRAW_ALIGN:TextDrawGetAlignment(Text:textid)`
- ` TextDrawGetBackgroundColor(Text:textid)`
- ` TextDrawGetBoxColor(Text:textid)`
- ` TextDrawGetColor(Text:textid)`
- `TEXT_DRAW_FONT:TextDrawGetFont(Text:textid)`
- `bool:TextDrawGetLetterSize(Text:textid, &Float:width, &Float:height)`
- ` TextDrawGetOutline(Text:textid)`
- `bool:TextDrawGetPos(Text:textid, &Float:x, &Float:y)`
- ` TextDrawGetPreviewModel(Text:textid)`
- `bool:TextDrawGetPreviewRot(Text:textid, &Float:rotationX, &Float:rotationY, &Float:rotationZ, &Float:zoom)`
- `bool:TextDrawGetPreviewVehCol(Text:textid, &colour1, &colour2)`
- ` TextDrawGetShadow(Text:textid)`
- `bool:TextDrawGetString(Text:textid, string[], stringSize = sizeof (string))`
- `bool:TextDrawGetTextSize(Text:textid, &Float:width, &Float:height)`
- `bool:TextDrawIsBox(Text:textid)`
- `bool:TextDrawIsProportional(Text:textid)`
- `bool:TextDrawIsSelectable(Text:textid)`
- `bool:TextDrawSetPos(Text:textid, Float:x, Float:y)`
- `bool:TextDrawSetStringForPlayer(Text:textid, playerid, const format[], OPEN_MP_TAGS:...)`
- `void:ToggleChatTextReplacement(bool:enable)`
- `bool:TogglePlayerGhostMode(playerid, bool:enable)`
- `bool:TogglePlayerWidescreen(playerid, bool:wide)`
- `bool:ToggleVehicleSirenEnabled(vehicleid, bool:enabled)`
- `bool:UseGangZoneCheck(zoneid, bool:enable)`
- `bool:UsePlayerGangZoneCheck(playerid, zoneid, bool:enable)`
- `bool:VehicleCanHaveComponent(modelid, componentid)`

## Unverifiable — the legacy stdlib copy has no matching module

- `argcount` (module args.inc tidak ada di stdlib legacy)
- `argindex` (module args.inc tidak ada di stdlib legacy)
- `argstr` (module args.inc tidak ada di stdlib legacy)
- `argvalue` (module args.inc tidak ada di stdlib legacy)
- `clamp` (module core.inc tidak ada di stdlib legacy)
- `clreol` (module console.inc tidak ada di stdlib legacy)
- `clrscr` (module console.inc tidak ada di stdlib legacy)
- `deletecfg` (module file.inc tidak ada di stdlib legacy)
- `deleteproperty` (module core.inc tidak ada di stdlib legacy)
- `dfind` (module file.inc tidak ada di stdlib legacy)
- `existproperty` (module core.inc tidak ada di stdlib legacy)
- `fattrib` (module file.inc tidak ada di stdlib legacy)
- `fblockread` (module file.inc tidak ada di stdlib legacy)
- `fblockwrite` (module file.inc tidak ada di stdlib legacy)
- `fclose` (module file.inc tidak ada di stdlib legacy)
- `fcopy` (module file.inc tidak ada di stdlib legacy)
- `fcreatedir` (module file.inc tidak ada di stdlib legacy)
- `fexist` (module file.inc tidak ada di stdlib legacy)
- `ffind` (module file.inc tidak ada di stdlib legacy)
- `fgetchar` (module file.inc tidak ada di stdlib legacy)
- `filecrc` (module file.inc tidak ada di stdlib legacy)
- `flength` (module file.inc tidak ada di stdlib legacy)
- `float` (module float.inc tidak ada di stdlib legacy)
- `floatabs` (module float.inc tidak ada di stdlib legacy)
- `floatadd` (module float.inc tidak ada di stdlib legacy)
- `floatcmp` (module float.inc tidak ada di stdlib legacy)
- `floatcos` (module float.inc tidak ada di stdlib legacy)
- `floatdiv` (module float.inc tidak ada di stdlib legacy)
- `floatfract` (module float.inc tidak ada di stdlib legacy)
- `floatlog` (module float.inc tidak ada di stdlib legacy)
- `floatmul` (module float.inc tidak ada di stdlib legacy)
- `floatpower` (module float.inc tidak ada di stdlib legacy)
- `floatround` (module float.inc tidak ada di stdlib legacy)
- `floatsin` (module float.inc tidak ada di stdlib legacy)
- `floatsqroot` (module float.inc tidak ada di stdlib legacy)
- `floatstr` (module float.inc tidak ada di stdlib legacy)
- `floatsub` (module float.inc tidak ada di stdlib legacy)
- `floattan` (module float.inc tidak ada di stdlib legacy)
- `fmatch` (module file.inc tidak ada di stdlib legacy)
- `fopen` (module file.inc tidak ada di stdlib legacy)
- `fputchar` (module file.inc tidak ada di stdlib legacy)
- `fread` (module file.inc tidak ada di stdlib legacy)
- `fremove` (module file.inc tidak ada di stdlib legacy)
- `frename` (module file.inc tidak ada di stdlib legacy)
- `fseek` (module file.inc tidak ada di stdlib legacy)
- `fstat` (module file.inc tidak ada di stdlib legacy)
- `ftell` (module file.inc tidak ada di stdlib legacy)
- `ftemp` (module file.inc tidak ada di stdlib legacy)
- `ftouch` (module file.inc tidak ada di stdlib legacy)
- `funcidx` (module core.inc tidak ada di stdlib legacy)
- `fwrite` (module file.inc tidak ada di stdlib legacy)
- `getarg` (module core.inc tidak ada di stdlib legacy)
- `getchar` (module console.inc tidak ada di stdlib legacy)
- `getdate` (module time.inc tidak ada di stdlib legacy)
- `getproperty` (module core.inc tidak ada di stdlib legacy)
- `getstring` (module console.inc tidak ada di stdlib legacy)
- `gettime` (module time.inc tidak ada di stdlib legacy)
- `getvalue` (module console.inc tidak ada di stdlib legacy)
- `gotoxy` (module console.inc tidak ada di stdlib legacy)
- `heapspace` (module core.inc tidak ada di stdlib legacy)
- `ispacked` (module string.inc tidak ada di stdlib legacy)
- `listenport` (module datagram.inc tidak ada di stdlib legacy)
- `max` (module core.inc tidak ada di stdlib legacy)
- `memcpy` (module string.inc tidak ada di stdlib legacy)
- `min` (module core.inc tidak ada di stdlib legacy)
- `numargs` (module core.inc tidak ada di stdlib legacy)
- `random` (module core.inc tidak ada di stdlib legacy)
- `readcfg` (module file.inc tidak ada di stdlib legacy)
- `readcfgvalue` (module file.inc tidak ada di stdlib legacy)
- `sendpacket` (module datagram.inc tidak ada di stdlib legacy)
- `sendstring` (module datagram.inc tidak ada di stdlib legacy)
- `setarg` (module core.inc tidak ada di stdlib legacy)
- `setattr` (module console.inc tidak ada di stdlib legacy)
- `setdate` (module time.inc tidak ada di stdlib legacy)
- `setproperty` (module core.inc tidak ada di stdlib legacy)
- `settime` (module time.inc tidak ada di stdlib legacy)
- `strcat` (module string.inc tidak ada di stdlib legacy)
- `strcmp` (module string.inc tidak ada di stdlib legacy)
- `strdel` (module string.inc tidak ada di stdlib legacy)
- `strfind` (module string.inc tidak ada di stdlib legacy)
- `strformat` (module string.inc tidak ada di stdlib legacy)
- `strins` (module string.inc tidak ada di stdlib legacy)
- `strlen` (module string.inc tidak ada di stdlib legacy)
- `strmid` (module string.inc tidak ada di stdlib legacy)
- `strpack` (module string.inc tidak ada di stdlib legacy)
- `strunpack` (module string.inc tidak ada di stdlib legacy)
- `strval` (module string.inc tidak ada di stdlib legacy)
- `swapchars` (module core.inc tidak ada di stdlib legacy)
- `tickcount` (module time.inc tidak ada di stdlib legacy)
- `tolower` (module core.inc tidak ada di stdlib legacy)
- `toupper` (module core.inc tidak ada di stdlib legacy)
- `uudecode` (module string.inc tidak ada di stdlib legacy)
- `uuencode` (module string.inc tidak ada di stdlib legacy)
- `valstr` (module string.inc tidak ada di stdlib legacy)
- `writecfg` (module file.inc tidak ada di stdlib legacy)
- `writecfgvalue` (module file.inc tidak ada di stdlib legacy)

## 0.3.7 only — removed or renamed in open.mp

- ` CancelEdit(playerid)`
- ` db_close(DB:db)`
- ` db_debug_openfiles()`
- ` db_debug_openresults()`
- ` db_field_name(DBResult:dbresult, field, result[], maxlength = sizeof result)`
- ` db_free_result(DBResult:dbresult)`
- ` db_get_field(DBResult:dbresult, field, result[], maxlength = sizeof result)`
- ` db_get_field_assoc(DBResult:dbresult, const field[], result[], maxlength = sizeof result)`
- `Float: db_get_field_assoc_float(DBResult:result, const field[])`
- ` db_get_field_assoc_int(DBResult:result, const field[])`
- `Float: db_get_field_float(DBResult:result, field = 0)`
- ` db_get_field_int(DBResult:result, field = 0)`
- ` db_get_mem_handle(DB:db)`
- ` db_get_result_mem_handle(DBResult:result)`
- ` db_next_row(DBResult:dbresult)`
- ` db_num_fields(DBResult:dbresult)`
- ` db_num_rows(DBResult:dbresult)`
- `DB: db_open(const name[])`
- `DBResult: db_query(DB:db, const query[])`
- ` EditObject(playerid, objectid)`
- ` EditPlayerObject(playerid, objectid)`
- ` GetActorPoolSize()` _(deprecated `stock` shim present)_
- ` GetDistanceFromMeToPoint(Float:X, Float:Y, Float:Z, &Float:Distance)`
- ` GetMyFacingAngle(&Float:ang)`
- ` GetMyPos(&Float:x, &Float:y, &Float:z)`
- ` GetPlayerArmedWeapon(playerid)`
- ` GetPlayerPoolSize()` _(deprecated `stock` shim present)_
- ` GetServerVarAsBool(const varname[])`
- ` GetServerVarAsInt(const varname[])`
- ` GetServerVarAsString(const varname[], buffer[], len = sizeof buffer)`
- ` GetVehiclePoolSize()` _(deprecated `stock` shim present)_
- ` OnClientMessage(color, text[])`
- ` OnNPCConnect(myplayerid)`
- ` OnNPCDisconnect(reason[])`
- ` OnNPCEnterVehicle(vehicleid, seatid)`
- ` OnNPCExitVehicle()`
- ` OnNPCModeExit()`
- ` OnNPCModeInit()`
- ` OnRecordingPlaybackEnd()`
- ` OnScriptCash(playerid, amount, source)`
- ` PauseRecordingPlayback()`
- ` ResumeRecordingPlayback()`
- ` SelectObject(playerid)`
- ` SendChat(const msg[])`
- ` SendCommand(const commandtext[])`
- ` SetMyFacingAngle(Float:ang)`
- ` SetMyPos(Float:x, Float:y, Float:z)`
- ` StartRecordingPlayback(playbacktype, const recordname[])`
- ` StopRecordingPlayback()`

## Shared but reshaped — the signature is not interchangeable

### `AddCharModel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AddCharModel(baseid, newid, const dffname[], const txdname[])` |
| open.mp | `bool: AddCharModel(baseid, newid, const dff[], const textureLibrary[])` |

### `AddMenuItem`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AddMenuItem(Menu:menuid, column, const menutext[])` |
| open.mp | ` AddMenuItem(Menu:menuid, column, const text[], OPEN_MP_TAGS:...)` |

### `AddPlayerClass`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AddPlayerClass(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)` |
| open.mp | ` AddPlayerClass(skin, Float:spawnX, Float:spawnY, Float:spawnZ, Float:angle, WEAPON:weapon1 = WEAPON_FIST, ammo1 = 0, WEAPON:weapon2 = WEAPON_FIST, ammo2 = 0, WEAPON:weapon3 = WEAPON_FIST, ammo3 = 0)` |

### `AddPlayerClassEx`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AddPlayerClassEx(teamid, modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)` |
| open.mp | ` AddPlayerClassEx(team, skin, Float:spawnX, Float:spawnY, Float:spawnZ, Float:angle, WEAPON:weapon1 = WEAPON_FIST, ammo1 = 0, WEAPON:weapon2 = WEAPON_FIST, ammo2 = 0, WEAPON:weapon3 = WEAPON_FIST, ammo3 = 0)` |

### `AddSimpleModel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AddSimpleModel(virtualworld, baseid, newid, const dffname[], const txdname[])` |
| open.mp | `bool: AddSimpleModel(virtualWorld, baseid, newid, const dff[], const textureLibrary[])` |

### `AddSimpleModelTimed`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AddSimpleModelTimed(virtualworld, baseid, newid, const dffname[], const txdname[], timeon, timeoff)` |
| open.mp | `bool: AddSimpleModelTimed(virtualWorld, baseid, newid, const dff[], const textureLibrary[], timeOn, timeOff)` |

### `AddStaticVehicleEx`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AddStaticVehicleEx(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, color1, color2, respawn_delay, addsiren=0)` |
| open.mp | ` AddStaticVehicleEx(modelid, Float:spawnX, Float:spawnY, Float:spawnZ, Float:angle, colour1, colour2, respawnDelay, bool:addSiren = false)` |

### `AddVehicleComponent`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AddVehicleComponent(vehicleid, componentid)` |
| open.mp | `bool: AddVehicleComponent(vehicleid, component)` |

### `AllowAdminTeleport`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AllowAdminTeleport(allow)` |
| open.mp | `void: AllowAdminTeleport(bool:allow)` |

### `AllowInteriorWeapons`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AllowInteriorWeapons(allow)` |
| open.mp | `void: AllowInteriorWeapons(bool:allow)` |

### `AllowPlayerTeleport`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AllowPlayerTeleport(playerid, allow)` |
| open.mp | `bool: AllowPlayerTeleport(playerid, bool:allow)` |

### `ApplyActorAnimation`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ApplyActorAnimation(actorid, const animlib[], const animname[], Float:fDelta, loop, lockx, locky, freeze, time)` |
| open.mp | `bool: ApplyActorAnimation(actorid, const animationLibrary[], const animationName[], Float:delta, bool:loop, bool:lockX, bool:lockY, bool:freeze, time)` |

### `ApplyAnimation`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ApplyAnimation(playerid, const animlib[], const animname[], Float:fDelta, loop, lockx, locky, freeze, time, forcesync = 0)` |
| open.mp | `bool: ApplyAnimation(playerid, const animationLibrary[], const animationName[], Float:delta, bool:loop, bool:lockX, bool:lockY, bool:freeze, time, FORCE_SYNC:forceSync = SYNC_NONE)` |

### `Attach3DTextLabelToPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` Attach3DTextLabelToPlayer(Text3D:id, playerid, Float:OffsetX, Float:OffsetY, Float:OffsetZ)` |
| open.mp | `bool: Attach3DTextLabelToPlayer(Text3D:textid, parentid, Float:offsetX, Float:offsetY, Float:offsetZ)` |

### `Attach3DTextLabelToVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` Attach3DTextLabelToVehicle(Text3D:id, vehicleid, Float:OffsetX, Float:OffsetY, Float:OffsetZ)` |
| open.mp | `bool: Attach3DTextLabelToVehicle(Text3D:textid, parentid, Float:offsetX, Float:offsetY, Float:offsetZ)` |

### `AttachCameraToObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AttachCameraToObject(playerid, objectid)` |
| open.mp | `bool: AttachCameraToObject(playerid, objectid)` |

### `AttachCameraToPlayerObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AttachCameraToPlayerObject(playerid, playerobjectid)` |
| open.mp | `bool: AttachCameraToPlayerObject(playerid, objectid)` |

### `AttachObjectToObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AttachObjectToObject(objectid, attachtoid, Float:OffsetX, Float:OffsetY, Float:OffsetZ, Float:RotX, Float:RotY, Float:RotZ, SyncRotation = 1)` |
| open.mp | `bool: AttachObjectToObject(objectid, parentid, Float:offsetX, Float:offsetY, Float:offsetZ, Float:rotationX, Float:rotationY, Float:rotationZ, bool:syncRotation = true)` |

### `AttachObjectToPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AttachObjectToPlayer(objectid, playerid, Float:OffsetX, Float:OffsetY, Float:OffsetZ, Float:RotX, Float:RotY, Float:RotZ)` |
| open.mp | `bool: AttachObjectToPlayer(objectid, parentid, Float:offsetX, Float:offsetY, Float:offsetZ, Float:rotationX, Float:rotationY, Float:rotationZ)` |

### `AttachObjectToVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AttachObjectToVehicle(objectid, vehicleid, Float:OffsetX, Float:OffsetY, Float:OffsetZ, Float:RotX, Float:RotY, Float:RotZ)` |
| open.mp | `bool: AttachObjectToVehicle(objectid, parentid, Float:offsetX, Float:offsetY, Float:offsetZ, Float:rotationX, Float:rotationY, Float:rotationZ)` |

### `AttachPlayerObjectToPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AttachPlayerObjectToPlayer(objectplayer, objectid, attachplayer, Float:OffsetX, Float:OffsetY, Float:OffsetZ, Float:rX, Float:rY, Float:rZ)` |
| open.mp | `bool: AttachPlayerObjectToPlayer(playerid, objectid, parentid, Float:offsetX, Float:offsetY, Float:offsetZ, Float:rotationX, Float:rotationY, Float:rotationZ)` |

### `AttachPlayerObjectToVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AttachPlayerObjectToVehicle(playerid, objectid, vehicleid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:RotZ)` |
| open.mp | `bool: AttachPlayerObjectToVehicle(playerid, objectid, parentid, Float:offsetX, Float:offsetY, Float:offsetZ, Float:rotationX, Float:rotationY, Float:rotationZ)` |

### `AttachTrailerToVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` AttachTrailerToVehicle(trailerid, vehicleid)` |
| open.mp | `bool: AttachTrailerToVehicle(trailerid, vehicleid)` |

### `Ban`

| Target | Declaration |
|---|---|
| 0.3.7 | ` Ban(playerid)` |
| open.mp | `bool: Ban(playerid)` |

### `BanEx`

| Target | Declaration |
|---|---|
| 0.3.7 | ` BanEx(playerid, const reason[])` |
| open.mp | `bool: BanEx(playerid, const reason[])` |

### `BlockIpAddress`

| Target | Declaration |
|---|---|
| 0.3.7 | ` BlockIpAddress(const ip_address[], timems)` |
| open.mp | `bool: BlockIpAddress(const ipAddress[], timeMS)` |

### `CallLocalFunction`

| Target | Declaration |
|---|---|
| 0.3.7 | ` CallLocalFunction(const function[], const format[], {Float,_}:...)` |
| open.mp | ` CallLocalFunction(const functionName[], const specifiers[] = "", OPEN_MP_TAGS:...)` |

### `CallRemoteFunction`

| Target | Declaration |
|---|---|
| 0.3.7 | ` CallRemoteFunction(const function[], const format[], {Float,_}:...)` |
| open.mp | ` CallRemoteFunction(const functionName[], const specifiers[] = "", OPEN_MP_TAGS:...)` |

### `CancelSelectTextDraw`

| Target | Declaration |
|---|---|
| 0.3.7 | ` CancelSelectTextDraw(playerid)` |
| open.mp | `bool: CancelSelectTextDraw(playerid)` |

### `ChangeVehicleColor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ChangeVehicleColor(vehicleid, color1, color2)` |
| open.mp | `bool: ChangeVehicleColor(vehicleid, color1, color2)` |

### `ChangeVehiclePaintjob`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ChangeVehiclePaintjob(vehicleid, paintjobid)` |
| open.mp | `bool: ChangeVehiclePaintjob(vehicleid, paintjob)` |

### `ClearActorAnimations`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ClearActorAnimations(actorid)` |
| open.mp | `bool: ClearActorAnimations(actorid)` |

### `ClearAnimations`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ClearAnimations(playerid, forcesync = 0)` |
| open.mp | `bool: ClearAnimations(playerid, FORCE_SYNC:forceSync = SYNC_NONE)` |

### `Create3DTextLabel`

| Target | Declaration |
|---|---|
| 0.3.7 | `Text3D: Create3DTextLabel(const text[], color, Float:X, Float:Y, Float:Z, Float:DrawDistance, virtualworld, testLOS=0)` |
| open.mp | `Text3D: Create3DTextLabel(const text[], colour, Float:x, Float:y, Float:z, Float:drawDistance, virtualWorld, bool:testLOS = false, OPEN_MP_TAGS:...)` |

### `CreateExplosion`

| Target | Declaration |
|---|---|
| 0.3.7 | ` CreateExplosion(Float:X, Float:Y, Float:Z, type, Float:Radius)` |
| open.mp | `bool: CreateExplosion(Float:x, Float:y, Float:z, type, Float:radius)` |

### `CreateExplosionForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` CreateExplosionForPlayer(playerid, Float:X, Float:Y, Float:Z, type, Float:Radius)` |
| open.mp | `bool: CreateExplosionForPlayer(playerid, Float:x, Float:y, Float:z, type, Float:radius)` |

### `CreateMenu`

| Target | Declaration |
|---|---|
| 0.3.7 | `Menu: CreateMenu(const title[], columns, Float:x, Float:y, Float:col1width, Float:col2width = 0.0)` |
| open.mp | `Menu: CreateMenu(const title[], columns, Float:x, Float:y, Float:column1width, Float:column2width = 0.0, OPEN_MP_TAGS:...)` |

### `CreatePlayer3DTextLabel`

| Target | Declaration |
|---|---|
| 0.3.7 | `PlayerText3D: CreatePlayer3DTextLabel(playerid, const text[], color, Float:X, Float:Y, Float:Z, Float:DrawDistance, attachedplayer=INVALID_PLAYER_ID, attachedvehicle=INVALID_VEHICLE_ID, testLOS=0)` |
| open.mp | `PlayerText3D: CreatePlayer3DTextLabel(playerid, const text[], colour, Float:x, Float:y, Float:z, Float:drawDistance, parentPlayerid = INVALID_PLAYER_ID, parentVehicleid = INVALID_VEHICLE_ID, bool:testLOS = false, OPEN_MP_TAGS:...)` |

### `CreatePlayerTextDraw`

| Target | Declaration |
|---|---|
| 0.3.7 | `PlayerText: CreatePlayerTextDraw(playerid, Float:x, Float:y, const text[])` |
| open.mp | `PlayerText: CreatePlayerTextDraw(playerid, Float:x, Float:y, const format[], OPEN_MP_TAGS:...)` |

### `CreateVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren=0)` |
| open.mp | ` CreateVehicle(modelid, Float:spawnX, Float:spawnY, Float:spawnZ, Float:angle, colour1, colour2, respawnDelay, bool:addSiren = false)` |

### `Delete3DTextLabel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` Delete3DTextLabel(Text3D:id)` |
| open.mp | `bool: Delete3DTextLabel(Text3D:textid)` |

### `DeletePlayer3DTextLabel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DeletePlayer3DTextLabel(playerid, PlayerText3D:id)` |
| open.mp | `bool: DeletePlayer3DTextLabel(playerid, PlayerText3D:textid)` |

### `DeletePVar`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DeletePVar(playerid, const varname[])` |
| open.mp | `bool: DeletePVar(playerid, const pvar[])` |

### `DeleteSVar`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DeleteSVar(const varname[])` |
| open.mp | `bool: DeleteSVar(const svar[])` |

### `DestroyActor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DestroyActor(actorid)` |
| open.mp | `bool: DestroyActor(actorid)` |

### `DestroyMenu`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DestroyMenu(Menu:menuid)` |
| open.mp | `bool: DestroyMenu(Menu:menuid)` |

### `DestroyObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DestroyObject(objectid)` |
| open.mp | `bool: DestroyObject(objectid)` |

### `DestroyPickup`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DestroyPickup(pickup)` |
| open.mp | `bool: DestroyPickup(pickup)` |

### `DestroyPlayerObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DestroyPlayerObject(playerid, objectid)` |
| open.mp | `bool: DestroyPlayerObject(playerid, objectid)` |

### `DestroyVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DestroyVehicle(vehicleid)` |
| open.mp | `bool: DestroyVehicle(vehicleid)` |

### `DetachTrailerFromVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DetachTrailerFromVehicle(vehicleid)` |
| open.mp | `bool: DetachTrailerFromVehicle(vehicleid)` |

### `DisableInteriorEnterExits`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DisableInteriorEnterExits()` |
| open.mp | `void: DisableInteriorEnterExits()` |

### `DisableMenu`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DisableMenu(Menu:menuid)` |
| open.mp | `bool: DisableMenu(Menu:menuid)` |

### `DisableMenuRow`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DisableMenuRow(Menu:menuid, row)` |
| open.mp | `bool: DisableMenuRow(Menu:menuid, row)` |

### `DisableNameTagLOS`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DisableNameTagLOS()` |
| open.mp | `void: DisableNameTagLOS()` |

### `DisablePlayerCheckpoint`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DisablePlayerCheckpoint(playerid)` |
| open.mp | `bool: DisablePlayerCheckpoint(playerid)` |

### `DisablePlayerRaceCheckpoint`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DisablePlayerRaceCheckpoint(playerid)` |
| open.mp | `bool: DisablePlayerRaceCheckpoint(playerid)` |

### `DisableRemoteVehicleCollisions`

| Target | Declaration |
|---|---|
| 0.3.7 | ` DisableRemoteVehicleCollisions(playerid, disable)` |
| open.mp | `bool: DisableRemoteVehicleCollisions(playerid, bool:disable)` |

### `EditAttachedObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` EditAttachedObject(playerid, index)` |
| open.mp | `bool: EditAttachedObject(playerid, index)` |

### `EnablePlayerCameraTarget`

| Target | Declaration |
|---|---|
| 0.3.7 | ` EnablePlayerCameraTarget(playerid, enable)` |
| open.mp | `bool: EnablePlayerCameraTarget(playerid, bool:enable)` |

### `EnableStuntBonusForAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` EnableStuntBonusForAll(enable)` |
| open.mp | `void: EnableStuntBonusForAll(bool:enable)` |

### `EnableStuntBonusForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` EnableStuntBonusForPlayer(playerid, enable)` |
| open.mp | `bool: EnableStuntBonusForPlayer(playerid, bool:enable)` |

### `EnableTirePopping`

| Target | Declaration |
|---|---|
| 0.3.7 | ` EnableTirePopping(enable)` |
| open.mp | `void: EnableTirePopping(bool:enable)` |

### `EnableVehicleFriendlyFire`

| Target | Declaration |
|---|---|
| 0.3.7 | ` EnableVehicleFriendlyFire()` |
| open.mp | `void: EnableVehicleFriendlyFire()` |

### `EnableZoneNames`

| Target | Declaration |
|---|---|
| 0.3.7 | ` EnableZoneNames(enable)` |
| open.mp | `void: EnableZoneNames(bool:enable)` |

### `ForceClassSelection`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ForceClassSelection(playerid)` |
| open.mp | `bool: ForceClassSelection(playerid)` |

### `format`

| Target | Declaration |
|---|---|
| 0.3.7 | ` format(output[], len = sizeof output, const format[], {Float,_}:...)` |
| open.mp | ` format(output[], len = sizeof (output), const format[], {Float, _}:...)` |

### `GameModeExit`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GameModeExit()` |
| open.mp | `void: GameModeExit()` |

### `GameTextForAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GameTextForAll(const string[], time, style)` |
| open.mp | `bool: GameTextForAll(const format[], time, style, OPEN_MP_TAGS:...)` |

### `GameTextForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GameTextForPlayer(playerid, const string[], time, style)` |
| open.mp | `bool: GameTextForPlayer(playerid, const format[], time, style, OPEN_MP_TAGS:...)` |

### `GangZoneDestroy`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneDestroy(zone)` |
| open.mp | `bool: GangZoneDestroy(zoneid)` |

### `GangZoneFlashForAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneFlashForAll(zone, flashcolor)` |
| open.mp | `bool: GangZoneFlashForAll(zoneid, flashColour)` |

### `GangZoneFlashForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneFlashForPlayer(playerid, zone, flashcolor)` |
| open.mp | `bool: GangZoneFlashForPlayer(playerid, zoneid, flashColour)` |

### `GangZoneHideForAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneHideForAll(zone)` |
| open.mp | `bool: GangZoneHideForAll(zoneid)` |

### `GangZoneHideForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneHideForPlayer(playerid, zone)` |
| open.mp | `bool: GangZoneHideForPlayer(playerid, zoneid)` |

### `GangZoneShowForAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneShowForAll(zone, color)` |
| open.mp | `bool: GangZoneShowForAll(zoneid, colour)` |

### `GangZoneShowForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneShowForPlayer(playerid, zone, color)` |
| open.mp | `bool: GangZoneShowForPlayer(playerid, zoneid, colour)` |

### `GangZoneStopFlashForAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneStopFlashForAll(zone)` |
| open.mp | `bool: GangZoneStopFlashForAll(zoneid)` |

### `GangZoneStopFlashForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GangZoneStopFlashForPlayer(playerid, zone)` |
| open.mp | `bool: GangZoneStopFlashForPlayer(playerid, zoneid)` |

### `GetActorFacingAngle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetActorFacingAngle(actorid, &Float:ang)` |
| open.mp | `bool: GetActorFacingAngle(actorid, &Float:angle)` |

### `GetActorHealth`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetActorHealth(actorid, &Float:health)` |
| open.mp | `bool: GetActorHealth(actorid, &Float:health)` |

### `GetActorPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetActorPos(actorid, &Float:X, &Float:Y, &Float:Z)` |
| open.mp | `bool: GetActorPos(actorid, &Float:x, &Float:y, &Float:z)` |

### `GetConsoleVarAsBool`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetConsoleVarAsBool(const varname[])` |
| open.mp | `bool: GetConsoleVarAsBool(const cvar[])` |

### `GetNetworkStats`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetNetworkStats(retstr[], retstr_size = sizeof retstr)` |
| open.mp | `bool: GetNetworkStats(output[], size = sizeof (output))` |

### `GetObjectPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetObjectPos(objectid, &Float:X, &Float:Y, &Float:Z)` |
| open.mp | `bool: GetObjectPos(objectid, &Float:x, &Float:y, &Float:z)` |

### `GetObjectRot`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetObjectRot(objectid, &Float:RotX, &Float:RotY, &Float:RotZ)` |
| open.mp | `bool: GetObjectRot(objectid, &Float:rotationX, &Float:rotationY, &Float:rotationZ)` |

### `GetPlayerArmour`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerArmour(playerid, &Float:armour)` |
| open.mp | `bool: GetPlayerArmour(playerid, &Float:armour)` |

### `GetPlayerCameraFrontVector`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerCameraFrontVector(playerid, &Float:x, &Float:y, &Float:z)` |
| open.mp | `bool: GetPlayerCameraFrontVector(playerid, &Float:x, &Float:y, &Float:z)` |

### `GetPlayerCameraMode`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerCameraMode(playerid)` |
| open.mp | `CAM_MODE: GetPlayerCameraMode(playerid)` |

### `GetPlayerCameraPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerCameraPos(playerid, &Float:x, &Float:y, &Float:z)` |
| open.mp | `bool: GetPlayerCameraPos(playerid, &Float:x, &Float:y, &Float:z)` |

### `GetPlayerFacingAngle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerFacingAngle(playerid, &Float:ang)` |
| open.mp | `bool: GetPlayerFacingAngle(playerid, &Float:angle)` |

### `GetPlayerFightingStyle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerFightingStyle(playerid)` |
| open.mp | `FIGHT_STYLE: GetPlayerFightingStyle(playerid)` |

### `GetPlayerHealth`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerHealth(playerid, &Float:health)` |
| open.mp | `bool: GetPlayerHealth(playerid, &Float:health)` |

### `GetPlayerKeys`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerKeys(playerid, &keys, &updown, &leftright)` |
| open.mp | `bool: GetPlayerKeys(playerid, &KEY:keys, &updown, &leftright)` |

### `GetPlayerLastShotVectors`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerLastShotVectors(playerid, &Float:fOriginX, &Float:fOriginY, &Float:fOriginZ, &Float:fHitPosX, &Float:fHitPosY, &Float:fHitPosZ)` |
| open.mp | `bool: GetPlayerLastShotVectors(playerid, &Float:originX, &Float:originY, &Float:originZ, &Float:hitPosX, &Float:hitPosY, &Float:hitPosZ)` |

### `GetPlayerNetworkStats`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerNetworkStats(playerid, retstr[], retstr_size = sizeof retstr)` |
| open.mp | `bool: GetPlayerNetworkStats(playerid, output[], size = sizeof (output))` |

### `GetPlayerObjectPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerObjectPos(playerid, objectid, &Float:X, &Float:Y, &Float:Z)` |
| open.mp | `bool: GetPlayerObjectPos(playerid, objectid, &Float:x, &Float:y, &Float:z)` |

### `GetPlayerObjectRot`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerObjectRot(playerid, objectid, &Float:RotX, &Float:RotY, &Float:RotZ)` |
| open.mp | `bool: GetPlayerObjectRot(playerid, objectid, &Float:rotationX, &Float:rotationY, &Float:rotationZ)` |

### `GetPlayerPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerPos(playerid, &Float:x, &Float:y, &Float:z)` |
| open.mp | `bool: GetPlayerPos(playerid, &Float:x, &Float:y, &Float:z)` |

### `GetPlayerSpecialAction`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerSpecialAction(playerid)` |
| open.mp | `SPECIAL_ACTION: GetPlayerSpecialAction(playerid)` |

### `GetPlayerState`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerState(playerid)` |
| open.mp | `PLAYER_STATE: GetPlayerState(playerid)` |

### `GetPlayerTime`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerTime(playerid, &hour, &minute)` |
| open.mp | `bool: GetPlayerTime(playerid, &hour, &minute)` |

### `GetPlayerVelocity`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerVelocity(playerid, &Float:X, &Float:Y, &Float:Z)` |
| open.mp | `bool: GetPlayerVelocity(playerid, &Float:x, &Float:y, &Float:z)` |

### `GetPlayerWeapon`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerWeapon(playerid)` |
| open.mp | `WEAPON: GetPlayerWeapon(playerid)` |

### `GetPlayerWeaponData`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerWeaponData(playerid, slot, &weapons, &ammo)` |
| open.mp | `bool: GetPlayerWeaponData(playerid, WEAPON_SLOT:slot, &WEAPON:weapon, &ammo)` |

### `GetPlayerWeaponState`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPlayerWeaponState(playerid)` |
| open.mp | `WEAPONSTATE: GetPlayerWeaponState(playerid)` |

### `GetPVarType`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetPVarType(playerid, const varname[])` |
| open.mp | `VARTYPE: GetPVarType(playerid, const pvar[])` |

### `GetSVarType`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetSVarType(const varname[])` |
| open.mp | `VARTYPE: GetSVarType(const svar[])` |

### `GetVehicleComponentInSlot`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleComponentInSlot(vehicleid, slot)` |
| open.mp | ` GetVehicleComponentInSlot(vehicleid, CARMODTYPE:slot)` |

### `GetVehicleComponentType`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleComponentType(component)` |
| open.mp | `CARMODTYPE: GetVehicleComponentType(component)` |

### `GetVehicleDamageStatus`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleDamageStatus(vehicleid, &panels, &doors, &lights, &tires)` |
| open.mp | `bool: GetVehicleDamageStatus(vehicleid, &VEHICLE_PANEL_STATUS:panels, &VEHICLE_DOOR_STATUS:doors, &VEHICLE_LIGHT_STATUS:lights, &VEHICLE_TYRE_STATUS:tyres)` |

### `GetVehicleHealth`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleHealth(vehicleid, &Float:health)` |
| open.mp | `bool: GetVehicleHealth(vehicleid, &Float:health)` |

### `GetVehicleModelInfo`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleModelInfo(vehiclemodel, infotype, &Float:X, &Float:Y, &Float:Z)` |
| open.mp | `bool: GetVehicleModelInfo(vehiclemodel, VEHICLE_MODEL_INFO:infotype, &Float:x, &Float:y, &Float:z)` |

### `GetVehicleParamsCarDoors`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleParamsCarDoors(vehicleid, &driver, &passenger, &backleft, &backright)` |
| open.mp | `bool: GetVehicleParamsCarDoors(vehicleid, &frontLeft = -1, &frontRight = -1, &rearLeft = -1, &rearRight = -1)` |

### `GetVehicleParamsCarWindows`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleParamsCarWindows(vehicleid, &driver, &passenger, &backleft, &backright)` |
| open.mp | `bool: GetVehicleParamsCarWindows(vehicleid, &frontLeft = -1, &frontRight = -1, &rearLeft = -1, &rearRight = -1)` |

### `GetVehicleParamsEx`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleParamsEx(vehicleid, &engine, &lights, &alarm, &doors, &bonnet, &boot, &objective)` |
| open.mp | `bool: GetVehicleParamsEx(vehicleid, &engine = -1, &lights = -1, &alarm = -1, &doors = -1, &bonnet = -1, &boot = -1, &objective = -1)` |

### `GetVehiclePos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehiclePos(vehicleid, &Float:x, &Float:y, &Float:z)` |
| open.mp | `bool: GetVehiclePos(vehicleid, &Float:x, &Float:y, &Float:z)` |

### `GetVehicleRotationQuat`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleRotationQuat(vehicleid, &Float:w, &Float:x, &Float:y, &Float:z)` |
| open.mp | `bool: GetVehicleRotationQuat(vehicleid, &Float:w, &Float:x, &Float:y, &Float:z)` |

### `GetVehicleVelocity`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleVelocity(vehicleid, &Float:X, &Float:Y, &Float:Z)` |
| open.mp | `bool: GetVehicleVelocity(vehicleid, &Float:x, &Float:y, &Float:z)` |

### `GetVehicleZAngle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetVehicleZAngle(vehicleid, &Float:z_angle)` |
| open.mp | `bool: GetVehicleZAngle(vehicleid, &Float:angle)` |

### `GetWeaponName`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GetWeaponName(weaponid, weapon[], len = sizeof weapon)` |
| open.mp | ` GetWeaponName(WEAPON:weaponid, weapon[], len = sizeof (weapon))` |

### `GivePlayerMoney`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GivePlayerMoney(playerid, money)` |
| open.mp | `bool: GivePlayerMoney(playerid, money)` |

### `GivePlayerWeapon`

| Target | Declaration |
|---|---|
| 0.3.7 | ` GivePlayerWeapon(playerid, weaponid, ammo)` |
| open.mp | `bool: GivePlayerWeapon(playerid, WEAPON:weaponid, ammo)` |

### `HideMenuForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` HideMenuForPlayer(Menu:menuid, playerid)` |
| open.mp | `bool: HideMenuForPlayer(Menu:menuid, playerid)` |

### `HTTP`

| Target | Declaration |
|---|---|
| 0.3.7 | ` HTTP(index, type, const url[], const data[], const callback[])` |
| open.mp | ` HTTP(index, HTTP_METHOD:method, const url[], const data[], const callback[])` |

### `InterpolateCameraLookAt`

| Target | Declaration |
|---|---|
| 0.3.7 | ` InterpolateCameraLookAt(playerid, Float:FromX, Float:FromY, Float:FromZ, Float:ToX, Float:ToY, Float:ToZ, time, cut = CAMERA_CUT)` |
| open.mp | `bool: InterpolateCameraLookAt(playerid, Float:fromX, Float:fromY, Float:fromZ, Float:toX, Float:toY, Float:toZ, time, CAM_MOVE:cut = CAMERA_CUT)` |

### `InterpolateCameraPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` InterpolateCameraPos(playerid, Float:FromX, Float:FromY, Float:FromZ, Float:ToX, Float:ToY, Float:ToZ, time, cut = CAMERA_CUT)` |
| open.mp | `bool: InterpolateCameraPos(playerid, Float:fromX, Float:fromY, Float:fromZ, Float:toX, Float:toY, Float:toZ, time, CAM_MOVE:cut = CAMERA_CUT)` |

### `IsActorInvulnerable`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsActorInvulnerable(actorid)` |
| open.mp | `bool: IsActorInvulnerable(actorid)` |

### `IsActorStreamedIn`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsActorStreamedIn(actorid, forplayerid)` |
| open.mp | `bool: IsActorStreamedIn(actorid, playerid)` |

### `IsObjectMoving`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsObjectMoving(objectid)` |
| open.mp | `bool: IsObjectMoving(objectid)` |

### `IsPlayerAdmin`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerAdmin(playerid)` |
| open.mp | `bool: IsPlayerAdmin(playerid)` |

### `IsPlayerAttachedObjectSlotUsed`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerAttachedObjectSlotUsed(playerid, index)` |
| open.mp | `bool: IsPlayerAttachedObjectSlotUsed(playerid, index)` |

### `IsPlayerConnected`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerConnected(playerid)` |
| open.mp | `bool: IsPlayerConnected(playerid)` |

### `IsPlayerInAnyVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerInAnyVehicle(playerid)` |
| open.mp | `bool: IsPlayerInAnyVehicle(playerid)` |

### `IsPlayerInCheckpoint`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerInCheckpoint(playerid)` |
| open.mp | `bool: IsPlayerInCheckpoint(playerid)` |

### `IsPlayerInRaceCheckpoint`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerInRaceCheckpoint(playerid)` |
| open.mp | `bool: IsPlayerInRaceCheckpoint(playerid)` |

### `IsPlayerInRangeOfPoint`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerInRangeOfPoint(playerid, Float:range, Float:x, Float:y, Float:z)` |
| open.mp | `bool: IsPlayerInRangeOfPoint(playerid, Float:range, Float:x, Float:y, Float:z)` |

### `IsPlayerInVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerInVehicle(playerid, vehicleid)` |
| open.mp | `bool: IsPlayerInVehicle(playerid, vehicleid)` |

### `IsPlayerNPC`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerNPC(playerid)` |
| open.mp | `bool: IsPlayerNPC(playerid)` |

### `IsPlayerObjectMoving`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerObjectMoving(playerid, objectid)` |
| open.mp | `bool: IsPlayerObjectMoving(playerid, objectid)` |

### `IsPlayerStreamedIn`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsPlayerStreamedIn(playerid, forplayerid)` |
| open.mp | `bool: IsPlayerStreamedIn(targetid, playerid)` |

### `IsTrailerAttachedToVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsTrailerAttachedToVehicle(vehicleid)` |
| open.mp | `bool: IsTrailerAttachedToVehicle(vehicleid)` |

### `IsValidActor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsValidActor(actorid)` |
| open.mp | `bool: IsValidActor(actorid)` |

### `IsValidMenu`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsValidMenu(Menu:menuid)` |
| open.mp | `bool: IsValidMenu(Menu:menuid)` |

### `IsValidObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsValidObject(objectid)` |
| open.mp | `bool: IsValidObject(objectid)` |

### `IsValidPlayerObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsValidPlayerObject(playerid, objectid)` |
| open.mp | `bool: IsValidPlayerObject(playerid, objectid)` |

### `IsVehicleStreamedIn`

| Target | Declaration |
|---|---|
| 0.3.7 | ` IsVehicleStreamedIn(vehicleid, forplayerid)` |
| open.mp | `bool: IsVehicleStreamedIn(vehicleid, playerid)` |

### `Kick`

| Target | Declaration |
|---|---|
| 0.3.7 | ` Kick(playerid)` |
| open.mp | `bool: Kick(playerid)` |

### `KillTimer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` KillTimer(timerid)` |
| open.mp | `bool: KillTimer(timerid)` |

### `LimitGlobalChatRadius`

| Target | Declaration |
|---|---|
| 0.3.7 | ` LimitGlobalChatRadius(Float:chat_radius)` |
| open.mp | `bool: LimitGlobalChatRadius(Float:chatRadius)` |

### `LimitPlayerMarkerRadius`

| Target | Declaration |
|---|---|
| 0.3.7 | ` LimitPlayerMarkerRadius(Float:marker_radius)` |
| open.mp | `bool: LimitPlayerMarkerRadius(Float:markerRadius)` |

### `LinkVehicleToInterior`

| Target | Declaration |
|---|---|
| 0.3.7 | ` LinkVehicleToInterior(vehicleid, interiorid)` |
| open.mp | `bool: LinkVehicleToInterior(vehicleid, interiorid)` |

### `ManualVehicleEngineAndLights`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ManualVehicleEngineAndLights()` |
| open.mp | `void: ManualVehicleEngineAndLights()` |

### `MoveObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` MoveObject(objectid, Float:X, Float:Y, Float:Z, Float:Speed, Float:RotX = -1000.0, Float:RotY = -1000.0, Float:RotZ = -1000.0)` |
| open.mp | `bool: MoveObject(objectid, Float:targetX, Float:targetY, Float:targetZ, Float:speed, Float:rotationX = -1000.0, Float:rotationY = -1000.0, Float:rotationZ = -1000.0)` |

### `MovePlayerObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` MovePlayerObject(playerid, objectid, Float:X, Float:Y, Float:Z, Float:Speed, Float:RotX = -1000.0, Float:RotY = -1000.0, Float:RotZ = -1000.0)` |
| open.mp | `bool: MovePlayerObject(playerid, objectid, Float:targetX, Float:targetY, Float:targetZ, Float:speed, Float:rotationX = -1000.0, Float:rotationY = -1000.0, Float:rotationZ = -1000.0)` |

### `NetStats_ConnectionStatus`

| Target | Declaration |
|---|---|
| 0.3.7 | ` NetStats_ConnectionStatus(playerid)` |
| open.mp | `CONNECTION_STATUS: NetStats_ConnectionStatus(playerid)` |

### `OnPlayerClickPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerClickPlayer(playerid, clickedplayerid, source)` |
| open.mp | ` OnPlayerClickPlayer(playerid, clickedplayerid, CLICK_SOURCE:source)` |

### `OnPlayerDeath`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerDeath(playerid, killerid, reason)` |
| open.mp | ` OnPlayerDeath(playerid, killerid, WEAPON:reason)` |

### `OnPlayerEditAttachedObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)` |
| open.mp | ` OnPlayerEditAttachedObject(playerid, EDIT_RESPONSE:response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)` |

### `OnPlayerEditObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)` |
| open.mp | ` OnPlayerEditObject(playerid, playerobject, objectid, EDIT_RESPONSE:response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)` |

### `OnPlayerGiveDamage`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)` |
| open.mp | ` OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)` |

### `OnPlayerGiveDamageActor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerGiveDamageActor(playerid, damaged_actorid, Float:amount, weaponid, bodypart)` |
| open.mp | ` OnPlayerGiveDamageActor(playerid, damaged_actorid, Float:amount, WEAPON:weaponid, bodypart)` |

### `OnPlayerKeyStateChange`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerKeyStateChange(playerid, newkeys, oldkeys)` |
| open.mp | ` OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)` |

### `OnPlayerRequestDownload`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerRequestDownload(playerid, type, crc)` |
| open.mp | ` OnPlayerRequestDownload(playerid, DOWNLOAD_REQUEST:type, crc)` |

### `OnPlayerSelectObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ)` |
| open.mp | ` OnPlayerSelectObject(playerid, SELECT_OBJECT:type, objectid, modelid, Float:fX, Float:fY, Float:fZ)` |

### `OnPlayerStateChange`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerStateChange(playerid, newstate, oldstate)` |
| open.mp | ` OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)` |

### `OnPlayerTakeDamage`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)` |
| open.mp | ` OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)` |

### `OnPlayerWeaponShot`

| Target | Declaration |
|---|---|
| 0.3.7 | ` OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)` |
| open.mp | ` OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)` |

### `PlayAudioStreamForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayAudioStreamForPlayer(playerid, const url[], Float:posX = 0.0, Float:posY = 0.0, Float:posZ = 0.0, Float:distance = 50.0, usepos = 0)` |
| open.mp | `bool: PlayAudioStreamForPlayer(playerid, const url[], Float:posX = 0.0, Float:posY = 0.0, Float:posZ = 0.0, Float:distance = 50.0, bool:usepos = false)` |

### `PlayCrimeReportForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayCrimeReportForPlayer(playerid, suspectid, crime)` |
| open.mp | `bool: PlayCrimeReportForPlayer(playerid, suspectid, crime)` |

### `PlayerPlaySound`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerPlaySound(playerid, soundid, Float:x, Float:y, Float:z)` |
| open.mp | `bool: PlayerPlaySound(playerid, soundid, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0)` |

### `PlayerSpectatePlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerSpectatePlayer(playerid, targetplayerid, mode = SPECTATE_MODE_NORMAL)` |
| open.mp | `bool: PlayerSpectatePlayer(playerid, targetid, SPECTATE_MODE:mode = SPECTATE_MODE_NORMAL)` |

### `PlayerSpectateVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerSpectateVehicle(playerid, targetvehicleid, mode = SPECTATE_MODE_NORMAL)` |
| open.mp | `bool: PlayerSpectateVehicle(playerid, targetid, SPECTATE_MODE:mode = SPECTATE_MODE_NORMAL)` |

### `PlayerTextDrawAlignment`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawAlignment(playerid, PlayerText:text, alignment)` |
| open.mp | `bool: PlayerTextDrawAlignment(playerid, PlayerText:textid, TEXT_DRAW_ALIGN:alignment)` |

### `PlayerTextDrawBackgroundColor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawBackgroundColor(playerid, PlayerText:text, color)` |
| open.mp | `bool: PlayerTextDrawBackgroundColor(playerid, PlayerText:textid, backgroundColor)` |

### `PlayerTextDrawBoxColor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawBoxColor(playerid, PlayerText:text, color)` |
| open.mp | `bool: PlayerTextDrawBoxColor(playerid, PlayerText:textid, boxColor)` |

### `PlayerTextDrawColor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawColor(playerid, PlayerText:text, color)` |
| open.mp | `bool: PlayerTextDrawColor(playerid, PlayerText:textid, textColor)` |

### `PlayerTextDrawDestroy`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawDestroy(playerid, PlayerText:text)` |
| open.mp | `bool: PlayerTextDrawDestroy(playerid, PlayerText:textid)` |

### `PlayerTextDrawFont`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawFont(playerid, PlayerText:text, font)` |
| open.mp | `bool: PlayerTextDrawFont(playerid, PlayerText:textid, TEXT_DRAW_FONT:font)` |

### `PlayerTextDrawHide`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawHide(playerid, PlayerText:text)` |
| open.mp | `bool: PlayerTextDrawHide(playerid, PlayerText:textid)` |

### `PlayerTextDrawLetterSize`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawLetterSize(playerid, PlayerText:text, Float:x, Float:y)` |
| open.mp | `bool: PlayerTextDrawLetterSize(playerid, PlayerText:textid, Float:width, Float:height)` |

### `PlayerTextDrawSetOutline`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawSetOutline(playerid, PlayerText:text, size)` |
| open.mp | `bool: PlayerTextDrawSetOutline(playerid, PlayerText:textid, outlineSize)` |

### `PlayerTextDrawSetPreviewModel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawSetPreviewModel(playerid, PlayerText:text, modelindex)` |
| open.mp | `bool: PlayerTextDrawSetPreviewModel(playerid, PlayerText:textid, model)` |

### `PlayerTextDrawSetPreviewRot`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawSetPreviewRot(playerid, PlayerText:text, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fZoom = 1.0)` |
| open.mp | `bool: PlayerTextDrawSetPreviewRot(playerid, PlayerText:textid, Float:rotX, Float:rotY, Float:rotZ, Float:zoom = 1.0)` |

### `PlayerTextDrawSetPreviewVehCol`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawSetPreviewVehCol(playerid, PlayerText:text, color1, color2)` |
| open.mp | `bool: PlayerTextDrawSetPreviewVehCol(playerid, PlayerText:textid, colour1, colour2)` |

### `PlayerTextDrawSetProportional`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawSetProportional(playerid, PlayerText:text, set)` |
| open.mp | `bool: PlayerTextDrawSetProportional(playerid, PlayerText:textid, bool:proportional)` |

### `PlayerTextDrawSetSelectable`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawSetSelectable(playerid, PlayerText:text, set)` |
| open.mp | `bool: PlayerTextDrawSetSelectable(playerid, PlayerText:textid, bool:selectable)` |

### `PlayerTextDrawSetShadow`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawSetShadow(playerid, PlayerText:text, size)` |
| open.mp | `bool: PlayerTextDrawSetShadow(playerid, PlayerText:textid, shadowSize)` |

### `PlayerTextDrawSetString`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawSetString(playerid, PlayerText:text, const string[])` |
| open.mp | `bool: PlayerTextDrawSetString(playerid, PlayerText:textid, const format[], OPEN_MP_TAGS:...)` |

### `PlayerTextDrawShow`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawShow(playerid, PlayerText:text)` |
| open.mp | `bool: PlayerTextDrawShow(playerid, PlayerText:textid)` |

### `PlayerTextDrawTextSize`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawTextSize(playerid, PlayerText:text, Float:x, Float:y)` |
| open.mp | `bool: PlayerTextDrawTextSize(playerid, PlayerText:textid, Float:width, Float:height)` |

### `PlayerTextDrawUseBox`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PlayerTextDrawUseBox(playerid, PlayerText:text, use)` |
| open.mp | `bool: PlayerTextDrawUseBox(playerid, PlayerText:textid, bool:boxEnabled)` |

### `printf`

| Target | Declaration |
|---|---|
| 0.3.7 | ` printf(const format[], {Float,_}:...)` |
| open.mp | ` printf(const format[], {Float, _}:...)` |

### `PutPlayerInVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` PutPlayerInVehicle(playerid, vehicleid, seatid)` |
| open.mp | `bool: PutPlayerInVehicle(playerid, vehicleid, seatid)` |

### `RedirectDownload`

| Target | Declaration |
|---|---|
| 0.3.7 | ` RedirectDownload(playerid, const url[])` |
| open.mp | `bool: RedirectDownload(playerid, const url[])` |

### `RemoveBuildingForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` RemoveBuildingForPlayer(playerid, modelid, Float:fX, Float:fY, Float:fZ, Float:fRadius)` |
| open.mp | `bool: RemoveBuildingForPlayer(playerid, modelid, Float:centerX, Float:centerY, Float:centerZ, Float:radius)` |

### `RemovePlayerAttachedObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` RemovePlayerAttachedObject(playerid, index)` |
| open.mp | `bool: RemovePlayerAttachedObject(playerid, index)` |

### `RemovePlayerFromVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` RemovePlayerFromVehicle(playerid)` |
| open.mp | `bool: RemovePlayerFromVehicle(playerid, bool:force = false)` |

### `RemovePlayerMapIcon`

| Target | Declaration |
|---|---|
| 0.3.7 | ` RemovePlayerMapIcon(playerid, iconid)` |
| open.mp | `bool: RemovePlayerMapIcon(playerid, iconid)` |

### `RemoveVehicleComponent`

| Target | Declaration |
|---|---|
| 0.3.7 | ` RemoveVehicleComponent(vehicleid, componentid)` |
| open.mp | `bool: RemoveVehicleComponent(vehicleid, component)` |

### `RepairVehicle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` RepairVehicle(vehicleid)` |
| open.mp | `bool: RepairVehicle(vehicleid)` |

### `ResetPlayerMoney`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ResetPlayerMoney(playerid)` |
| open.mp | `bool: ResetPlayerMoney(playerid)` |

### `ResetPlayerWeapons`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ResetPlayerWeapons(playerid)` |
| open.mp | `bool: ResetPlayerWeapons(playerid)` |

### `SelectTextDraw`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SelectTextDraw(playerid, hovercolor)` |
| open.mp | `bool: SelectTextDraw(playerid, hoverColor)` |

### `SendClientCheck`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SendClientCheck(playerid, type, memAddr, memOffset, byteCount)` |
| open.mp | `bool: SendClientCheck(playerid, type, memoryAddress, memoryOffset, byteCount)` |

### `SendClientMessage`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SendClientMessage(playerid, color, const message[])` |
| open.mp | `bool: SendClientMessage(playerid, colour, const format[], OPEN_MP_TAGS:...)` |

### `SendClientMessageToAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SendClientMessageToAll(color, const message[])` |
| open.mp | `bool: SendClientMessageToAll(colour, const format[], OPEN_MP_TAGS:...)` |

### `SendDeathMessage`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SendDeathMessage(killer, killee, weapon)` |
| open.mp | `bool: SendDeathMessage(killer, killee, weapon)` |

### `SendDeathMessageToPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SendDeathMessageToPlayer(playerid, killer, killee, weapon)` |
| open.mp | `bool: SendDeathMessageToPlayer(playerid, killer, killee, weapon)` |

### `SendPlayerMessageToAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SendPlayerMessageToAll(senderid, const message[])` |
| open.mp | `bool: SendPlayerMessageToAll(senderid, const format[], OPEN_MP_TAGS:...)` |

### `SendPlayerMessageToPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SendPlayerMessageToPlayer(playerid, senderid, const message[])` |
| open.mp | `bool: SendPlayerMessageToPlayer(playerid, senderid, const format[], OPEN_MP_TAGS:...)` |

### `SendRconCommand`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SendRconCommand(const command[])` |
| open.mp | `bool: SendRconCommand(const format[], OPEN_MP_TAGS:...)` |

### `SetActorFacingAngle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetActorFacingAngle(actorid, Float:ang)` |
| open.mp | `bool: SetActorFacingAngle(actorid, Float:angle)` |

### `SetActorHealth`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetActorHealth(actorid, Float:health)` |
| open.mp | `bool: SetActorHealth(actorid, Float:health)` |

### `SetActorInvulnerable`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetActorInvulnerable(actorid, invulnerable = true)` |
| open.mp | `bool: SetActorInvulnerable(actorid, bool:invulnerable = true)` |

### `SetActorPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetActorPos(actorid, Float:X, Float:Y, Float:Z)` |
| open.mp | `bool: SetActorPos(actorid, Float:x, Float:y, Float:z)` |

### `SetActorVirtualWorld`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetActorVirtualWorld(actorid, vworld)` |
| open.mp | `bool: SetActorVirtualWorld(actorid, virtualWorld)` |

### `SetCameraBehindPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetCameraBehindPlayer(playerid)` |
| open.mp | `bool: SetCameraBehindPlayer(playerid)` |

### `SetDeathDropAmount`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetDeathDropAmount(amount)` |
| open.mp | `void: SetDeathDropAmount(amount)` |

### `SetGameModeText`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetGameModeText(const string[])` |
| open.mp | `bool: SetGameModeText(const format[], OPEN_MP_TAGS:...)` |

### `SetGravity`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetGravity(Float:gravity)` |
| open.mp | `void: SetGravity(Float:gravity)` |

### `SetMenuColumnHeader`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetMenuColumnHeader(Menu:menuid, column, const columnheader[])` |
| open.mp | `bool: SetMenuColumnHeader(Menu:menuid, column, const heading[], OPEN_MP_TAGS:...)` |

### `SetNameTagDrawDistance`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetNameTagDrawDistance(Float:distance)` |
| open.mp | `void: SetNameTagDrawDistance(Float:distance)` |

### `SetObjectMaterial`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetObjectMaterial(objectid, materialindex, modelid, const txdname[], const texturename[], materialcolor=0)` |
| open.mp | `bool: SetObjectMaterial(objectid, materialIndex, modelid, const textureLibrary[], const textureName[], materialColour = 0)` |

### `SetObjectMaterialText`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetObjectMaterialText(objectid, const text[], materialindex = 0, materialsize = OBJECT_MATERIAL_SIZE_256x128, const fontface[] = "Arial", fontsize = 24, bold = 1, fontcolor = 0xFFFFFFFF, backcolor = 0, textalignment = 0)` |
| open.mp | `bool: SetObjectMaterialText(objectid, const text[], materialIndex = 0, OBJECT_MATERIAL_SIZE:materialSize = OBJECT_MATERIAL_SIZE_256x128, const fontFace[] = "Arial", fontSize = 24, bool:bold = true, fontColour = 0xFFFFFFFF, backgroundColour = 0, OBJECT_MATERIAL_TEXT_ALIGN:textAlignment = OBJECT_MATERIAL_TEXT_ALIGN_LEFT, OPEN_MP_TAGS:...)` |

### `SetObjectNoCameraCol`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetObjectNoCameraCol(objectid)` |
| open.mp | `bool: SetObjectNoCameraCol(objectid)` |

### `SetObjectPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetObjectPos(objectid, Float:X, Float:Y, Float:Z)` |
| open.mp | `bool: SetObjectPos(objectid, Float:x, Float:y, Float:z)` |

### `SetObjectRot`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetObjectRot(objectid, Float:RotX, Float:RotY, Float:RotZ)` |
| open.mp | `bool: SetObjectRot(objectid, Float:rotationX, Float:rotationY, Float:rotationZ)` |

### `SetObjectsDefaultCameraCol`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetObjectsDefaultCameraCol(disable)` |
| open.mp | `bool: SetObjectsDefaultCameraCol(bool:disable)` |

### `SetPlayerAmmo`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerAmmo(playerid, weaponid, ammo)` |
| open.mp | `bool: SetPlayerAmmo(playerid, WEAPON:weaponid, ammo)` |

### `SetPlayerArmedWeapon`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerArmedWeapon(playerid, weaponid)` |
| open.mp | `bool: SetPlayerArmedWeapon(playerid, WEAPON:weaponid)` |

### `SetPlayerArmour`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerArmour(playerid, Float:armour)` |
| open.mp | `bool: SetPlayerArmour(playerid, Float:armour)` |

### `SetPlayerAttachedObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerAttachedObject(playerid, index, modelid, bone, Float:fOffsetX = 0.0, Float:fOffsetY = 0.0, Float:fOffsetZ = 0.0, Float:fRotX = 0.0, Float:fRotY = 0.0, Float:fRotZ = 0.0, Float:fScaleX = 1.0, Float:fScaleY = 1.0, Float:fScaleZ = 1.0, materialcolor1 = 0, materialcolor2 = 0)` |
| open.mp | `bool: SetPlayerAttachedObject(playerid, index, modelid, bone, Float:offsetX = 0.0, Float:offsetY = 0.0, Float:offsetZ = 0.0, Float:rotationX = 0.0, Float:rotationY = 0.0, Float:rotationZ = 0.0, Float:scaleX = 1.0, Float:scaleY = 1.0, Float:scaleZ = 1.0, materialColour1 = 0, materialColour2 = 0)` |

### `SetPlayerCameraLookAt`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerCameraLookAt(playerid, Float:x, Float:y, Float:z, cut = CAMERA_CUT)` |
| open.mp | `bool: SetPlayerCameraLookAt(playerid, Float:x, Float:y, Float:z, CAM_MOVE:cut = CAMERA_CUT)` |

### `SetPlayerCameraPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerCameraPos(playerid, Float:x, Float:y, Float:z)` |
| open.mp | `bool: SetPlayerCameraPos(playerid, Float:x, Float:y, Float:z)` |

### `SetPlayerChatBubble`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerChatBubble(playerid, const text[], color, Float:drawdistance, expiretime)` |
| open.mp | `bool: SetPlayerChatBubble(playerid, const text[], colour, Float:drawDistance, expireTime, OPEN_MP_TAGS:...)` |

### `SetPlayerCheckpoint`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerCheckpoint(playerid, Float:x, Float:y, Float:z, Float:size)` |
| open.mp | `bool: SetPlayerCheckpoint(playerid, Float:centreX, Float:centreY, Float:centreZ, Float:radius)` |

### `SetPlayerColor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerColor(playerid, color)` |
| open.mp | `bool: SetPlayerColor(playerid, colour)` |

### `SetPlayerDrunkLevel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerDrunkLevel(playerid, level)` |
| open.mp | `bool: SetPlayerDrunkLevel(playerid, level)` |

### `SetPlayerFacingAngle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerFacingAngle(playerid, Float:ang)` |
| open.mp | `bool: SetPlayerFacingAngle(playerid, Float:angle)` |

### `SetPlayerFightingStyle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerFightingStyle(playerid, style)` |
| open.mp | `bool: SetPlayerFightingStyle(playerid, FIGHT_STYLE:style)` |

### `SetPlayerHealth`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerHealth(playerid, Float:health)` |
| open.mp | `bool: SetPlayerHealth(playerid, Float:health)` |

### `SetPlayerInterior`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerInterior(playerid, interiorid)` |
| open.mp | `bool: SetPlayerInterior(playerid, interiorid)` |

### `SetPlayerMapIcon`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerMapIcon(playerid, iconid, Float:x, Float:y, Float:z, markertype, color, style = MAPICON_LOCAL)` |
| open.mp | `bool: SetPlayerMapIcon(playerid, iconid, Float:x, Float:y, Float:z, markerType, colour, MAPICON:style = MAPICON_LOCAL)` |

### `SetPlayerMarkerForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerMarkerForPlayer(playerid, showplayerid, color)` |
| open.mp | `bool: SetPlayerMarkerForPlayer(playerid, targetid, colour)` |

### `SetPlayerObjectMaterial`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerObjectMaterial(playerid, objectid, materialindex, modelid, const txdname[], const texturename[], materialcolor=0)` |
| open.mp | `bool: SetPlayerObjectMaterial(playerid, objectid, materialIndex, modelid, const textureLibrary[], const textureName[], materialColour = 0)` |

### `SetPlayerObjectMaterialText`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerObjectMaterialText(playerid, objectid, const text[], materialindex = 0, materialsize = OBJECT_MATERIAL_SIZE_256x128, const fontface[] = "Arial", fontsize = 24, bold = 1, fontcolor = 0xFFFFFFFF, backcolor = 0, textalignment = 0)` |
| open.mp | `bool: SetPlayerObjectMaterialText(playerid, objectid, const text[], materialIndex = 0, OBJECT_MATERIAL_SIZE:materialSize = OBJECT_MATERIAL_SIZE_256x128, const fontFace[] = "Arial", fontSize = 24, bool:bold = true, fontColour = 0xFFFFFFFF, backgroundColour = 0, OBJECT_MATERIAL_TEXT_ALIGN:textAlignment = OBJECT_MATERIAL_TEXT_ALIGN_LEFT, OPEN_MP_TAGS:...)` |

### `SetPlayerObjectNoCameraCol`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerObjectNoCameraCol(playerid, objectid)` |
| open.mp | `bool: SetPlayerObjectNoCameraCol(playerid, objectid)` |

### `SetPlayerObjectPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerObjectPos(playerid, objectid, Float:X, Float:Y, Float:Z)` |
| open.mp | `bool: SetPlayerObjectPos(playerid, objectid, Float:x, Float:y, Float:z)` |

### `SetPlayerObjectRot`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerObjectRot(playerid, objectid, Float:RotX, Float:RotY, Float:RotZ)` |
| open.mp | `bool: SetPlayerObjectRot(playerid, objectid, Float:rotationX, Float:rotationY, Float:rotationZ)` |

### `SetPlayerPos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerPos(playerid, Float:x, Float:y, Float:z)` |
| open.mp | `bool: SetPlayerPos(playerid, Float:x, Float:y, Float:z)` |

### `SetPlayerPosFindZ`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z)` |
| open.mp | `bool: SetPlayerPosFindZ(playerid, Float:x, Float:y, Float:z)` |

### `SetPlayerRaceCheckpoint`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerRaceCheckpoint(playerid, type, Float:x, Float:y, Float:z, Float:nextx, Float:nexty, Float:nextz, Float:size)` |
| open.mp | `bool: SetPlayerRaceCheckpoint(playerid, CP_TYPE:type, Float:centreX, Float:centreY, Float:centreZ, Float:nextX, Float:nextY, Float:nextZ, Float:radius)` |

### `SetPlayerScore`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerScore(playerid, score)` |
| open.mp | `bool: SetPlayerScore(playerid, score)` |

### `SetPlayerShopName`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerShopName(playerid, const shopname[])` |
| open.mp | `bool: SetPlayerShopName(playerid, const shopName[])` |

### `SetPlayerSkillLevel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerSkillLevel(playerid, skill, level)` |
| open.mp | `bool: SetPlayerSkillLevel(playerid, WEAPONSKILL:skill, level)` |

### `SetPlayerSkin`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerSkin(playerid, skinid)` |
| open.mp | `bool: SetPlayerSkin(playerid, skinid)` |

### `SetPlayerSpecialAction`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerSpecialAction(playerid, actionid)` |
| open.mp | `bool: SetPlayerSpecialAction(playerid, SPECIAL_ACTION:actionid)` |

### `SetPlayerTeam`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerTeam(playerid, teamid)` |
| open.mp | `bool: SetPlayerTeam(playerid, teamid)` |

### `SetPlayerTime`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerTime(playerid, hour, minute)` |
| open.mp | `bool: SetPlayerTime(playerid, hour, minute)` |

### `SetPlayerVelocity`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerVelocity(playerid, Float:X, Float:Y, Float:Z)` |
| open.mp | `bool: SetPlayerVelocity(playerid, Float:x, Float:y, Float:z)` |

### `SetPlayerVirtualWorld`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerVirtualWorld(playerid, worldid)` |
| open.mp | `bool: SetPlayerVirtualWorld(playerid, virtualWorld)` |

### `SetPlayerWantedLevel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerWantedLevel(playerid, level)` |
| open.mp | `bool: SetPlayerWantedLevel(playerid, level)` |

### `SetPlayerWeather`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerWeather(playerid, weather)` |
| open.mp | `bool: SetPlayerWeather(playerid, weather)` |

### `SetPlayerWorldBounds`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPlayerWorldBounds(playerid, Float:x_max,Float:x_min,Float:y_max,Float:y_min)` |
| open.mp | `bool: SetPlayerWorldBounds(playerid, Float:maxX, Float:minX, Float:maxY, Float:minY)` |

### `SetPVarFloat`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPVarFloat(playerid, const varname[], Float:float_value)` |
| open.mp | `bool: SetPVarFloat(playerid, const pvar[], Float:value)` |

### `SetPVarInt`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPVarInt(playerid, const varname[], int_value)` |
| open.mp | `bool: SetPVarInt(playerid, const pvar[], value)` |

### `SetPVarString`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetPVarString(playerid, const varname[], const string_value[])` |
| open.mp | `bool: SetPVarString(playerid, const pvar[], const value[], OPEN_MP_TAGS:...)` |

### `SetSpawnInfo`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetSpawnInfo(playerid, team, skin, Float:x, Float:y, Float:z, Float:rotation, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)` |
| open.mp | `bool: SetSpawnInfo(playerid, team, skin, Float:spawnX, Float:spawnY, Float:spawnZ, Float:angle, WEAPON:weapon1 = WEAPON_FIST, ammo1 = 0, WEAPON:weapon2 = WEAPON_FIST, ammo2 = 0, WEAPON:weapon3 = WEAPON_FIST, ammo3 = 0)` |

### `SetSVarFloat`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetSVarFloat(const varname[], Float:float_value)` |
| open.mp | `bool: SetSVarFloat(const svar[], Float:value)` |

### `SetSVarInt`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetSVarInt(const varname[], int_value)` |
| open.mp | `bool: SetSVarInt(const svar[], value)` |

### `SetSVarString`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetSVarString(const varname[], const string_value[])` |
| open.mp | `bool: SetSVarString(const svar[], const value[], OPEN_MP_TAGS:...)` |

### `SetTeamCount`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetTeamCount(count)` |
| open.mp | `void: SetTeamCount(count)` |

### `SetTimer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetTimer(const funcname[], interval, repeating)` |
| open.mp | ` SetTimer(const functionName[], interval, bool:repeating)` |

### `SetTimerEx`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetTimerEx(const funcname[], interval, repeating, const format[], {Float,_}:...)` |
| open.mp | ` SetTimerEx(const functionName[], interval, bool:repeating, const specifiers[] = "", OPEN_MP_TAGS:...)` |

### `SetVehicleAngularVelocity`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleAngularVelocity(vehicleid, Float:X, Float:Y, Float:Z)` |
| open.mp | `bool: SetVehicleAngularVelocity(vehicleid, Float:x, Float:y, Float:z)` |

### `SetVehicleHealth`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleHealth(vehicleid, Float:health)` |
| open.mp | `bool: SetVehicleHealth(vehicleid, Float:health)` |

### `SetVehicleNumberPlate`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleNumberPlate(vehicleid, const numberplate[])` |
| open.mp | `bool: SetVehicleNumberPlate(vehicleid, const numberPlate[])` |

### `SetVehicleParamsCarDoors`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleParamsCarDoors(vehicleid, driver, passenger, backleft, backright)` |
| open.mp | `bool: SetVehicleParamsCarDoors(vehicleid, frontLeft = -1, frontRight = -1, rearLeft = -1, rearRight = -1)` |

### `SetVehicleParamsCarWindows`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, backright)` |
| open.mp | `bool: SetVehicleParamsCarWindows(vehicleid, frontLeft = -1, frontRight = -1, rearLeft = -1, rearRight = -1)` |

### `SetVehicleParamsEx`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective)` |
| open.mp | `bool: SetVehicleParamsEx(vehicleid, engine = -1, lights = -1, alarm = -1, doors = -1, bonnet = -1, boot = -1, objective = -1)` |

### `SetVehicleParamsForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleParamsForPlayer(vehicleid, playerid, objective, doorslocked)` |
| open.mp | `bool: SetVehicleParamsForPlayer(vehicleid, playerid, objective = -1, doors = -1)` |

### `SetVehiclePos`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehiclePos(vehicleid, Float:x, Float:y, Float:z)` |
| open.mp | `bool: SetVehiclePos(vehicleid, Float:x, Float:y, Float:z)` |

### `SetVehicleToRespawn`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleToRespawn(vehicleid)` |
| open.mp | `bool: SetVehicleToRespawn(vehicleid)` |

### `SetVehicleVelocity`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleVelocity(vehicleid, Float:X, Float:Y, Float:Z)` |
| open.mp | `bool: SetVehicleVelocity(vehicleid, Float:x, Float:y, Float:z)` |

### `SetVehicleVirtualWorld`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleVirtualWorld(vehicleid, worldid)` |
| open.mp | `bool: SetVehicleVirtualWorld(vehicleid, virtualWorld)` |

### `SetVehicleZAngle`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetVehicleZAngle(vehicleid, Float:z_angle)` |
| open.mp | `bool: SetVehicleZAngle(vehicleid, Float:angle)` |

### `SetWeather`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetWeather(weatherid)` |
| open.mp | `void: SetWeather(weatherid)` |

### `SetWorldTime`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SetWorldTime(hour)` |
| open.mp | `void: SetWorldTime(hour)` |

### `ShowMenuForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ShowMenuForPlayer(Menu:menuid, playerid)` |
| open.mp | `bool: ShowMenuForPlayer(Menu:menuid, playerid)` |

### `ShowNameTags`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ShowNameTags(show)` |
| open.mp | `void: ShowNameTags(bool:show)` |

### `ShowPlayerDialog`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ShowPlayerDialog(playerid, dialogid, style, const caption[], const info[], const button1[], const button2[])` |
| open.mp | `bool: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE:style, const title[], const body[], const button1[], const button2[], OPEN_MP_TAGS:...)` |

### `ShowPlayerMarkers`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ShowPlayerMarkers(mode)` |
| open.mp | `void: ShowPlayerMarkers(PLAYER_MARKERS_MODE:mode)` |

### `ShowPlayerNameTagForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` ShowPlayerNameTagForPlayer(playerid, showplayerid, show)` |
| open.mp | `bool: ShowPlayerNameTagForPlayer(playerid, targetid, bool:show)` |

### `SpawnPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` SpawnPlayer(playerid)` |
| open.mp | `bool: SpawnPlayer(playerid)` |

### `StartRecordingPlayerData`

| Target | Declaration |
|---|---|
| 0.3.7 | ` StartRecordingPlayerData(playerid, recordtype, const recordname[])` |
| open.mp | `bool: StartRecordingPlayerData(playerid, PLAYER_RECORDING_TYPE:recordType, const recordFile[])` |

### `StopAudioStreamForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` StopAudioStreamForPlayer(playerid)` |
| open.mp | `bool: StopAudioStreamForPlayer(playerid)` |

### `StopObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` StopObject(objectid)` |
| open.mp | `bool: StopObject(objectid)` |

### `StopPlayerObject`

| Target | Declaration |
|---|---|
| 0.3.7 | ` StopPlayerObject(playerid, objectid)` |
| open.mp | `bool: StopPlayerObject(playerid, objectid)` |

### `StopRecordingPlayerData`

| Target | Declaration |
|---|---|
| 0.3.7 | ` StopRecordingPlayerData(playerid)` |
| open.mp | `bool: StopRecordingPlayerData(playerid)` |

### `TextDrawAlignment`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawAlignment(Text:text, alignment)` |
| open.mp | `bool: TextDrawAlignment(Text:textid, TEXT_DRAW_ALIGN:alignment)` |

### `TextDrawBackgroundColor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawBackgroundColor(Text:text, color)` |
| open.mp | `bool: TextDrawBackgroundColor(Text:textid, backgroundColor)` |

### `TextDrawBoxColor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawBoxColor(Text:text, color)` |
| open.mp | `bool: TextDrawBoxColor(Text:textid, boxColor)` |

### `TextDrawColor`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawColor(Text:text, color)` |
| open.mp | `bool: TextDrawColor(Text:textid, textColor)` |

### `TextDrawCreate`

| Target | Declaration |
|---|---|
| 0.3.7 | `Text: TextDrawCreate(Float:x, Float:y, const text[])` |
| open.mp | `Text: TextDrawCreate(Float:x, Float:y, const format[], OPEN_MP_TAGS:...)` |

### `TextDrawDestroy`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawDestroy(Text:text)` |
| open.mp | `bool: TextDrawDestroy(Text:textid)` |

### `TextDrawFont`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawFont(Text:text, font)` |
| open.mp | `bool: TextDrawFont(Text:textid, TEXT_DRAW_FONT:font)` |

### `TextDrawHideForAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawHideForAll(Text:text)` |
| open.mp | `bool: TextDrawHideForAll(Text:textid)` |

### `TextDrawHideForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawHideForPlayer(playerid, Text:text)` |
| open.mp | `bool: TextDrawHideForPlayer(playerid, Text:textid)` |

### `TextDrawLetterSize`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawLetterSize(Text:text, Float:x, Float:y)` |
| open.mp | `bool: TextDrawLetterSize(Text:textid, Float:width, Float:height)` |

### `TextDrawSetOutline`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawSetOutline(Text:text, size)` |
| open.mp | `bool: TextDrawSetOutline(Text:textid, outlineSize)` |

### `TextDrawSetPreviewModel`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawSetPreviewModel(Text:text, modelindex)` |
| open.mp | `bool: TextDrawSetPreviewModel(Text:textid, model)` |

### `TextDrawSetPreviewRot`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawSetPreviewRot(Text:text, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fZoom = 1.0)` |
| open.mp | `bool: TextDrawSetPreviewRot(Text:textid, Float:rotationX, Float:rotationY, Float:rotationZ, Float:zoom = 1.0)` |

### `TextDrawSetPreviewVehCol`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawSetPreviewVehCol(Text:text, color1, color2)` |
| open.mp | `bool: TextDrawSetPreviewVehCol(Text:textid, colour1, colour2)` |

### `TextDrawSetProportional`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawSetProportional(Text:text, set)` |
| open.mp | `bool: TextDrawSetProportional(Text:textid, bool:proportional)` |

### `TextDrawSetSelectable`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawSetSelectable(Text:text, set)` |
| open.mp | `bool: TextDrawSetSelectable(Text:textid, bool:selectable)` |

### `TextDrawSetShadow`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawSetShadow(Text:text, size)` |
| open.mp | `bool: TextDrawSetShadow(Text:textid, shadowSize)` |

### `TextDrawSetString`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawSetString(Text:text, const string[])` |
| open.mp | `bool: TextDrawSetString(Text:textid, const format[], OPEN_MP_TAGS:...)` |

### `TextDrawShowForAll`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawShowForAll(Text:text)` |
| open.mp | `bool: TextDrawShowForAll(Text:textid)` |

### `TextDrawShowForPlayer`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawShowForPlayer(playerid, Text:text)` |
| open.mp | `bool: TextDrawShowForPlayer(playerid, Text:textid)` |

### `TextDrawTextSize`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawTextSize(Text:text, Float:x, Float:y)` |
| open.mp | `bool: TextDrawTextSize(Text:textid, Float:width, Float:height)` |

### `TextDrawUseBox`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TextDrawUseBox(Text:text, use)` |
| open.mp | `bool: TextDrawUseBox(Text:textid, bool:enableBox)` |

### `TogglePlayerClock`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TogglePlayerClock(playerid, toggle)` |
| open.mp | `bool: TogglePlayerClock(playerid, bool:toggle)` |

### `TogglePlayerControllable`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TogglePlayerControllable(playerid, toggle)` |
| open.mp | `bool: TogglePlayerControllable(playerid, bool:controllable)` |

### `TogglePlayerSpectating`

| Target | Declaration |
|---|---|
| 0.3.7 | ` TogglePlayerSpectating(playerid, toggle)` |
| open.mp | `bool: TogglePlayerSpectating(playerid, bool:toggle)` |

### `UnBlockIpAddress`

| Target | Declaration |
|---|---|
| 0.3.7 | ` UnBlockIpAddress(const ip_address[])` |
| open.mp | `bool: UnBlockIpAddress(const ipAddress[])` |

### `Update3DTextLabelText`

| Target | Declaration |
|---|---|
| 0.3.7 | ` Update3DTextLabelText(Text3D:id, color, const text[])` |
| open.mp | `bool: Update3DTextLabelText(Text3D:textid, colour, const text[], OPEN_MP_TAGS:...)` |

### `UpdatePlayer3DTextLabelText`

| Target | Declaration |
|---|---|
| 0.3.7 | ` UpdatePlayer3DTextLabelText(playerid, PlayerText3D:id, color, const text[])` |
| open.mp | `bool: UpdatePlayer3DTextLabelText(playerid, PlayerText3D:textid, colour, const text[], OPEN_MP_TAGS:...)` |

### `UpdateVehicleDamageStatus`

| Target | Declaration |
|---|---|
| 0.3.7 | ` UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires)` |
| open.mp | `bool: UpdateVehicleDamageStatus(vehicleid, VEHICLE_PANEL_STATUS:panels, VEHICLE_DOOR_STATUS:doors, VEHICLE_LIGHT_STATUS:lights, VEHICLE_TYRE_STATUS:tires)` |

### `UsePlayerPedAnims`

| Target | Declaration |
|---|---|
| 0.3.7 | ` UsePlayerPedAnims()` |
| open.mp | `void: UsePlayerPedAnims()` |

