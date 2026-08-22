# DreamHost Shared schema baseline — 2026-08-22

Sanitized schema reference captured from the active Data Inspire WordPress database.

This file intentionally excludes database names, account names, host/network identifiers, credentials and table names that could unnecessarily expose project-specific implementation details.

## WordPress database configuration

- `DB_CHARSET`: `utf8`
- `DB_COLLATE`: empty

The literal `wp-config.php` values do not describe the effective WordPress database connection by themselves. WordPress capability detection upgrades the live connection to `utf8mb4` on this MySQL server.

## Effective WordPress/PHP database connection

Measured through the active WordPress `$wpdb` connection:

- `$wpdb->charset`: `utf8mb4`
- `$wpdb->collate`: `utf8mb4_unicode_520_ci`
- `character_set_client`: `utf8mb4`
- `character_set_connection`: `utf8mb4`
- `character_set_results`: `utf8mb4`
- `collation_connection`: `utf8mb4_unicode_520_ci`

Therefore the active application runtime is unequivocally `utf8mb4`, despite the legacy `DB_CHARSET=utf8` setting and the database server/database defaults described below.

## Database defaults

- Default character set: `utf8mb3`
- Default collation: `utf8mb3_unicode_ci`

These defaults are legacy state and are not representative of the charset WordPress actually negotiates for its active PHP database connection.

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

## Reusable platform policy

The reusable `dreamhost-shared` profile should use a clean **InnoDB + `utf8mb4`** policy for new databases/tables rather than reproducing the historical mixed schema.

For WordPress-oriented compatibility, `utf8mb4_unicode_520_ci` is the preferred initial connection/application collation because that is the collation selected by the measured production WordPress runtime. Existing migrated tables using `utf8mb4_unicode_ci` remain compatible and do not need to be normalized merely to satisfy the development template.

The two remaining legacy `utf8mb3` tables and the single MyISAM table must still be identified before any production migration/normalization plan is proposed. Their legacy state is treated as project data to assess, not as a reusable platform requirement.

## Remaining schema check

Identify the two legacy tables and determine whether they belong to WordPress core, an active plugin, or abandoned/legacy functionality. No production schema changes are authorized by this discovery phase.
