# DreamHost Shared profile

**Status:** measured discovery in progress

This profile adapts `wp-dev-platform` to DreamHost Shared Hosting behavior while preserving the common HCF-derived development, validation, deployment, and migration pattern.

## Measured baseline

The Data Inspire production environment has now been partially fingerprinted. Confirmed characteristics include:

- Ubuntu 24.04.4 LTS host environment.
- Apache 2.4.58.
- Multiple PHP binaries available; default CLI PHP is 8.2.30.
- Shared MySQL 8 on a separate database server.
- Measured database server version: MySQL 8.0.41 (Ubuntu).
- `localhost` must not be assumed for production database access.
- Persistent background processes must not be required by the production application.
- Docker is development infrastructure only and is not a production dependency.

## Effective database privileges

The active Data Inspire database user is currently granted normal WordPress DML/DDL privileges plus views, routines and triggers at database scope. In particular, the measured grants include:

- `CREATE ROUTINE`
- `ALTER ROUTINE`
- `EXECUTE`
- `TRIGGER`

`EVENT` and global administrative/user-management privileges were not observed.

This corrects the preliminary assumption that routines and triggers are universally unavailable on DreamHost Shared. The measured account grants are authoritative for the Data Inspire compatibility profile.

The generic platform should nevertheless avoid making routines/triggers mandatory unless portability across all supported hosting profiles is explicitly accepted and tested.

## Authoritative reference data

Raw captures remain outside Git; only sanitized compatibility data belongs under `reference/`.

See:

- `../../docs/DREAMHOST-FINGERPRINT.md`
- `reference/runtime-baseline-2026-08-22.md`
- `reference/database-baseline-2026-08-22.md`
- `../../ROADMAP.md`

## Remaining discovery

Before the first runnable profile is finalized, we still need:

- website-assigned PHP version from the DreamHost panel;
- web/FastCGI PHP runtime confirmation where practical;
- current database/table character sets and collations;
- table storage engines and existing database objects as metadata;
- optional WordPress plugin/theme inventory.

## Planned structure

```text
profiles/dreamhost-shared/
├── README.md
├── compatibility.md
├── compose.override.yaml
├── php/
├── mysql/
└── reference/
    ├── runtime-baseline-2026-08-22.md
    ├── database-baseline-2026-08-22.md
    └── sanitized-profile.json
```

Do not add production credentials or raw fingerprint files here.
