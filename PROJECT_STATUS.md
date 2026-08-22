# Project Status

## Current phase

**Phase 2 — `wp-dev-platform v0.1.0-rc1` Carida/QNAP validation**

## Phase 1 result

DreamHost discovery is complete. The normalized production compatibility baseline confirms:

- Ubuntu 24.04.4 LTS host family;
- Apache 2.4.58 on DreamHost;
- production website PHP 8.3.30 via `cgi-fcgi`;
- default DreamHost SSH/CLI PHP 8.2.30;
- WordPress 7.0.4;
- WP-CLI 2.12.0;
- MySQL server 8.0.41;
- SQL mode `NO_ENGINE_SUBSTITUTION`;
- 32 MiB `max_allowed_packet`;
- effective WordPress database connection `utf8mb4` / `utf8mb4_unicode_520_ci`;
- measured database-scoped application grants;
- 47 current production tables, with two legacy `utf8mb3` tables and one legacy MyISAM table treated as Data Inspire migration concerns rather than platform requirements.

Raw fingerprints and account-specific identifiers remain outside the public repository.

## Provider capability envelope captured

The DreamHost Shared profile now records not only the current Data Inspire values but also the hosting-plan configuration capabilities available when a future solution needs them.

Documented capabilities include:

- per-site PHP version selection;
- panel-adjustable PHP limits (`memory_limit`, upload/post sizes, execution/input times and input variables);
- temporary PHP warnings;
- optional PHP extensions exposed by DreamHost, including `gmp` and `tidy`;
- OPcache settings/information and advanced controls where the selected PHP version/plan permits them;
- custom PHP configuration through DreamHost's PHP configuration mechanism;
- configurable website document-root/directory mapping;
- other provider-managed website services such as DNS, SSL/security, logs, file/migration tools and IP options where available.

Important scope rule: DreamHost documents PHP-setting changes as applying to all websites assigned to the same SFTP/SSH user. Future independent customers/sites should therefore use appropriately isolated hosting users when different PHP tuning may be required.

See `profiles/dreamhost-shared/provider-capabilities.md`.

## RC1 implementation status

The first runnable `dreamhost-shared` profile is present on `dev` and the repository version is `0.1.0-rc1`.

Implemented:

- Docker Compose runtime;
- split Apache -> FastCGI -> WordPress/PHP topology;
- PHP 8.3 application runtime aligned with the measured DreamHost web family;
- measured PHP limits and OPcache settings;
- opt-in project-specific PHP INI override layer without mutating the reusable baseline;
- MySQL 8.0.41 compatibility runtime;
- clean InnoDB + `utf8mb4` reusable database defaults;
- WordPress-oriented `utf8mb4_unicode_520_ci` collation policy;
- restricted application user matching the measured DreamHost privilege set;
- internal backend network;
- external `carida_cloudflare` frontend integration;
- no host-published application/database ports;
- persistent project-scoped WordPress and MySQL volumes;
- QNAP-safe WordPress initialization based on the HCF tar-copy pattern;
- container health checks;
- secret-safe `.env.example`;
- WP-CLI 2.12.0 administrative helper under the PHP 8.3 runtime;
- optional Adminer tools profile;
- compatibility `doctor` script;
- guarded database export/import helpers;
- explicit compatibility contract documenting intentional approximations.

Optional extensions are not preinstalled merely because DreamHost can enable them. If a consumer requires one, the development runtime image must add it explicitly and production support must be validated.

## Intentional compatibility approximations

- DreamHost reports `cgi-fcgi`; RC1 uses PHP-FPM FastCGI (`fpm-fcgi`) behind Apache. The Apache -> FastCGI -> PHP execution boundary is preserved.
- DreamHost Apache is 2.4.58; RC1 uses a current Apache 2.4 patch instead of deliberately pinning an older web-server patch.
- DreamHost's database/server defaults are historically `utf8mb3`; RC1 creates clean `utf8mb4` databases because the measured WordPress application connection is already `utf8mb4`.
- DreamHost's default SSH PHP is 8.2.30; RC1 deliberately runs bundled WP-CLI under the PHP 8.3 application runtime for deterministic project tooling.

## Automated RC validation — GREEN

The strengthened GitHub Actions gate completed successfully on 2026-08-22 for RC head `1ba8e485ddc3f11b1cb096c39cb5959dbf0b8db8` (DreamHost RC validation run #40).

Verified automatically on a clean Linux/Docker runner:

1. Compose model validation.
2. Fresh image builds from the pinned WordPress, Apache and MySQL bases.
3. Fresh runtime startup with health checks.
4. WordPress 7.0.4 installation.
5. Compatibility doctor pass for PHP, required extensions, MySQL settings/grants, WordPress DB connection and Apache -> FastCGI -> PHP execution.
6. Real friendly permalink request through Apache returning HTTP 200.
7. Media import with the stored `_wp_attached_file` path requested directly through Apache and returning HTTP 200.
8. Runtime restart followed by successful WordPress, permalink and uploaded-media persistence verification.
9. Database export/import round trip using the guarded migration helpers.
10. Final compatibility doctor pass after the round trip.
11. Clean teardown of the disposable validation environment.

The earlier theme/API-dependent media URL assertion was removed in favor of the provider-relevant invariant: the attachment record/path and physical upload must survive restart and remain directly servable through Apache.

## Remaining RC1 acceptance gate

**Generic Linux/Docker validation is complete.** RC1 is still not accepted or tagged as `v0.1.0` because it must now pass the actual Carida/QNAP/Portainer environment gate.

Next validation on Carida:

1. Compose/build succeeds on QNAP/Portainer.
2. MySQL initializes with the intended grants/settings.
3. QNAP-safe WordPress volume initialization succeeds.
4. Apache reaches PHP-FPM through FastCGI.
5. Cloudflare Tunnel reaches the Apache service through `carida_cloudflare`.
6. WordPress installation/admin/login work through the published HTTPS development hostname.
7. `wpdev-doctor` passes from the WordPress container.
8. Restart/redeploy persistence is confirmed on QNAP volumes.
9. Permalinks/`.htaccess`, uploads and WP-CLI are exercised through the real published route.
10. Database export/import dry run succeeds on Carida.

See `profiles/dreamhost-shared/VALIDATION.md` for the execution procedure.

## Migration follow-up — not an RC1 platform blocker

- determine the provenance/current dependency status of the legacy Data Inspire `feeds` table;
- inventory current Data Inspire plugins/themes before importing the existing site into the validated platform.

## Next release target

If RC1 passes Carida/QNAP validation without architecture-changing fixes, promote the accepted platform to **`v0.1.0`** and then pin `datainspire-web` to that released version.
