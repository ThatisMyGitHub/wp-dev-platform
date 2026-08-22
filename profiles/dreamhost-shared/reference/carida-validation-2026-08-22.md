# Carida / QNAP RC1 validation evidence — 2026-08-22

This file records sanitized acceptance evidence for `wp-dev-platform` `dreamhost-shared` v0.1.0-rc1 on the real Carida/QNAP host. It contains no credentials, private addresses or environment dumps.

## Runtime artifact gate — PASS

All three public GHCR RC images were pulled successfully from the QNAP Docker daemon and confirmed as `linux/amd64`:

- `ghcr.io/thatismygithub/wp-dev-platform-wordpress:0.1.0-rc1`
  - registry digest: `sha256:28714327339f7be9d4ba07271c93081b724d3a04fd6006bee748434a0522b66b`
  - local image ID: `sha256:136d89ee91be5f0e83aa1de0637ea7f7c02dac3b804a43b8f7b6023ce22c7f47`
- `ghcr.io/thatismygithub/wp-dev-platform-httpd:0.1.0-rc1`
  - original registry digest before FastCGI DNS correction: `sha256:c218ae7e785a53f161fb59c4e02cf0db53849ce0f3b0747acc6a6d621032ea99`
  - corrected RC image registry digest: `sha256:46dc8f254c952b359c775b8a026f2d3b7b137e7a6dd1aafb29ad59765c396b9c`
- `ghcr.io/thatismygithub/wp-dev-platform-mysql:0.1.0-rc1`
  - registry digest: `sha256:ef294eb37bc6932dd864bd323e037d69c3e9f8710710d7b280e9c2aea8ad4a59`
  - local image ID: `sha256:282feba2ae53ba49cd841c5da868a3ee4721e4ba6ff4d32ae33e3d8c2f5737b6`

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

Observed members of `wpdev-rc1_backend`:

- `wpdev-rc1-db-1`
- `wpdev-rc1-wordpress-1`
- `wpdev-rc1-web-1`

Observed `wpdev-rc1` member of external `carida_cloudflare`:

- `wpdev-rc1-web-1`

Therefore MySQL and WordPress/PHP remain backend-only, while Apache is the sole frontend participant on the Cloudflare network.

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

## Next acceptance gate

Complete the fresh WordPress installation through the HTTPS development hostname, then run the full `wpdev-doctor` and continue permalink/media/restart/redeploy/migration checks.
