// Entity pool behaviour — executed on a real open.mp server.
// @runtime-suite
#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

#include "samp_entity_lifecycle"

new gChecks;
new gFailures;

stock TestImpl(bool:condition, const label[])
{
    gChecks++;
    if (condition) return 1;

    gFailures++;
    printf("[ENT] FAIL: %s", label);
    return 0;
}

/* `!bool` and `bool == 0` produce untagged results; the cast keeps both tagged
 * and untagged expressions warning-free on both stdlibs. */
#define Test(%0,%1) TestImpl(bool:(%0), %1)

stock TestInt(expected, actual, const label[])
{
    gChecks++;
    if (expected == actual) return 1;

    gFailures++;
    printf("[ENT] FAIL: %s (expected %d, got %d)", label, expected, actual);
    return 0;
}

stock TestActors()
{
    new actor = CreateActor(1, 0.0, 0.0, 3.0, 90.0);
    Test(IsValidActor(actor), "created actor is valid");
    Test(EL_TrackActor(0, actor), "actor can be tracked for its owner");
    TestInt(1, EL_TrackedCount(), "tracked count incremented");

    Test(!EL_TrackActor(0, actor), "the same actor cannot be tracked twice");
    TestInt(1, EL_TrackedCount(), "rejected duplicate leaves the table unchanged");
    TestInt(1, EL_DestroyOwned(0), "owned actor is destroyed");
    Test(!IsValidActor(actor), "destroyed actor is no longer valid");
    TestInt(0, EL_TrackedCount(), "destroy frees the tracking slot");
    TestInt(0, EL_DestroyOwned(0), "second cleanup destroys nothing");
    TestInt(0, DestroyActor(actor), "native refuses to destroy an invalid actor again");
}

stock TestPickups()
{
    new pickup = CreatePickup(1240, 2, 1.0, 1.0, 3.0);
    Test(pickup >= 0, "pickup is created");
#if defined OMP_BUILD
    /* IsValidPickup/GetPickupModel do not exist in the 0.3.7 stdlib. */
    Test(IsValidPickup(pickup), "created pickup is valid");
    TestInt(1240, GetPickupModel(pickup), "pickup model reads back");
#endif

    Test(DestroyPickup(pickup), "pickup is destroyed");
    Test(!DestroyPickup(pickup), "double destroy is refused");

    new reused = CreatePickup(1240, 2, 2.0, 2.0, 3.0);
#if defined OMP_BUILD
    Test(IsValidPickup(reused), "a new pickup can be created after destroy");
#endif
    DestroyPickup(reused);
}

stock TestGangzones()
{
    new zone = GangZoneCreate(0.0, 0.0, 100.0, 100.0);
    Test(zone >= 0, "gangzone is created");
#if defined OMP_BUILD
    Test(IsValidGangZone(zone), "created gangzone is valid");
#endif

    Test(GangZoneDestroy(zone), "gangzone is destroyed");
#if defined OMP_BUILD
    /* IsValidGangZone is not in the 0.3.7 stdlib. */
    Test(!IsValidGangZone(zone), "destroyed gangzone is invalid");
#endif
    Test(!GangZoneDestroy(zone), "double gangzone destroy is refused");
}

stock TestTextLabels()
{
    new Text3D:label = Create3DTextLabel("fixture", 0xFFFFFFFF, 0.0, 0.0, 3.0, 20.0, 0, false);
    Test(Delete3DTextLabel(label), "3D label is deleted");
#if defined OMP_BUILD
    /* IsValid3DTextLabel is not in the 0.3.7 stdlib. */
    Test(!IsValid3DTextLabel(label), "deleted label is invalid");
#endif
    Test(!Delete3DTextLabel(label), "double label delete is refused");
}

stock TestCheckpointWithoutClient()
{
    /* Checkpoints are per-player; with no connected client the native must
     * refuse instead of pretending to show something. */
    Test(!SetPlayerCheckpoint(0, 0.0, 0.0, 3.0, 2.0), "checkpoint for a disconnected player is refused");
#if defined OMP_BUILD
    Test(!IsPlayerCheckpointActive(0), "no checkpoint is active for a disconnected player");
#endif
    Test(!DisablePlayerCheckpoint(0), "disabling a nonexistent checkpoint returns false");
}

stock TestTrackingBounds()
{
    EL_Reset();

    Test(!EL_TrackActor(-1, 0), "negative owner is refused");
    Test(!EL_TrackActor(1500, 0), "owner past the configured range is refused");

    new actor = CreateActor(1, 5.0, 5.0, 3.0, 0.0);
    EL_TrackActor(1, actor);

    new tracked = 0;
    for (new i = 0; i < EL_MAX_TRACKED + 4; i++)
    {
        new extra = CreateActor(1, 5.0, 5.0, 3.0, 0.0);
        if (EL_TrackActor(2, extra)) tracked++;
        else DestroyActor(extra);
    }
    TestInt(EL_MAX_TRACKED - 1, tracked, "tracking table stops at its capacity");

    TestInt(EL_MAX_TRACKED, EL_TrackedCount(), "table is full but consistent");
    EL_Reset();
    TestInt(0, EL_TrackedCount(), "reset clears the table");

    DestroyActor(actor);
}

stock TestOwnerCleanup()
{
    EL_Reset();

    new actor = CreateActor(1, 6.0, 6.0, 3.0, 0.0);
    new pickup = CreatePickup(1240, 2, 6.0, 6.0, 3.0);
    new zone = GangZoneCreate(0.0, 0.0, 50.0, 50.0);

    Test(EL_TrackActor(3, actor), "actor tracked for cleanup");
    Test(EL_TrackPickup(3, pickup), "pickup tracked for cleanup");
    Test(EL_TrackGangzone(3, zone), "gangzone tracked for cleanup");

    Test(!EL_TrackPickup(3, pickup), "the same pickup cannot be tracked twice");
    Test(!EL_TrackGangzone(3, zone), "the same gangzone cannot be tracked twice");
    TestInt(3, EL_OwnedCount(3), "owned count spans every entity kind");

    new other = CreateActor(1, 7.0, 7.0, 3.0, 0.0);
    Test(EL_TrackActor(4, other), "a second owner can track its own actor");

    TestInt(3, EL_DestroyOwned(3), "cleanup destroys exactly the owner's entities");
#if defined OMP_BUILD
    Test(!IsValidActor(actor), "cleaned actor is invalid");
    Test(!IsValidPickup(pickup), "cleaned pickup is invalid");
    Test(!IsValidGangZone(zone), "cleaned gangzone is invalid");
#endif
    TestInt(1, EL_TrackedCount(), "other owners stay tracked");
    Test(IsValidActor(other), "another owner's actor is untouched");

    TestInt(1, EL_DestroyOwned(4), "second owner cleanup destroys its actor");
    TestInt(0, EL_TrackedCount(), "table is empty after both cleanups");
}

stock TestForgetWithoutDestroy()
{
    EL_Reset();

    new pickup = CreatePickup(1240, 2, 8.0, 8.0, 3.0);
    Test(EL_TrackPickup(5, pickup), "pickup tracked before forgetting");
    Test(EL_ForgetPickup(pickup), "pickup can be forgotten");
    Test(!EL_ForgetPickup(pickup), "forgetting an untracked pickup is refused");
#if defined OMP_BUILD
    Test(IsValidPickup(pickup), "forgetting does not destroy the pickup");
#endif
    DestroyPickup(pickup);

    new zone = GangZoneCreate(0.0, 0.0, 20.0, 20.0);
    Test(EL_TrackGangzone(5, zone), "gangzone tracked before forgetting");
    Test(EL_ForgetGangzone(zone), "gangzone can be forgotten");
    Test(!EL_ForgetGangzone(zone), "forgetting an untracked gangzone is refused");
#if defined OMP_BUILD
    Test(IsValidGangZone(zone), "forgetting does not destroy the gangzone");
#endif
    GangZoneDestroy(zone);

    Test(!EL_TrackPickup(-1, 0), "negative owner is refused for pickups");
    Test(!EL_TrackGangzone(0, -1), "negative zone id is refused");
}

stock TestStaleEntriesDropped()
{
    EL_Reset();

    new pickup = CreatePickup(1240, 2, 9.0, 9.0, 3.0);
    Test(EL_TrackPickup(6, pickup), "pickup tracked before an out-of-band destroy");
    DestroyPickup(pickup);

    TestInt(0, EL_DestroyOwned(6), "stale entry is not counted as destroyed");
    TestInt(0, EL_TrackedCount(), "stale entry is dropped instead of retried");
}

public OnGameModeInit()
{
    TestActors();
    TestPickups();
    TestGangzones();
    TestTextLabels();
    TestCheckpointWithoutClient();
    TestTrackingBounds();
    TestOwnerCleanup();
    TestForgetWithoutDestroy();
    TestStaleEntriesDropped();

    printf("[ENT] %d checks, %d failed", gChecks, gFailures);
    return 1;
}
