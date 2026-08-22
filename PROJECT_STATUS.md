# Project Status

## Current phase

**Phase 1 complete — DreamHost discovery and measured compatibility baseline**

## Status summary

- Repository baseline created on `main`.
- `dev` integration branch created.
- Project roadmap documented.
- DreamHost environment fingerprint procedure documented.
- Secret-safe repository rules established.
- Shell/runtime fingerprint captured and normalized.
- Database server fingerprint and effective grants captured and normalized.
- Active Data Inspire WordPress installation verified at WordPress 7.0.4.
- Database/schema distribution captured and normalized.
- Effective WordPress/PHP database connection captured: `utf8mb4` + `utf8mb4_unicode_520_ci`.
- Reusable database policy set to clean InnoDB + `utf8mb4` rather than reproducing the historical mixed schema.
- The two legacy schema tables have been identified functionally: one Yoast prominent-words table and one unresolved feeds table.
- DreamHost panel confirms the production website is assigned PHP 8.3 while the default SSH/CLI runtime is PHP 8.2.30.
- The production website runtime has now been measured directly over HTTPS as PHP 8.3.30 / `cgi-fcgi`, with OPcache enabled.
- Phase 1 discovery is complete and no further production diagnostics block the first runtime RC.

## Measured production baseline

The current observation confirms, among other values:

- Ubuntu 24.04.4 LTS;
- Apache 2.4.58;
- website PHP **8.3.30**;
- web SAPI `cgi-fcgi`;
- web `memory_limit` 128M;
- web `max_execution_time` 120 seconds;
- web `max_input_vars` 3000;
- web `post_max_size` / `upload_max_filesize` 512M;
- web OPcache enabled;
- default CLI PHP 8.2.30;
- WP-CLI 2.12.0;
- Git 2.43.0;
- MySQL server 8.0.41;
- SQL mode `NO_ENGINE_SUBSTITUTION`;
- database default `utf8mb3` / `utf8mb3_unicode_ci`;
- WordPress runtime connection `utf8mb4` / `utf8mb4_unicode_520_ci`;
- 47 base tables: 45 already `utf8mb4`, 2 legacy `utf8mb3`;
- 46 InnoDB tables and 1 MyISAM table;
- no current triggers, routines or events.

## Blocking input

**None for `wp-dev-platform v0.1.0-rc1`.**

Migration follow-up, not a platform blocker:

- determine the provenance/current dependency status of the legacy `feeds` table.

Optional but useful:

- current WordPress plugin/theme inventory.

## Next implementation target

**Phase 2 — build `wp-dev-platform v0.1.0-rc1`.**

Planned implementation:

- provider profile `dreamhost-shared`;
- Docker Compose baseline;
- WordPress/Apache + PHP 8.3 runtime targeting PHP 8.3.30 compatibility;
- measured web PHP limits where materially relevant;
- MySQL 8 runtime with compatibility-aware application grants;
- InnoDB + `utf8mb4` default database policy;
- WordPress connection collation aligned with `utf8mb4_unicode_520_ci`;
- QNAP/Portainer-safe initialization;
- Cloudflare `carida_cloudflare` network integration;
- no direct host port exposure in the Carida deployment profile;
- health checks and environment doctor;
- migration helpers and compatibility validation.
