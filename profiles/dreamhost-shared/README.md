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

See `compatibility.md` and `reference/` for the measured compatibility rationale. Raw production fingerprints are never committed.
