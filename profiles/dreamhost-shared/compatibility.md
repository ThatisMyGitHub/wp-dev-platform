# DreamHost Shared compatibility contract — v0.1.0-rc1

This profile emulates the production-relevant behavior measured from the Data Inspire DreamHost Shared Unlimited environment on 2026-08-22.

## Application runtime target

- WordPress baseline: 7.0.4.
- Production web PHP: 8.3.30.
- Production SAPI: `cgi-fcgi`.
- Development transport: Apache 2.4 proxying PHP requests to PHP-FPM over FastCGI.
- Development PHP family: 8.3, pinned through the WordPress base-image reference.
- OPcache enabled.
- Effective PHP limits: 128M memory, 120 s execution time, 3000 input variables, 512M POST/upload limits, 20 files, 60 s socket timeout.

The development SAPI reports `fpm-fcgi`, not `cgi-fcgi`. This is an intentional compatibility approximation: requests still cross Apache -> FastCGI -> PHP, which preserves the hosting behavior that matters to WordPress while avoiding a custom unsupported CGI image.

Apache is kept on the current 2.4 line rather than deliberately pinning the development proxy to DreamHost's older 2.4.58 patch. WordPress `.htaccess`, rewrite and FastCGI behavior are the compatibility target; the hosting-provider patch level remains recorded in the sanitized fingerprint.

## Database target

- MySQL 8.0.41 compatibility baseline.
- SQL mode: `NO_ENGINE_SUBSTITUTION`.
- `max_allowed_packet`: 32 MiB.
- `lower_case_table_names`: 0.
- Clean reusable schema policy: InnoDB + `utf8mb4`.
- WordPress connection collation: `utf8mb4_unicode_520_ci`.

DreamHost's historical server/database defaults are `utf8mb3`, but the measured WordPress connection is already `utf8mb4` and 45 of 47 production tables are `utf8mb4`. New platform databases therefore do not reproduce the historical mixed schema.

## Application database privileges

The development application user is restricted to the measured DreamHost database-scoped privilege set:

`SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, TRIGGER`

`EVENT`, global administrative privileges and `GRANT OPTION` are intentionally absent.

## Hosting constraints represented by the profile

- No application/database host ports are published by default.
- Database traffic stays on an internal Docker network.
- Only the Apache frontend joins `carida_cloudflare` in the default profile.
- No persistent application worker/process is required.
- Docker is development infrastructure only; DreamHost production deployment remains files + database + hosting configuration.
- Secrets live in local `.env`, never in Git.

## Known differences from production

- DreamHost web PHP uses `cgi-fcgi`; development uses PHP-FPM FastCGI (`fpm-fcgi`).
- DreamHost Apache measured 2.4.58; development uses a current Apache 2.4 patch.
- DreamHost shell PHP defaults to 8.2.30, while the development application and bundled WP-CLI runtime use PHP 8.3 for deterministic project behavior.
- DreamHost's MySQL host has legacy `utf8mb3` defaults; new development databases intentionally default to `utf8mb4`.

These differences are explicit and must not be mistaken for unmeasured parity.
