/* Owner-tracked entity lifecycle: actors, pickups, gangzones.
 *
 * The native pool already refuses to destroy an invalid entity, but nothing
 * remembers WHICH entity belonged to WHICH player. That memory is what leaks when
 * a player disconnects or reopens a shop panel: the actor/pickup/zone stays, the
 * next player creates another one, and the pool fills silently.
 *
 * The table is small on purpose (a player does not own dozens of entities). When
 * it is full, tracking is refused rather than silently dropped.
 */
#if defined _samp_entity_lifecycle_included
    #endinput
#endif
#define _samp_entity_lifecycle_included

#if !defined EL_MAX_TRACKED
    #define EL_MAX_TRACKED (32)
#endif
#if !defined EL_MAX_OWNERS
    #define EL_MAX_OWNERS (MAX_PLAYERS)
#endif

/* Anonymous so the constants carry no tag: a tagged enum here would force every
 * helper and call site to cast, which is noise, not safety. */
enum
{
    EL_ACTOR = 1,
    EL_PICKUP,
    EL_GANGZONE
}

static gElOwner[EL_MAX_TRACKED];
static gElKind[EL_MAX_TRACKED];
static gElId[EL_MAX_TRACKED];
static gElCount;

stock EL_TrackedCount()
{
    return gElCount;
}

/** Number of entities of any kind tracked for one owner. */
stock EL_OwnedCount(owner)
{
    new owned = 0;
    for (new i = 0; i < gElCount; i++)
    {
        if (gElOwner[i] == owner) owned++;
    }
    return owned;
}

/* 0.3.7's IsValidActor returns an untagged int while open.mp returns bool, so the
 * ternary normalises both without a tagged comparison. */
static bool:EL_IsActorValid(actorId)
{
    return IsValidActor(actorId) ? true : false;
}

static bool:EL_IsIdValid(kind, id)
{
    if (id < 0) return false;

    /* 0.3.7 has no IsValidActor/IsValidPickup/IsValidGangZone trio, so validity
     * is checked only for actors (which both stdlibs expose). Stale pickups and
     * zones are dropped when their destroy call fails. */
    if (kind == EL_ACTOR) return EL_IsActorValid(id);
    return true;
}

static bool:EL_Track(kind, owner, id)
{
    if (owner < 0 || owner >= EL_MAX_OWNERS) return false;
    if (!EL_IsIdValid(kind, id)) return false;
    if (gElCount >= EL_MAX_TRACKED) return false;

    /* Tracking the same entity twice would double-destroy it later. Ids of
     * different kinds are independent pools, so compare kind AND id. */
    for (new i = 0; i < gElCount; i++)
    {
        if (gElKind[i] == kind && gElId[i] == id) return false;
    }

    gElOwner[gElCount] = owner;
    gElKind[gElCount] = kind;
    gElId[gElCount] = id;
    gElCount++;
    return true;
}

static bool:EL_Forget(kind, id)
{
    for (new i = 0; i < gElCount; i++)
    {
        if (gElKind[i] != kind || gElId[i] != id) continue;

        for (new j = i; j < gElCount - 1; j++)
        {
            gElOwner[j] = gElOwner[j + 1];
            gElKind[j] = gElKind[j + 1];
            gElId[j] = gElId[j + 1];
        }
        gElCount--;
        return true;
    }
    return false;
}

/** Refuses an invalid actor, an invalid owner, and a full table. */
stock bool:EL_TrackActor(owner, actorId)
{
    return EL_Track(EL_ACTOR, owner, actorId);
}

stock bool:EL_TrackPickup(owner, pickupId)
{
    return EL_Track(EL_PICKUP, owner, pickupId);
}

stock bool:EL_TrackGangzone(owner, zoneId)
{
    return EL_Track(EL_GANGZONE, owner, zoneId);
}

/** Forgets one entity without destroying it (caller already did). */
stock bool:EL_ForgetActor(actorId)
{
    return EL_Forget(EL_ACTOR, actorId);
}

stock bool:EL_ForgetPickup(pickupId)
{
    return EL_Forget(EL_PICKUP, pickupId);
}

stock bool:EL_ForgetGangzone(zoneId)
{
    return EL_Forget(EL_GANGZONE, zoneId);
}

static bool:EL_Destroy(kind, id)
{
    if (kind == EL_ACTOR)
    {
        if (!EL_IsActorValid(id)) return false;
        return DestroyActor(id) ? true : false;
    }
    if (kind == EL_PICKUP) return DestroyPickup(id) ? true : false;
    if (kind == EL_GANGZONE) return GangZoneDestroy(id) ? true : false;
    return false;
}

/** Destroys every valid entity owned by `owner`; returns how many were
 *  destroyed. Entries whose entity is already gone are dropped, not retried. */
stock EL_DestroyOwned(owner)
{
    if (owner < 0 || owner >= EL_MAX_OWNERS) return 0;

    new destroyed = 0;
    new i = 0;
    while (i < gElCount)
    {
        if (gElOwner[i] != owner)
        {
            i++;
            continue;
        }

        if (EL_Destroy(gElKind[i], gElId[i])) destroyed++;

        for (new j = i; j < gElCount - 1; j++)
        {
            gElOwner[j] = gElOwner[j + 1];
            gElKind[j] = gElKind[j + 1];
            gElId[j] = gElId[j + 1];
        }
        gElCount--;
    }
    return destroyed;
}

stock EL_Reset()
{
    gElCount = 0;
}
