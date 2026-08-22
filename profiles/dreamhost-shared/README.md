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

INI overrides cannot install PHP extensions. If a solution requires a DreamHost-supported optional extension such as `gmp` or `tidy`, the development runtime must be extended deliberately and production availability verified before release.

## First WordPress installation

After the stack is healthy, open `WP_URL` and complete the normal WordPress installation, or use the WP-CLI helper:

```bash
./scripts/wp.sh core version
```

The helper runs WP-CLI 2.12.0 inside the PHP 8.3 application image rather than inheriting an unrelated host CLI PHP version.

## Compatibility doctor

After WordPress has been installed:

```bash
./scripts/doctor.sh
```

The doctor checks Compose validity, PHP family/limits, MySQL version/settings, application grants, and WordPress's effective database charset/collation.

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

Exports are written under `backups/` by default and are ignored by Git. Import is deliberately gated by `CONFIRM_IMPORT=1`.

## Important initialization behavior

The database privilege restriction script runs only when the MySQL volume is initialized for the first time. If the privilege model changes during an RC and you are working with disposable development data, recreate the MySQL volume before re-testing. Never do that to a volume containing data you need to preserve.

## Production boundary

This Compose stack is not deployed to DreamHost. Production migration remains a controlled transfer of WordPress files/database/configuration to the shared-hosting environment.

See `compatibility.md`, `provider-capabilities.md`, and `reference/` for the measured compatibility rationale and provider configuration envelope. Raw production fingerprints are never committed.
