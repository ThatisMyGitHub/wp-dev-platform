# Project Status

## Current phase

**Phase 3 — `wp-dev-platform v0.1.0` promoted to `main` after accepted Carida/QNAP validation.**

PR #1 was merged into `main` on 2026-08-22. The repository `VERSION` is `0.1.0`, runtime defaults reference the `0.1.0` GHCR image tags, and OCI image labels identify version `0.1.0`.

The connected GitHub integration used for this session does not expose Git tag or GitHub Release creation. Therefore the immutable repository tag/release object `v0.1.0` must still be created through GitHub UI/CLI before downstream consumers treat the release as fully immutable.

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
- legacy Data Inspire `utf8mb3` / MyISAM exceptions treated as migration concerns rather than reusable platform requirements.

Raw fingerprints, credentials and account-specific identifiers remain outside the public repository.

## Released platform architecture

The `dreamhost-shared` profile provides:

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

- DreamHost reports `cgi-fcgi`; the platform uses PHP-FPM FastCGI (`fpm-fcgi`) behind Apache while preserving the Apache -> FastCGI -> PHP execution boundary.
- DreamHost Apache is 2.4.58; the platform uses a current Apache 2.4 patch rather than deliberately pinning an older patch release.
- DreamHost server defaults are historically `utf8mb3`; clean platform databases use `utf8mb4` because the measured WordPress application connection is already `utf8mb4`.
- DreamHost SSH defaults to PHP 8.2.30; platform tooling deliberately runs WP-CLI under the PHP 8.3 application runtime for deterministic project behavior.

## Automated validation — GREEN

The strengthened validation gate covers:

1. Compose deployment and source-build models.
2. Fresh builds from pinned runtime bases.
3. Runtime startup and health checks.
4. Malformed WordPress `.htaccess` self-healing while preserving custom directives.
5. Private FastCGI DNS isolation with a decoy generic `wordpress` alias on the shared external network.
6. WordPress outbound HTTPS.
7. WordPress installation.
8. Full PHP/extensions/MySQL/grants/DB-connection/Apache->FastCGI compatibility doctor.
9. Real friendly permalink and uploaded-media delivery.
10. Restart persistence.
11. Guarded database export/import round trip.
12. Final compatibility doctor.
13. Clean disposable-environment teardown.

The final `0.1.0` PR-triggered validation for release head `2addacf0aafeaf42cf11b7a85873094bb4945f49` passed all functional gates. Its GHCR publish step is intentionally skipped for pull-request events; publication is performed only by the corresponding push-to-`dev` workflow. The connector cannot enumerate that push-only run, so publish completion should be independently verified by pulling the `0.1.0` tags before downstream pinning.

## Carida/QNAP acceptance — PASS

The release candidate passed the real Carida/QNAP/Portainer acceptance suite before promotion.

Validated evidence includes:

- public GHCR RC images pulled successfully as `linux/amd64`;
- final self-healing WordPress RC digest observed on Carida: `sha256:1305bd62932f30b96bbb3ca216c397ba18a3317ae4fda5d444e68f3f789565c0`;
- Portainer deployment with persistent named WordPress/MySQL volumes;
- Cloudflare HTTPS -> Tunnel -> Apache -> FastCGI -> WordPress/PHP-FPM -> MySQL path verified;
- shared-network FastCGI DNS collision discovered and fixed with `wpdev-php-backend`;
- WordPress outbound HTTPS fixed with the separate egress bridge;
- fresh WordPress installation and dashboard access through HTTPS;
- full live `wpdev-doctor` pass;
- friendly permalink and uploaded media through Cloudflare;
- malformed persisted WordPress rewrite block discovered, repaired and encoded as safe self-healing behavior;
- ordinary container restart persistence;
- Portainer pull/redeploy persistence;
- deliberately restored malformed `.htaccess` repaired automatically by `wordpress-init` on QNAP;
- portable DB export with no `GTID_PURGED` and no `CREATE DATABASE` statement;
- post round-trip WordPress state, public permalink/media and final doctor all green.

Transcript note: the final user-provided excerpt begins after the direct MySQL import command, so the literal `Database import: PASS` line is not present in the captured excerpt. No import error was reported, and the complete post-import application/compatibility verification is green.

## Release decision

**Accepted and merged.** No unresolved architecture-changing blocker remains for `wp-dev-platform v0.1.0`.

Non-blocking follow-ups remain:

- improve the MySQL initialization helper to avoid the CLI password warning where practical;
- strengthen the Apache container health check beyond process-only status;
- relax the generic doctor from requiring routine/trigger privileges if the reusable platform contract is later narrowed beyond the measured DreamHost envelope;
- investigate the provenance/dependency status of the legacy Data Inspire `feeds` table;
- inventory current Data Inspire plugins/themes before importing production content.

## Next action

1. Verify all three public GHCR `0.1.0` tags can be pulled and record their immutable digests.
2. Create Git tag/release `v0.1.0` at the final `main` release commit.
3. Pin `datainspire-web` to the immutable `v0.1.0` platform release and begin the Data Inspire migration/integration phase.
