# Carida / QNAP RC1 validation evidence — 2026-08-22

This file records sanitized acceptance evidence for `wp-dev-platform` `dreamhost-shared` v0.1.0-rc1 on the real Carida/QNAP host. It contains no credentials, private addresses or environment dumps.

## Runtime artifact gate — PASS

All three public GHCR RC images were pulled successfully from the QNAP Docker daemon and confirmed as `linux/amd64`:

- `ghcr.io/thatismygithub/wp-dev-platform-wordpress:0.1.0-rc1`
  - original registry digest before outbound-network correction: `sha256:28714327339f7be9d4ba07271c93081b724d3a04fd6006bee748434a0522b66b`
  - corrected RC image registry digest: `sha256:ea1ccac9d895ab7e323ff04476114556a1604a3c4b05798daee8aabd387347ba`
- `ghcr.io/thatismygithub/wp-dev-platform-httpd:0.1.0-rc1`
  - original registry digest before FastCGI DNS correction: `sha256:c218ae7e785a53f161fb59c4e02cf0db53849ce0f3b0747acc6a6d621032ea99`
  - corrected RC image registry digest: `sha256:46dc8f254c952b359c775b8a026f2d3b7b137e7a6dd1aafb29ad59765c396b9c`
- `ghcr.io/thatismygithub/wp-dev-platform-mysql:0.1.0-rc1`
  - registry digest: `sha256:ef294eb37bc6932dd864bd323e037d69c3e9f8710710d7b280e9c2aea8ad4a59`
  - observed local image ID during initial artifact validation: `sha256:282feba2ae53ba49cd841c5da868a3ee4721e4ba6ff4d32ae33e3d8c2f5737b6`

## Portainer deployment/startup gate — PASS

Initial validated runtime commit: `2151428798b470fe0c79d29a72a283f383ea96e6`.

Observed service state:

- `wpdev-rc1-db-1` — running / healthy;
- `wpdev-rc1-wordpress-1` — running / healthy;
- `wpdev-rc1-web-1` — running / healthy;
- `wpdev-rc1-wordpress-init-1` — exited successfully with code 0.

The web container reports internal `80/tcp` exposure only; no host port mapping is present.

## Persistence resources — PASS

Observed named volumes:

- `wpdev-rc1_mysql_data`
- `wpdev-rc1_wordpress_data`

## Network isolation/topology — PASS

Initial topology validation confirmed:

- MySQL, WordPress/PHP and Apache share the project-scoped internal `wpdev-rc1_backend` network;
- only Apache joins the external `carida_cloudflare` network;
- no application service publishes host ports.

During browser acceptance, WordPress update checks revealed that a service attached only to an `internal: true` backend cannot perform normal Internet egress. RC1 was therefore refined with a separate project-scoped egress bridge for WordPress/PHP (and the optional WP-CLI administrative path), while MySQL remains backend-only and Apache remains backend + Cloudflare only.

This preserves inbound isolation while allowing normal WordPress core/plugin/theme HTTPS traffic.

## Startup-log gate — PASS

Sanitized startup logs confirm:

- MySQL 8.0.41 initialized the data directory, created the RC database/application user, executed `/docker-entrypoint-initdb.d/10-restrict-app-user.sh`, completed the temporary initialization server cycle and restarted ready for connections on port 3306;
- InnoDB initialized successfully;
- WordPress volume initialization completed and the existing `.htaccess` was preserved;
- the WordPress/PHP container generated `wp-config.php` from the supplied `WORDPRESS_*` environment contract;
- PHP-FPM started and reported `ready to handle connections`;
- Apache 2.4.68 reported `configured -- resuming normal operations`.

Observed MySQL warnings are non-blocking official-image/runtime warnings rather than initialization failures: deprecated `--skip-host-cache` syntax, the temporary `--initialize-insecure` bootstrap warning, self-signed internal CA, pid-file directory warning and the CLI password warning from the initialization helper. None prevented the final server from reaching its healthy/running state.

The CLI-password warning should be considered a security-hygiene improvement opportunity for the initialization helper before or after final release, but it is not an RC1 functional blocker and no password value is emitted in the logs.

## Shared-network FastCGI DNS collision — FOUND AND FIXED

The first public HTTPS request reached Apache but returned HTTP 503. Diagnostics proved:

- Cloudflare Tunnel -> Apache was working;
- PHP-FPM was listening successfully on port 9000;
- Apache resolved the generic hostname `wordpress` to an unrelated container address on the shared `carida_cloudflare` network instead of the RC WordPress/PHP container on `wpdev-rc1_backend`;
- Apache therefore attempted FastCGI against the wrong IP and logged `AH00957` / `AH01079` connection-refused errors.

RC1 was corrected so the WordPress/PHP service receives a backend-only alias `wpdev-php-backend`, and Apache now targets `proxy:fcgi://wpdev-php-backend:9000` instead of the ambiguous generic `wordpress:9000` name.

The CI gate was strengthened by deliberately creating a decoy `wordpress` alias on the shared external network. The new `Verify private FastCGI DNS isolation` check passes, and the full RC validation suite continues to pass afterward.

## Cloudflare public application route — PASS

A temporary published application route was created for the RC hostname and pointed to the Apache service on the shared Cloudflare Docker network.

After redeployment with the corrected backend alias/runtime, the public HTTPS hostname successfully returned the normal fresh WordPress installation screen. This proves the complete path:

`Cloudflare HTTPS -> Tunnel -> Apache -> FastCGI -> WordPress/PHP-FPM -> MySQL`

The previous Apache-generated 503 is resolved.

## Fresh WordPress installation — PASS

WordPress 7.0.4 was installed successfully through the published HTTPS development hostname and the administrative dashboard became available.

The first dashboard load exposed missing outbound Internet access from WordPress/PHP. RC1 was corrected by adding a separate egress network while retaining the private internal application backend.

## WordPress outbound HTTPS — PASS

After the egress-network correction and redeployment, the live Carida WordPress/PHP container successfully reached:

`https://api.wordpress.org/core/version-check/1.7/`

using HTTPS. The check was repeated successfully.

The CI gate was also strengthened with `Verify WordPress outbound HTTPS`, which validates both a raw HTTPS request and WordPress's own HTTP API path.

## Full in-container compatibility doctor — PASS

The live Carida `wpdev-doctor` completed successfully after WordPress installation and the outbound-network correction.

Observed PASS checks:

- PHP runtime family `8.3.x` (Carida RC observed `8.3.33`);
- RC1 CLI PHP settings;
- DreamHost-compatible PHP extension baseline;
- MySQL `8.0.41`;
- intended SQL settings and reusable schema defaults;
- measured DreamHost-compatible application grant envelope;
- WordPress installed state;
- WordPress DB connection `utf8mb4` / `utf8mb4_unicode_520_ci`;
- WordPress outbound HTTPS to `api.wordpress.org`;
- Apache -> FastCGI -> PHP web runtime, with observed FPM runtime `8.3.33|fpm-fcgi|128M|120|-1|3000|512M|512M|20|60|1`.

Result: `wp-dev-platform DreamHost Shared compatibility doctor passed.`

## Generic CI status after outbound-network correction — PASS

The RC workflow for commit `18314b16f7b2532df7198be05b8c0f7e0d280469` completed successfully, including:

- source image build;
- runtime startup;
- private FastCGI DNS isolation;
- WordPress outbound HTTPS;
- WordPress installation;
- compatibility doctor;
- real permalink and media delivery;
- restart persistence;
- database export/import round trip;
- final doctor.

## Next acceptance gate

Validate real friendly permalinks and media upload through the published Carida hostname, then verify restart persistence, Portainer redeploy persistence and the Carida-side guarded database export/import dry run.
