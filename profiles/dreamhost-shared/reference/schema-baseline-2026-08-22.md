# DreamHost Shared schema baseline — 2026-08-22

Sanitized schema reference captured from the active Data Inspire WordPress database.

This file intentionally excludes database names, account names, host/network identifiers and credentials. Project-specific table prefixes are also omitted below; only functional table identities are retained where useful for migration analysis.

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

## Legacy table identities

The two nonconforming tables were identified without modifying production:

1. `yoast_prominent_words`
   - Engine: InnoDB
   - Collation: `utf8mb3_general_ci`
   - Approximate rows observed: 177
   - Functional attribution: Yoast prominent-words data.
   - Migration interpretation: plugin/legacy application data, not a reusable hosting-platform requirement.

2. `feeds`
   - Engine: MyISAM
   - Collation: `utf8mb3_general_ci`
   - Approximate rows observed: 1
   - Functional attribution: unresolved from the table name alone.
   - Migration interpretation: provenance must be checked against the installed/current plugin set or source code before deciding whether it should be migrated, normalized or retired.

No production table conversion, deletion or cleanup is authorized by this discovery work.

## Stored database objects

- Triggers: 0
- Routines: 0
- Events: 0

The hosting account has privileges that can support some of these objects, but the current Data Inspire schema does not depend on them.

## Reusable platform policy

The reusable `dreamhost-shared` profile should use a clean **InnoDB + `utf8mb4`** policy for new databases/tables rather than reproducing the historical mixed schema.

For WordPress-oriented compatibility, `utf8mb4_unicode_520_ci` is the preferred initial connection/application collation because that is the collation selected by the measured production WordPress runtime. Existing migrated tables using `utf8mb4_unicode_ci` remain compatible and do not need to be normalized merely to satisfy the development template.

The two legacy tables are treated as Data Inspire migration concerns, not as reusable platform defaults.

## Remaining schema/migration check

Determine the provenance and active dependency status of the legacy `feeds` table. The Yoast table is already functionally identified. No production schema changes are authorized by this discovery phase.
