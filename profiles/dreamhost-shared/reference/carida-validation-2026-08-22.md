# Carida / QNAP RC1 validation evidence — 2026-08-22

This file records sanitized acceptance evidence for `wp-dev-platform` `dreamhost-shared` v0.1.0-rc1 on the real Carida/QNAP host. It contains no credentials, private addresses or environment dumps.

## Runtime artifact gate — PASS

All three public GHCR RC images were pulled successfully from the QNAP Docker daemon and confirmed as `linux/amd64`:

- `ghcr.io/thatismygithub/wp-dev-platform-wordpress:0.1.0-rc1`
  - registry digest: `sha256:28714327339f7be9d4ba07271c93081b724d3a04fd6006bee748434a0522b66b`
  - local image ID: `sha256:136d89ee91be5f0e83aa1de0637ea7f7c02dac3b804a43b8f7b6023ce22c7f47`
- `ghcr.io/thatismygithub/wp-dev-platform-httpd:0.1.0-rc1`
  - registry digest: `sha256:c218ae7e785a53f161fb59c4e02cf0db53849ce0f3b0747acc6a6d621032ea99`
  - local image ID: `sha256:1a94b1d111f4e933586512868744903af9c718f5d251de7fb5b0f272abc1bc51`
- `ghcr.io/thatismygithub/wp-dev-platform-mysql:0.1.0-rc1`
  - registry digest: `sha256:ef294eb37bc6932dd864bd323e037d69c3e9f8710710d7b280e9c2aea8ad4a59`
  - local image ID: `sha256:282feba2ae53ba49cd841c5da868a3ee4721e4ba6ff4d32ae33e3d8c2f5737b6`

## Portainer deployment/startup gate — PASS

Validated runtime commit: `2151428798b470fe0c79d29a72a283f383ea96e6`.

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

## Next acceptance gate

Inspect sanitized startup logs for MySQL initialization/restricted grants, WordPress volume initialization, PHP-FPM startup and Apache startup. If clean, create the temporary Cloudflare route, complete a fresh WordPress installation, then run the full `wpdev-doctor` and continue permalink/media/restart/redeploy/migration checks.
