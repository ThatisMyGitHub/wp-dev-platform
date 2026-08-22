# DreamHost Shared compatibility contract — v0.1.0-rc1

This profile emulates the production-relevant behavior measured from the Data Inspire DreamHost Shared Unlimited environment on 2026-08-22.

## Baseline vs provider capability envelope

The RC1 defaults represent the **measured Data Inspire production baseline**, not every setting that DreamHost Shared can support.

DreamHost exposes configurable PHP and website settings that can be used when a project has a justified requirement. Those provider capabilities are documented separately in:

`provider-capabilities.md`

Project-specific tuning must not silently mutate this reusable baseline. It should be implemented as an explicit consumer/deployment override, validated against DreamHost, and then measured in the effective production web runtime.

## Application runtime target

- WordPress baseline: 7.0.4.
- Production web PHP: **8.3.30**.
- Production SAPI: `cgi-fcgi`.
- RC1 immutable WordPress/PHP image currently resolves to PHP **8.3.33**.
- Development transport: Apache 2.4.68 proxying PHP requests to PHP-FPM over FastCGI.
- Development SAPI: `fpm-fcgi`.
- OPcache enabled.
- Effective web PHP limits: 128M memory, 120 s execution time, -1 input time, 3000 input variables, 512M POST/upload limits, 20 files, 60 s socket timeout.

### PHP patch-level policy

Production is measured at PHP 8.3.30 while RC1's immutable official WordPress 7.0.4 / PHP 8.3 image currently contains PHP 8.3.33. This is an **intentional maintenance-patch approximation within the same PHP 8.3 minor line**, not an unnoticed mismatch.

The platform prioritizes:

- the same PHP 8.3 language/runtime family;
- the same measured web limits;
- the same relevant extension envelope;
- the same WordPress version baseline;
- current security/maintenance fixes available in the immutable upstream image.

The compatibility doctor therefore requires PHP 8.3.x and validates the behavior/settings that matter to the application. It does not require an obsolete exact PHP patch when that patch is no longer the maintained upstream container runtime.

A consumer that depends on patch-specific PHP behavior must explicitly document and validate that dependency rather than assuming patch-level identity.

### FastCGI/SAPI approximation

DreamHost reports `cgi-fcgi`; development reports `fpm-fcgi`. This is intentional: requests still cross the Apache -> FastCGI -> PHP execution boundary, preserving the hosting behavior relevant to WordPress while avoiding a bespoke CGI image that would be harder to maintain and less representative of modern container practice.

### Apache patch policy

Production Apache measured 2.4.58. RC1 uses **Apache 2.4.68**, pinned by digest for reproducibility. We deliberately do not preserve an older Apache maintenance patch merely for numeric identity. WordPress `.htaccess`, rewrite, headers and FastCGI behavior are the compatibility targets.

## Fresh-install `.htaccess` policy

DreamHost/Apache production behavior depends on WordPress rewrite rules in `.htaccess`. The RC1 WordPress initialization therefore seeds the standard root WordPress rewrite file **only when the persistent WordPress volume has no `.htaccess` at all**.

This rule is deliberately conservative:

- a clean new volume receives standard WordPress root rewrite rules so friendly permalinks work immediately under Apache;
- an existing or migrated `.htaccess` is always preserved;
- RC initialization never replaces customer/provider-specific rewrite, redirect or security rules.

The automated RC gate creates a published post and requests its friendly URL through Apache, so permalink compatibility is validated as an HTTP behavior rather than inferred from the WordPress option alone.

## PHP customization support

The current DreamHost Shared plan provides a wider configuration surface than the RC1 defaults, including PHP-version selection, general PHP limits, optional extensions, OPcache controls/information and custom PHP configuration mechanisms.

The profile includes an **opt-in local PHP override layer** for development emulation:

```bash
cp php/project-overrides.ini.example php/project-overrides.ini
# Edit only settings confirmed for the target DreamHost site/user.
docker compose --env-file .env \
  -f compose.yaml \
  -f compose.php-overrides.yaml \
  up -d --build
```

This override mechanism is intentionally not active in the default RC1 startup.

Optional PHP extensions are different from INI settings: if a project requires an extension such as `gmp` or `tidy`, the development PHP image must actually install the extension and DreamHost must be confirmed to enable it for the target site/user.

DreamHost PHP settings can be scoped to the SFTP/SSH user. Therefore customer/site isolation at the hosting-user level is an architectural concern when independent PHP tuning may be required.

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

- DreamHost web PHP 8.3.30 uses `cgi-fcgi`; RC1 currently uses PHP 8.3.33 through PHP-FPM FastCGI (`fpm-fcgi`).
- DreamHost Apache measured 2.4.58; RC1 uses digest-pinned Apache 2.4.68.
- DreamHost shell PHP defaults to 8.2.30, while the development application and bundled WP-CLI runtime use the PHP 8.3 application image for deterministic project tooling.
- DreamHost's MySQL host has legacy `utf8mb3` defaults; new development databases intentionally default to `utf8mb4`.

These differences are explicit, measured where possible, and must not be mistaken for bit-for-bit hosting parity.
