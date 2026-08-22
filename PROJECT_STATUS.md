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

The DreamHost Shared profile records both the current Data Inspire values and the hosting-plan configuration capabilities available when a future solution needs them.

Documented capabilities include per-site PHP version selection, panel-adjustable PHP limits, temporary PHP warnings, optional PHP extensions, OPcache settings/information, custom PHP configuration, configurable website document roots and other provider-managed website services.

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
- explicit compatibility contract documenting intentional approximations;
- source-build overlay retained for CI/developer verification;
- Portainer/QNAP deployment manifest is build-free and consumes validated GHCR runtime images.

Optional extensions are not preinstalled merely because DreamHost can enable them. If a consumer requires one, the development runtime image must add it explicitly and production support must be validated.

## Intentional compatibility approximations

- DreamHost reports `cgi-fcgi`; RC1 uses PHP-FPM FastCGI (`fpm-fcgi`) behind Apache. The Apache -> FastCGI -> PHP execution boundary is preserved.
- DreamHost Apache is 2.4.58; RC1 uses a current Apache 2.4 patch instead of deliberately pinning an older web-server patch.
- DreamHost's database/server defaults are historically `utf8mb3`; RC1 creates clean `utf8mb4` databases because the measured WordPress application connection is already `utf8mb4`.
- DreamHost's default SSH PHP is 8.2.30; RC1 deliberately runs bundled WP-CLI under the PHP 8.3 application runtime for deterministic project tooling.

## Automated RC validation — GREEN

The current RC publication pipeline validates the runtime from source before publishing deployment images. The full strengthened gate verifies:

1. Compose deployment and source-build model validation.
2. Fresh source builds from the pinned WordPress, Apache and MySQL bases.
3. Fresh runtime startup with health checks.
4. WordPress 7.0.4 installation.
5. Compatibility doctor pass for PHP, required extensions, MySQL settings/grants, WordPress DB connection and Apache -> FastCGI -> PHP execution.
6. Real friendly permalink request through Apache returning HTTP 200.
7. Media import with the stored `_wp_attached_file` path requested directly through Apache and returning HTTP 200.
8. Runtime restart followed by successful WordPress, permalink and uploaded-media persistence verification.
9. Database export/import round trip using the guarded migration helpers.
10. Final compatibility doctor pass after the round trip.
11. On `dev` pushes, the exact validated AMD64 images are authenticated and pushed to GHCR only after the preceding checks pass.
12. Clean teardown of the disposable validation environment.

## Carida/QNAP validation status

Initial Portainer source-build attempts exposed that native PHP-extension compilation should not be part of the NAS deployment path. RC1 was therefore changed to a build/publish/consume model:

- CI/developer builds use `compose.build.yaml` and compile from source;
- the validated runtime images are published to GHCR;
- Portainer/QNAP uses `compose.yaml` only and pulls prebuilt images;
- QNAP is not required to compile PHP extensions during deployment.

Registry/architecture gate is now **PASS** on Carida. Direct anonymous pulls from the QNAP Docker daemon succeeded for all three public RC images and each image was confirmed as `linux/amd64`:

- `ghcr.io/thatismygithub/wp-dev-platform-wordpress:0.1.0-rc1`
  - registry digest: `sha256:28714327339f7be9d4ba07271c93081b724d3a04fd6006bee748434a0522b66b`
  - local image ID: `sha256:136d89ee91be5f0e83aa1de0637ea7f7c02dac3b804a43b8f7b6023ce22c7f47`
- `ghcr.io/thatismygithub/wp-dev-platform-httpd:0.1.0-rc1`
  - registry digest: `sha256:c218ae7e785a53f161fb59c4e02cf0db53849ce0f3b0747acc6a6d621032ea99`
  - local image ID: `sha256:1a94b1d111f4e933586512868744903af9c718f5d251de7fb5b0f272abc1bc51`
- `ghcr.io/thatismygithub/wp-dev-platform-mysql:0.1.0-rc1`
  - registry digest: `sha256:ef294eb37bc6932dd864bd323e037d69c3e9f8710710d7b280e9c2aea8ad4a59`
  - local image ID: `sha256:282feba2ae53ba49cd841c5da868a3ee4721e4ba6ff4d32ae33e3d8c2f5737b6`

The next Carida action is to **Pull and redeploy** the existing Git-managed `wpdev-rc1` stack from current `dev` without deleting volumes or changing development credentials.

After a successful runtime start, continue with MySQL initialization, QNAP-safe WordPress volume initialization, Apache/FastCGI, Cloudflare publication, browser installation, doctor, permalinks/uploads, persistence and migration checks described in `profiles/dreamhost-shared/VALIDATION.md`.

## Migration follow-up — not an RC1 platform blocker

- determine the provenance/current dependency status of the legacy Data Inspire `feeds` table;
- inventory current Data Inspire plugins/themes before importing the existing site into the validated platform.

## Next release target

If RC1 passes Carida/QNAP validation without architecture-changing fixes, promote the accepted platform to **`v0.1.0`** and then pin `datainspire-web` to that released version.
