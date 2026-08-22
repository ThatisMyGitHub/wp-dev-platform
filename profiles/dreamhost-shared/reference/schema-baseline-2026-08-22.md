# DreamHost Shared schema baseline — 2026-08-22

Sanitized schema reference captured from the active Data Inspire WordPress database.

This file intentionally excludes database names, account names, host/network identifiers, credentials and table names that could unnecessarily expose project-specific implementation details.

## WordPress database configuration

- `DB_CHARSET`: `utf8`
- `DB_COLLATE`: empty

Interpretation: WordPress configuration itself does not force a collation. The actual connection and physical table definitions must be inspected independently before choosing the reusable platform baseline.

## Database defaults

- Default character set: `utf8mb3`
- Default collation: `utf8mb3_unicode_ci`

## Physical table distribution

Total base tables observed: **47**.

- InnoDB / `utf8mb4_unicode_ci`: 36 tables
- InnoDB / `utf8mb4_unicode_520_ci`: 9 tables
- InnoDB / `utf8mb3_general_ci`: 1 table
- MyISAM / `utf8mb3_general_ci`: 1 table

Therefore:

- 45 of 47 tables are already `utf8mb4`;
- 2 of 47 tables remain `utf8mb3`;
- 46 of 47 tables are InnoDB;
- 1 of 47 tables remains MyISAM.

## Stored database objects

- Triggers: 0
- Routines: 0
- Events: 0

The hosting account has privileges that can support some of these objects, but the current Data Inspire schema does not depend on them.

## Design implications

The reusable DreamHost profile must not reproduce this mixed historical schema state by default. The measured production database is clearly the product of incremental WordPress/plugin evolution rather than a clean schema policy.

Before setting the canonical development defaults, complete two additional checks:

1. identify the two legacy `utf8mb3` tables and determine whether they belong to WordPress core, a current plugin, or abandoned data;
2. capture the charset/collation actually negotiated by WordPress over its PHP database connection.

The likely reusable baseline is a clean InnoDB + `utf8mb4` policy, but that decision remains pending until those checks are complete and migration compatibility is assessed.
