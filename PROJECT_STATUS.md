# Project Status

## Current phase

**Phase 2 complete — `wp-dev-platform v0.1.0-rc1` accepted on Carida/QNAP**

**Next phase — promote the accepted platform to `v0.1.0`, then pin `datainspire-web` to that released version.**

## DreamHost compatibility baseline

DreamHost discovery is complete. The normalized production reference confirms:

- Ubuntu 24.04.4 LTS host family;
- Apache 2.4.58 on DreamHost;
- production website PHP 8.3.30 via `cgi-fcgi`;
- default DreamHost SSH/CLI PHP 8.2.30;
- WordPress 7.0.4;
- WP-CLI 2.12.0;
- MySQL 8.0.41;
- SQL mode `NO_ENGINE_SUBSTITUTION`;
- 32 MiB `max_allowed_packet`;
- effective WordPress DB connection `utf8mb4` / `utf8mb4_unicode_520_ci`;
- measured database-scoped application grants;
- 47 production tables, with the legacy `utf8mb3` / MyISAM exceptions treated as Data Inspire migration concerns rather than reusable platform requirements.

Raw fingerprints, credentials and account-specific identifiers remain outside the public repository.

## Accepted RC1 architecture

The `dreamhost-shared` profile now provides:

- build-free Portainer/QNAP deployment from validated GHCR images;
- split Apache -> FastCGI -> WordPress/PHP 8.3 runtime;
- MySQL 8.0.41 compatibility runtime;
- clean InnoDB + `utf8mb4` + `utf8mb4_unicode_520_ci` reusable DB policy;
- measured DreamHost-compatible application grants;
- private project backend network;
- separate WordPress egress network for normal core/plugin/theme HTTPS traffic;
- external `carida_cloudflare` integration only on the Apache frontend;
- no host-published application or database ports;
- persistent project-scoped WordPress and MySQL volumes;
- QNAP-safe WordPress volume initialization;
- safe repair of an incomplete standard WordPress `.htaccess` marker block while preserving unrelated directives;
- bundled WP-CLI 2.12.0 and compatibility doctor;
- guarded, shared-host-safe DB export/import helpers;
- optional project PHP override layer and Adminer tools profile;
- source-build overlay retained for CI/developer validation only.

## Intentional compatibility approximations

- DreamHost reports `cgi-fcgi`; RC1 uses PHP-FPM FastCGI (`fpm-fcgi`) behind Apache while preserving the Apache -> FastCGI -> PHP execution boundary.
- DreamHost Apache is 2.4.58; RC1 uses a current Apache 2.4 patch rather than deliberately pinning an older patch release.
- DreamHost server defaults are historically `utf8mb3`; clean RC databases use `utf8mb4` because the measured WordPress application connection is already `utf8mb4`.
- DreamHost SSH defaults to PHP 8.2.30; RC tooling deliberately runs WP-CLI under the PHP 8.3 application runtime for deterministic project behavior.

## Automated RC validation — GREEN

The strengthened CI gate validates:

1. Compose deployment and source-build models.
2. Fresh source builds from pinned runtime bases.
3. Runtime startup and health checks.
4. A deliberately malformed WordPress `.htaccess` fixture and safe self-healing.
5. Private FastCGI DNS isolation even with a decoy generic `wordpress` alias on the shared external network.
6. WordPress outbound HTTPS.
7. WordPress installation.
8. Full PHP/extensions/MySQL/grants/DB-connection/Apache->FastCGI compatibility doctor.
9. Real friendly permalink and uploaded-media delivery.
10. Restart persistence.
11. Guarded database export/import round trip.
12. Final compatibility doctor.
13. Clean disposable-environment teardown.

The final self-healing regression run for RC head `886e2bb658f904d63e20585a81fa76c2234ceb14` passed all of these gates.

## Carida/QNAP acceptance — PASS

The RC has now passed the real Carida/QNAP/Portainer acceptance suite.

Validated evidence includes:

- public GHCR images pull successfully as `linux/amd64`;
- final self-healing WordPress RC registry digest observed on Carida: `sha256:1305bd62932f30b96bbb3ca216c397ba18a3317ae4fda5d444e68f3f789565c0`;
- Portainer deployment with persistent named WordPress/MySQL volumes;
- MySQL, WordPress/PHP and Apache healthy on the real QNAP host;
- Cloudflare HTTPS -> Tunnel -> Apache -> FastCGI -> WordPress/PHP-FPM -> MySQL path verified;
- shared-network FastCGI DNS collision discovered on Carida and fixed with the private `wpdev-php-backend` alias;
- WordPress outbound HTTPS discovered as missing on the first live deployment and fixed with a separate egress bridge;
- fresh WordPress installation and dashboard access through the published HTTPS development hostname;
- full live `wpdev-doctor` pass;
- friendly permalink and uploaded media through the public Cloudflare hostname;
- empty persisted WordPress rewrite block discovered live, repaired, and encoded as safe self-healing behavior;
- ordinary container restart persistence for DB, WordPress, post, media, permalink and full doctor;
- Portainer Pull/redeploy persistence with the newest runtime image;
- deliberately restored malformed `.htaccess` automatically repaired by `wordpress-init` on the real QNAP host;
- post-redeploy post/media persistence, public permalink/media delivery and full doctor pass;
- portable DB export produced successfully with no `GTID_PURGED` and no `CREATE DATABASE` statement;
- export size observed as 117 KiB with SHA-256 `33f149080c408058e15b67eb7591b06a6e83cceee3684b323bfbeb794cd783e7`;
- application tier stopped while MySQL remained healthy for the controlled round-trip;
- after the guarded round-trip sequence, WordPress returned healthy, the test post and media metadata persisted, the public permalink/media checks passed, and the final `wpdev-doctor` passed every compatibility check.

Transcript note: the user-provided final excerpt begins after the direct MySQL import command, so its literal `Database import: PASS` line is not present in the captured excerpt. No import error was reported, and the complete post-import application/compatibility verification is green. This nuance is retained in the record rather than fabricating a missing output line.

## RC1 acceptance decision

**Accepted.** No unresolved architecture-changing blocker remains for `wp-dev-platform v0.1.0-rc1`.

Non-blocking follow-ups remain:

- improve the MySQL initialization helper to avoid the CLI password warning where practical;
- strengthen the Apache container health check beyond process-only status;
- relax the generic doctor from requiring routine/trigger privileges if the reusable platform contract is later narrowed beyond the measured DreamHost envelope;
- investigate the provenance/dependency status of the legacy Data Inspire `feeds` table;
- inventory current Data Inspire plugins/themes before importing production content.

## Next release target

Promote the accepted RC to **`v0.1.0`**, merge the release candidate into `main`, publish immutable release artifacts/tags, and then update `datainspire-web` to consume the released platform version rather than the mutable RC tag.
