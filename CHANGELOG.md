# Changelog

All notable platform changes are recorded here.

## [Unreleased]

### Validation

- Enhanced generic Linux/Docker RC gate is green on 2026-08-22 (DreamHost RC validation run #40).
- Fresh install, compatibility doctor, real Apache permalink delivery, uploaded-media delivery, restart persistence, database export/import round trip and final doctor all passed.
- Media validation now uses the persisted WordPress attachment path (`_wp_attached_file`) and direct Apache delivery rather than theme/API-dependent attachment URL rendering.

### Pending

- Carida/QNAP/Portainer deployment validation of the first DreamHost runtime RC.
- Cloudflare Tunnel publication and HTTPS-route validation on the actual Carida environment.
- QNAP volume persistence/redeploy validation and Carida-side migration dry run.

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
