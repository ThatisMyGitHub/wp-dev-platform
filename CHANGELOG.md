# Changelog

All notable platform changes are recorded here.

## [Unreleased]

No unreleased platform changes.

## [0.1.0] - 2026-08-22

### Released

- Promoted the accepted `dreamhost-shared` platform from `v0.1.0-rc1` after successful generic CI and real Carida/QNAP/Portainer acceptance.
- Final deployment model is build/publish/consume: source builds remain in CI/developer workflows while QNAP/Portainer consumes prebuilt validated AMD64 GHCR images.
- Confirmed the complete public path on Carida: Cloudflare HTTPS -> Tunnel -> Apache -> FastCGI -> WordPress/PHP-FPM -> MySQL.

### Fixed during RC acceptance

- Isolated Apache FastCGI routing from shared-network DNS collisions by using the backend-only `wpdev-php-backend` alias.
- Added a project-scoped egress network for WordPress/PHP and WP-CLI so normal core/plugin/theme HTTPS traffic works without exposing the private backend.
- Added safe WordPress `.htaccess` self-healing for incomplete standard WordPress marker blocks while preserving surrounding custom directives and leaving non-standard files untouched.
- Added regression coverage for the shared-network FastCGI collision, outbound HTTPS and malformed WordPress `.htaccess` conditions discovered on the real QNAP host.

### Acceptance evidence

- Fresh WordPress 7.0.4 installation and administrative access through the published HTTPS hostname — PASS.
- Full compatibility doctor for PHP/runtime settings/extensions, MySQL version/settings/grants, WordPress DB charset/collation, outbound HTTPS and Apache -> FastCGI -> PHP — PASS.
- Friendly permalink and uploaded-media delivery through Cloudflare — PASS.
- Ordinary container restart persistence — PASS.
- Portainer pull/redeploy persistence using named volumes — PASS.
- Real-QNAP `.htaccess` self-healing during redeploy — PASS.
- Portable database export (`--single-transaction`, no tablespaces, GTID state or database creation statement) — PASS.
- Post database round-trip WordPress state, permalink, media and final doctor — PASS.

### Release boundary

- Data Inspire production content/database import is intentionally outside this platform release and remains a project migration task.
- Legacy Data Inspire table engines/collations and plugin/theme dependencies remain migration concerns rather than reusable platform requirements.

## [0.1.0-rc1] - 2026-08-22

### Added

- First runnable `dreamhost-shared` Docker Compose profile.
- Apache 2.4 frontend on `carida_cloudflare` with no host-published ports.
- WordPress 7.0.4 / PHP 8.3 FastCGI-compatible runtime, pinned from the official WordPress image family.
- DreamHost-measured PHP limits and OPcache configuration.
- DreamHost provider-capability reference separating current Data Inspire values from settings the Shared plan allows us to configure.
- Optional project-specific PHP INI override layer (`compose.php-overrides.yaml` + `project-overrides.ini.example`) so consumer requirements can be emulated without mutating the reusable baseline.
- Documentation of DreamHost's SFTP/SSH-user scope for PHP setting changes and the resulting customer-isolation recommendation.
- MySQL 8.0.41 compatibility runtime with `NO_ENGINE_SUBSTITUTION`, 32 MiB packet limit and `lower_case_table_names=0`.
- Clean InnoDB + `utf8mb4` / `utf8mb4_unicode_520_ci` reusable database policy.
- Application database privilege restriction matching the measured DreamHost account and intentionally omitting `EVENT` and global administrative privileges.
- QNAP-safe persistent WordPress initialization based on the HCF tar-copy pattern.
- Internal project backend network plus external `carida_cloudflare` integration.
- Health checks for MySQL, PHP-FPM and Apache.
- WP-CLI 2.12.0 administrative path running under the PHP 8.3 application image.
- Optional development-only Adminer profile.
- Compatibility doctor and guarded database import/export helpers.
- Secret-safe `.env.example` and explicit DreamHost compatibility contract.

### Compatibility notes

- Production DreamHost reports PHP 8.3.30 with `cgi-fcgi`; development uses PHP-FPM FastCGI (`fpm-fcgi`) behind Apache as an explicit transport-level approximation.
- Production Apache 2.4.58 is documented, while development uses a current Apache 2.4 patch rather than deliberately pinning an older web-server patch.
- DreamHost's legacy `utf8mb3` database defaults are not reproduced for new databases because the measured WordPress runtime is already `utf8mb4`.
- DreamHost can expose additional PHP versions/settings/extensions/OPcache controls; they are treated as provider capabilities to use only when a consumer requirement justifies and validates them.

## [0.1.0-dev.0] - 2026-08-22

Initial project bootstrap and DreamHost discovery baseline. No runnable platform release at this version.
