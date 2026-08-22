# Project Status

## Current phase

**Phase 1 — DreamHost discovery and measured compatibility baseline**

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
- No runnable production-emulation stack has been finalized yet.

## Measured production baseline captured

The current observation confirms, among other values:

- Ubuntu 24.04.4 LTS;
- Apache 2.4.58;
- default CLI PHP 8.2.30;
- WP-CLI 2.12.0;
- Git 2.43.0;
- MySQL server 8.0.41;
- SQL mode `NO_ENGINE_SUBSTITUTION`;
- database default `utf8mb3` / `utf8mb3_unicode_ci`;
- 47 base tables: 45 already `utf8mb4`, 2 legacy `utf8mb3`;
- 46 InnoDB tables and 1 MyISAM table;
- no current triggers, routines or events.

CLI values are not yet being treated as authoritative web/FastCGI values.

## Remaining blocking input

Before finalizing the first runnable DreamHost profile we still require:

1. identify the two legacy `utf8mb3` tables and assess whether they are active dependencies;
2. confirm the charset/collation negotiated by WordPress over its PHP database connection;
3. PHP version assigned to the Data Inspire website in the DreamHost panel;
4. web/FastCGI PHP runtime confirmation where practical.

Optional but useful:

- current WordPress plugin/theme inventory.

## Next implementation target

`wp-dev-platform v0.1.0-rc1`

Planned after fingerprint review:

- provider profile `dreamhost-shared`;
- Docker Compose baseline;
- WordPress/PHP runtime;
- MySQL 8 runtime with compatibility-aware application grants;
- explicit charset/collation policy derived from the measured schema and migration requirements;
- QNAP/Portainer-safe initialization;
- Cloudflare network integration;
- health checks and environment doctor;
- migration helpers and compatibility validation.
