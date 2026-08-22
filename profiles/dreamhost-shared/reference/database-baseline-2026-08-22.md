# DreamHost Shared database baseline — 2026-08-22

Sanitized reference captured from the active Data Inspire WordPress database on DreamHost Shared Unlimited.

This file intentionally excludes database names, database usernames, source network ranges, database hostnames and credentials.

## MySQL server

- Server version: MySQL 8.0.41 (`8.0.41-0ubuntu0.24.04.1`)
- Vendor comment: Ubuntu
- Server character set: `utf8mb3`
- Server collation: `utf8mb3_unicode_ci`
- SQL mode: `NO_ENGINE_SUBSTITUTION`
- Time zone: `SYSTEM`
- `max_allowed_packet`: 33,554,432 bytes (32 MiB)
- `lower_case_table_names`: `0`

The server defaults do not prove the character set/collation used by the existing WordPress tables. Table/database-level metadata must be captured separately before deciding the development database defaults.

## Effective application-account grants observed

The production application database user currently has database-scoped privileges equivalent to:

- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`
- `CREATE`
- `DROP`
- `REFERENCES`
- `INDEX`
- `ALTER`
- `CREATE TEMPORARY TABLES`
- `LOCK TABLES`
- `EXECUTE`
- `CREATE VIEW`
- `SHOW VIEW`
- `CREATE ROUTINE`
- `ALTER ROUTINE`
- `TRIGGER`

A global `USAGE` grant is also present.

Not observed in the effective grants include `EVENT`, `GRANT OPTION`, global administrative privileges, user-management privileges, `FILE`, `PROCESS`, or `SUPER`-class privileges.

## Important correction to the preliminary profile

The measured Data Inspire environment contradicts the preliminary assumption that routines and triggers are universally unavailable on DreamHost Shared. The active account is explicitly granted routine and trigger privileges.

Therefore:

1. measured effective grants take precedence over generic provider assumptions for the Data Inspire compatibility profile;
2. the reusable platform must not artificially remove privileges that are demonstrably present when emulating this environment;
3. routines/triggers should still not become dependencies of the generic template unless portability across supported hosting profiles is deliberately accepted and tested;
4. no destructive production test will be performed merely to prove that a granted DDL capability executes successfully.

## Pending database discovery

Before finalizing the MySQL development profile, capture:

- current database default character set/collation;
- actual WordPress table collations;
- table storage engines;
- any existing triggers/routines/events as metadata only;
- WordPress database prefix if needed for migration tooling (kept project-specific, not platform-specific).

## Design implication

The development database should emulate application-visible behavior and effective privilege boundaries rather than blindly reproduce every server-wide DreamHost default. In particular, the observed `utf8mb3` server default must not be used as the WordPress schema target until the existing application's database/table metadata is known.
