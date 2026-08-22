# DreamHost Shared profile — v0.1.0-rc1

First runnable provider profile for `wp-dev-platform`. It adapts the HCF development/deployment pattern to the measured Data Inspire DreamHost Shared environment.

## Runtime topology

```text
Cloudflare Tunnel
       |
       v
Apache 2.4 (`web`)
       |
       | FastCGI
       v
WordPress / PHP 8.3 (`wordpress`)
       |
       v
MySQL 8.0.41 (`db`)
```

`web` joins the external `carida_cloudflare` network. `wordpress` and `db` communicate on a project-scoped internal backend network. No ports are published on the QNAP host by default.

The split Apache + PHP-FPM layout intentionally reproduces DreamHost's Apache -> FastCGI execution model more closely than the single-container `wordpress:apache` image would.

RC1 bakes the reviewed Apache configuration, DreamHost PHP baseline, compatibility doctor and MySQL privilege initialization into locally-built versioned images. The default stack therefore does not rely on QNAP host bind-mount paths for those core configuration files.

## Measured baseline vs configurable hosting plan

RC1 defaults reproduce the current Data Inspire production runtime. They are **not a declaration that DreamHost Shared cannot be tuned differently**.

The current plan exposes configuration capabilities including PHP-version selection, general PHP limits, optional extensions, OPcache configuration/information, custom PHP configuration and website directory mapping. See:

`provider-capabilities.md`

That document is part of the provider contract and should be consulted when Data Inspire or a future customer needs a setting beyond the current baseline.

A particularly important hosting constraint is that DreamHost PHP-setting changes can affect all websites assigned to the same SFTP/SSH user. Independent customer sites should therefore use appropriately isolated hosting users when different tuning may be required.

## Quick start

Prerequisites:

- Docker Compose / Portainer with Compose-spec support.
- Existing external network `carida_cloudflare` (or set `CLOUDFLARE_NETWORK`).
- A Cloudflare Tunnel route targeting the configured `CLOUDFLARE_ALIAS` on port 80.

Prepare the profile:

```bash
cp .env.example .env
# Edit .env and replace CHANGE_ME values and WP_URL.
docker compose --env-file .env -f compose.yaml config -q
docker compose --env-file .env -f compose.yaml up -d --build
```

The WordPress files are initialized into a persistent named volume using the QNAP-safe tar-copy pattern proven in HCF.

For the canonical Carida/Portainer RC validation procedure, see `VALIDATION.md`.

## Optional project-specific PHP tuning

Do not edit `php/zz-dreamhost.ini` merely because one consumer needs different provider-supported settings. Instead use the opt-in override layer:

```bash
cp php/project-overrides.ini.example php/project-overrides.ini
# Edit php/project-overrides.ini with values verified for the target DreamHost site/user.

docker compose --env-file .env \
  -f compose.yaml \
  -f compose.php-overrides.yaml \
  up -d --build
```

`php/project-overrides.ini` is ignored by this reusable repository. A consumer project that requires a persistent non-secret override should document/version that requirement in its own project overlay.

`WP_MEMORY_LIMIT` and `WP_MAX_MEMORY_LIMIT` are also explicit environment settings so WordPress's own memory policy can follow a validated PHP-memory override instead of remaining hard-coded to the Data Inspire baseline.

INI overrides cannot install PHP extensions. If a solution requires a DreamHost-supported optional extension such as `gmp` or `tidy`, the development runtime must be extended deliberately and production availability verified before release.

## First WordPress installation

After the stack is healthy, open `WP_URL` and complete the normal WordPress installation, or use the WP-CLI helper from a checked-out host environment:

```bash
./scripts/wp.sh core version
```

WP-CLI 2.12.0 is baked into the PHP 8.3 application image rather than inheriting an unrelated host CLI PHP version.

Inside the running WordPress container it is also available directly:

```bash
wp --allow-root core version
```

## Compatibility doctor

After WordPress has been installed, the canonical compatibility check is available **inside the WordPress container**:

```bash
wpdev-doctor
```

This is intentionally Portainer-friendly. It verifies the PHP family/limits/extensions, MySQL version/settings/grants, WordPress database connection and the actual Apache -> FastCGI -> PHP request path.

From a checked-out host environment the wrapper remains available:

```bash
./scripts/doctor.sh
```

If project-specific PHP overrides are active, their expected values must be added to the consumer project's validation rather than changing the generic RC1 doctor's baseline assertions.

## Development-only Adminer

Adminer is disabled by default. Start it only when needed:

```bash
docker compose --env-file .env -f compose.yaml --profile tools up -d adminer
```

It joins `carida_cloudflare` under `ADMINER_ALIAS`, but it is not publicly reachable unless a Cloudflare Tunnel route is explicitly created. Remove that route and stop the service after use.

## Database export/import

```bash
./scripts/db-export.sh
CONFIRM_IMPORT=1 ./scripts/db-import.sh backups/database-YYYYMMDD-HHMMSS.sql
```

Exports are written under `backups/` by default and are ignored by Git. Export uses shared-host-compatible options that do not require MySQL `PROCESS` and do not embed GTID state. Import is deliberately gated by `CONFIRM_IMPORT=1`.

## Automated RC gate

`.github/workflows/dreamhost-rc.yml` builds and exercises the profile on a clean GitHub Linux runner. It validates image builds, Compose startup, fresh WordPress installation, the compatibility doctor, permalinks, media upload, restart persistence and a database export/import round trip.

This automated gate complements rather than replaces the QNAP/Portainer/Cloudflare validation in `VALIDATION.md`.

## Important initialization behavior

The database privilege restriction script runs only when the MySQL volume is initialized for the first time. If the privilege model changes during an RC and you are working with disposable development data, recreate the MySQL volume before re-testing. Never do that to a volume containing data you need to preserve.

## Production boundary

This Compose stack is not deployed to DreamHost. Production migration remains a controlled transfer of WordPress files/database/configuration to the shared-hosting environment.

See `compatibility.md`, `provider-capabilities.md`, `VALIDATION.md`, and `reference/` for the measured compatibility rationale, provider configuration envelope and acceptance procedure. Raw production fingerprints are never committed.
