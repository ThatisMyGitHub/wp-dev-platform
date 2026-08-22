# Changelog

All notable platform changes are recorded here.

## [Unreleased]

### Pending

- Carida/Portainer deployment validation of the first DreamHost runtime RC.
- Fresh-install, persistence, permalink, upload, privilege and migration dry-run tests.

## [0.1.0-rc1] - 2026-08-22

### Added

- First runnable `dreamhost-shared` Docker Compose profile.
- Apache 2.4 frontend on `carida_cloudflare` with no host-published ports.
- WordPress 7.0.4 / PHP 8.3 FastCGI-compatible runtime, pinned from the official WordPress image family.
- DreamHost-measured PHP limits and OPcache configuration.
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

## [0.1.0-dev.0] - 2026-08-22

Initial project bootstrap and DreamHost discovery baseline. No runnable platform release at this version.
