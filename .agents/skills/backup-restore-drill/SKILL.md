---
name: backup-restore-drill
description: Prove backups actually restore — define RPO/RTO, run a timed restore drill into an isolated environment, verify row counts and referential integrity, and record the evidence so an untested backup is never mistaken for a recovery plan.
---

# Backup restore drill

An untested backup is a hope. The only meaningful metric is: how long did a real
restore take, and did the data come back consistent?

## Define the numbers first

- **RPO** — how much data you can lose (e.g. 5 minutes → WAL archiving, not nightly
  dumps).
- **RTO** — how long recovery may take (drives standby vs restore-from-dump).
- Write both down; a backup schedule without RPO/RTO cannot be judged.

## Backup layers

| Layer | Protects against | Verify with |
|---|---|---|
| Logical dump (`pg_dump`/`mysqldump`) | accidental deletes, migrations | restore into a scratch DB |
| Physical/base backup (`pg_basebackup`, XtraBackup) | disk loss, fast large restores | start a server from it |
| WAL/binlog archiving | RPO minutes, point-in-time recovery | replay to a timestamp |
| Snapshots (PVC/VM) | whole-machine loss | mount and query |
| Offsite + immutable copy | ransomware, region loss | restore from offsite path |

3-2-1 still applies: three copies, two media, one offsite. Immutability (object
lock, retention policy) is what stops a compromised admin from deleting backups.

## Drill runbook

1. Pick a restore point and note the exact timestamp.
2. Restore into an **isolated** instance — never over production, never on the same
   host if you can avoid it.
3. Start the app against it (or run read-only checks if the app is not available).
4. Verify: schema version, row counts on critical tables, foreign keys, a known
   recent write, and one aggregate that would change if data were truncated.
5. Time every step. The total is your measured RTO; compare with the target.
6. Record the run: date, backup id, restore point, duration, verification output,
   who ran it, what failed.

## Verification queries that catch silent truncation

```sql
SELECT count(*) FROM orders;
SELECT max(created_at) FROM orders;
SELECT count(*) FROM orders o
LEFT JOIN customers c ON c.id = o.customer_id
WHERE c.id IS NULL;              -- should be 0 with FKs enforced
```

A dump that restores without errors but is missing the last day is a failed drill.

## Common failure modes

- dump succeeded, restore never tested, `pg_restore` fails on extensions/roles;
- backup excludes large tables by accident;
- WAL archive gap discovered only during PITR;
- credentials/keys not backed up, so the restored DB cannot decrypt columns;
- retention deletes the only good copy before the new one is verified;
- restore takes 4h against a 1h RTO and nobody knew.

## Scheduling

- drill quarterly at minimum, and after any schema or storage change;
- rotate who runs it so it is not one person's tribal knowledge;
- automate the isolated restore in CI/nightly where possible, alert on failure;
- keep the runbook next to the on-call docs, not in someone's notes.

## Limits

- Concrete commands differ per engine/version; use your engine's documented
  restore path and pin the version.
- This is a drill and verification procedure, not a backup product choice.
- No fixture: proof requires a real backup artifact and a restore target.
