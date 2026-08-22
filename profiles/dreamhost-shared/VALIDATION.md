# Carida / Portainer validation — `dreamhost-shared` v0.1.0-rc1

This procedure validates the first DreamHost Shared release candidate on the real Carida/QNAP development host before the platform can be promoted to `v0.1.0`.

The validation environment is disposable. Do **not** import the production Data Inspire database during the initial RC validation.

## 1. Preconditions

Before deployment confirm:

- the external Docker network `carida_cloudflare` already exists;
- the RC uses a dedicated development hostname, not the production Data Inspire hostname;
- the chosen stack/project slug does not collide with HCF or another Carida stack;
- new development-only MySQL passwords have been generated;
- no production credentials are entered into Git or committed files.

Recommended validation identifiers:

```text
Portainer stack:      wpdev-rc1
WPDEV_PROJECT_SLUG:   wpdev-rc1
CLOUDFLARE_ALIAS:     wpdev-rc1-web
MYSQL_DATABASE:       wpdev_rc1
MYSQL_USER:           wpdev_rc1
```

The MySQL database/user names intentionally use underscores because the RC privilege bootstrap only accepts alphanumeric characters and underscores.

## 2. Preferred Portainer deployment mode

Use **Stacks -> Add stack -> Repository** so all Docker build contexts are taken from the reviewed Git tree.

Configure:

```text
Repository URL:       https://github.com/ThatisMyGitHub/wp-dev-platform.git
Repository reference: refs/heads/dev
Compose path:         profiles/dreamhost-shared/compose.yaml
```

Do not enable automatic updates while validating RC1. Each update should be deliberate so the tested Git commit is known.

### Required stack environment values

Set at least:

```text
WPDEV_PROJECT_SLUG=wpdev-rc1
TZ=UTC

WP_URL=https://<RC1-DEVELOPMENT-HOSTNAME>
WP_ENVIRONMENT=development
WP_DEBUG=true
WP_TABLE_PREFIX=wp_
WP_POST_REVISIONS=10
WP_MEMORY_LIMIT=128M
WP_MAX_MEMORY_LIMIT=128M

CLOUDFLARE_NETWORK=carida_cloudflare
CLOUDFLARE_ALIAS=wpdev-rc1-web

MYSQL_DATABASE=wpdev_rc1
MYSQL_USER=wpdev_rc1
MYSQL_PASSWORD=<NEW-DEVELOPMENT-ONLY-PASSWORD>
MYSQL_ROOT_PASSWORD=<NEW-DEVELOPMENT-ONLY-ROOT-PASSWORD>
```

The versioned base-image variables in `.env.example` are optional in Portainer because `compose.yaml` contains the RC1 defaults. Supply them only when intentionally overriding/pinning a different reviewed image.

## 3. Initial deployment expectations

Deploy the stack.

Expected default services:

- `db` — running and healthy;
- `wordpress-init` — completes successfully and exits with code 0;
- `wordpress` — running and healthy;
- `web` — running and healthy.

`wpcli` and `adminer` are tools-profile services and should not be running by default.

The RC1 base configuration is baked into the built images. The default stack does not depend on QNAP host bind-mount paths for Apache configuration, PHP INI settings, or the MySQL initialization script.

### Network expectations

Verify in Portainer:

- `db` is connected only to `<slug>_backend`;
- `wordpress` is connected only to `<slug>_backend`;
- `web` is connected to `<slug>_backend` and `carida_cloudflare`;
- `<slug>_backend` is internal;
- no application or database host ports are published.

### Volume expectations

Named volumes should exist:

```text
wpdev-rc1_wordpress_data
wpdev-rc1_mysql_data
```

The WordPress volume must contain the normal WordPress tree after `wordpress-init` completes.

## 4. Review logs before publishing

Before creating a Cloudflare public route, inspect the service logs.

There should be no fatal errors from:

- MySQL initialization or the restricted-user grant script;
- WordPress volume initialization;
- PHP-FPM startup;
- Apache configuration/startup.

The MySQL initialization script is expected to execute only on the first creation of the MySQL data volume.

## 5. Cloudflare Tunnel publication

After the internal stack is healthy, add a temporary development hostname to the existing Carida Cloudflare Tunnel.

Route the hostname to:

```text
http://wpdev-rc1-web:80
```

Use the same public URL as `WP_URL`.

Do not route the hostname directly to `wordpress`, `db`, or a QNAP host port.

## 6. Fresh WordPress installation

Open the temporary development URL and complete a fresh WordPress installation through the browser.

Do not reuse production Data Inspire administrator credentials for this disposable validation instance.

After installation confirm:

- home page loads through HTTPS;
- `/wp-admin/` login works;
- WordPress reports the expected RC core version;
- no redirect loop occurs behind Cloudflare;
- media/admin requests remain HTTPS.

## 7. Canonical compatibility doctor

In Portainer open a console on the running `wordpress` service/container and execute:

```bash
wpdev-doctor
```

A successful run must report PASS for:

- PHP 8.3 runtime;
- measured PHP limits and OPcache;
- DreamHost-compatible PHP extension baseline;
- MySQL 8.0.41;
- SQL mode / packet / case / charset / collation / InnoDB defaults;
- measured application privilege envelope;
- WordPress installed state;
- effective WordPress `utf8mb4` / `utf8mb4_unicode_520_ci` connection;
- Apache -> FastCGI -> PHP request path.

Save the terminal output as validation evidence, but do not commit passwords, container environment dumps, or other secrets.

## 8. Permalink and `.htaccess` validation

In the WordPress admin:

1. open **Settings -> Permalinks**;
2. select a non-plain structure such as **Post name**;
3. save;
4. create a temporary post;
5. confirm its friendly URL loads through the Cloudflare hostname.

This validates Apache `mod_rewrite`, `.htaccess`, the shared WordPress volume and FastCGI routing together.

## 9. Upload/media validation

Upload a small image through **Media -> Add New** and confirm:

- the upload succeeds;
- the image can be opened publicly;
- metadata/thumbnails are generated normally;
- the file survives a container restart.

## 10. Restart and redeploy persistence

Restart `db`, `wordpress`, and `web` from Portainer.

Confirm:

- WordPress remains installed;
- the temporary post remains available;
- uploaded media remains available;
- no new WordPress install is triggered;
- database data persists.

Then perform a controlled stack redeploy from the same `dev` commit without deleting volumes and repeat the same checks.

## 11. Tools profile

Adminer is not part of the default runtime. If database UI validation is required, enable the `tools` profile deliberately and publish it only through a temporary, access-controlled Cloudflare route.

Remove the route and stop Adminer immediately after use.

WP-CLI is baked into the WordPress runtime and can also be executed directly from the `wordpress` container console:

```bash
wp --allow-root core version
wp --allow-root option get siteurl
```

## 12. Export/import dry run

The repository contains guarded host-side helpers:

```bash
scripts/db-export.sh
scripts/db-import.sh
```

They are intended for an SSH/checked-out-repository workflow and deliberately do not live inside the web container. The export uses shared-host-safe options including `--no-tablespaces` and disables GTID state.

If the Carida host checkout/SSH workflow is available, run a disposable export/import round trip after all other checks pass. Otherwise the automated GitHub RC workflow provides the generic Docker round-trip test, and the Carida-specific migration rehearsal is performed before `v0.1.0` acceptance.

## 13. RC acceptance record

Record the following for the exact tested Git commit:

```text
Git commit:
Portainer stack name:
Validation hostname:
Build/deploy: PASS/FAIL
DB initialization/grants: PASS/FAIL
WordPress fresh install: PASS/FAIL
Cloudflare route: PASS/FAIL
wpdev-doctor: PASS/FAIL
Permalinks: PASS/FAIL
Uploads: PASS/FAIL
Restart persistence: PASS/FAIL
Redeploy persistence: PASS/FAIL
DB export/import: PASS/FAIL/DEFERRED
Observed issues/fixes:
```

RC1 must not be promoted to `v0.1.0` until all required checks pass or an explicitly documented non-blocking exception is accepted.
