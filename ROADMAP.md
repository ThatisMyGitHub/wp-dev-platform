# wp-dev-platform — Project Roadmap

**Status:** Initialisation  
**Target first release:** `v0.1.0`  
**Primary first consumer:** Data Inspire (`datainspire-web`)  
**First hosting profile:** DreamHost Shared Unlimited / Shared MySQL  
**Development host:** Carida / Portainer / Cloudflare Tunnel

## 1. Project objective

Create and maintain a reusable WordPress development platform that follows the same configuration, deployment, validation, and migration strategy proven in the HCF project while adapting each hosting profile to the actual production provider.

The platform is **not intended to reproduce every hosting provider bit-for-bit**. It is intended to reproduce the production-relevant behavior, constraints, versions, and deployment assumptions closely enough that local development and validation provide a reliable migration path.

The first implementation will support the existing Data Inspire website hosted on DreamHost Shared Unlimited and will become the reference template for future customer projects.

## 2. Repository model

### `wp-dev-platform`
Canonical reusable platform. Owns:

- Docker/Compose development runtime.
- WordPress bootstrap and runtime conventions.
- Hosting-provider profiles.
- Environment validation and health checks.
- Hosting fingerprint tooling.
- Import/export and migration helpers.
- CI compatibility tests.
- Development and deployment documentation.
- Platform versioning.

It must not contain customer branding, customer content, production credentials, raw backups, or unredacted customer/server fingerprints.

### `datainspire-web`
First consumer and reference implementation. Owns:

- Data Inspire-specific WordPress theme/customisation.
- Data Inspire plugins and MU-plugins.
- Project configuration overlays.
- Project content/configuration artifacts that are appropriate for source control.
- Data Inspire release history and project status.
- A lock/reference to the platform version and hosting profile it has been validated against.

## 3. Core principles

1. **Provider-adapted, pattern-consistent.** Reuse the HCF workflow and deployment/migration pattern, but adapt the runtime to DreamHost rather than copying the Infomaniak/MariaDB stack.
2. **Production constraints are development constraints.** Features that cannot run on DreamHost Shared must not silently appear to work in the development platform.
3. **Template and consumer are separate products.** Data Inspire consumes the platform; it does not become the template.
4. **No secrets in Git.** Repositories may be public. Credentials, raw fingerprints, backups, `.env` files, private hostnames, database usernames, and server-specific private data stay outside Git.
5. **Reproducible environments.** Runtime images and compatibility assumptions are versioned and documented.
6. **Migration is a tested workflow.** Export/import, URL transformation, database compatibility, permissions, and rollback are tested before production deployment.
7. **Small, reviewable changes.** `main` is the accepted baseline; active work occurs on `dev` and short-lived branches with pull requests for meaningful changes.

## 4. Compatibility model

### Level 1 — DreamHost specification profile

Built from current DreamHost documentation and designed to reproduce documented Shared Hosting behavior. Initial known constraints include:

- Apache-hosted PHP running through FastCGI.
- Supported PHP versions selected per hosted site.
- MySQL 8 on a separate shared database server.
- No assumption that the database is reachable through `localhost`.
- Shared MySQL restrictions, including unsupported routines/triggers/events and restricted administrative privileges.
- No dependency on Docker in production.
- No dependency on persistent application workers/processes on Shared Hosting.
- SSH, Git, WP-CLI, cron, SFTP and standard WordPress deployment mechanisms may be used where supported.

This profile is sufficient to begin platform construction but is not the final authority for Data Inspire.

### Level 2 — Data Inspire DreamHost fingerprint

A sanitized fingerprint of the actual Data Inspire DreamHost environment becomes the authoritative compatibility reference for the first platform release.

The fingerprint process records, where available:

- OS/kernel information visible to the shell user.
- CLI PHP version, binary, modules and configuration paths.
- Website PHP version and selected relevant runtime settings.
- WP-CLI version/environment.
- Git client version.
- MySQL client version.
- MySQL server version.
- Database character set and collation.
- SQL mode.
- selected safe server variables relevant to WordPress/migrations.
- effective database grants, after redaction if necessary.

Raw fingerprint output is treated as private operational data. Only a sanitized compatibility profile is committed.

## 5. Roadmap

### Phase 0 — Repository and governance baseline

**Goal:** establish safe repositories and a common workflow.

Deliverables:

- [x] Create `wp-dev-platform` repository.
- [x] Create `datainspire-web` repository.
- [x] Establish `main` baseline.
- [x] Establish `dev` branch.
- [ ] Add contribution/versioning conventions.
- [ ] Add changelog and project-status documents.
- [ ] Add secret-safe `.gitignore` rules.
- [ ] Add platform/project version markers.
- [ ] Open initialisation PRs for review.

Exit criterion: both repositories have a documented workflow and contain no secrets.

### Phase 1 — DreamHost discovery and fingerprint

**Goal:** replace assumptions with measured Data Inspire production facts.

Deliverables:

- [ ] Execute the shell/runtime fingerprint on the DreamHost account.
- [ ] Confirm the PHP version assigned to the Data Inspire website, not only the CLI version.
- [ ] Execute the database fingerprint against the Data Inspire MySQL host.
- [ ] Record relevant PHP limits/settings.
- [ ] Identify the current WordPress version and important plugins/themes.
- [ ] Sanitize the collected data.
- [ ] Create the normalized `dreamhost-shared` compatibility profile.
- [ ] Record any differences between DreamHost documentation and the measured environment.

Exit criterion: we can state the concrete production-relevant runtime that the development platform must emulate.

### Phase 2 — `wp-dev-platform v0.1.0-rc1`

**Goal:** create the first runnable DreamHost-adapted development runtime.

Planned components:

- [ ] Docker Compose runtime.
- [ ] Apache/PHP WordPress service aligned with the measured PHP runtime.
- [ ] MySQL 8 service aligned with the measured server behavior as closely as practical.
- [ ] Separate internal database network.
- [ ] `carida_cloudflare` external network integration.
- [ ] No host-published application/database ports by default.
- [ ] Persistent WordPress and database volumes.
- [ ] QNAP/Portainer-safe WordPress initialization pattern based on HCF experience.
- [ ] Restricted application database user.
- [ ] Health checks.
- [ ] `.env.example` without secrets.
- [ ] WP-CLI administrative path.
- [ ] Optional development-only database administration profile.
- [ ] Runtime `doctor` command.
- [ ] DreamHost SQL compatibility checks.
- [ ] Import/export helpers.

Exit criterion: a clean Carida deployment can install and operate WordPress using the DreamHost profile without relying on unsupported production features.

### Phase 3 — Platform validation

**Goal:** prove that the generic platform works before Data Inspire customisation is layered on top.

Validation includes:

- [ ] Fresh installation test.
- [ ] Container restart/redeploy persistence test.
- [ ] WordPress admin/login test.
- [ ] permalink/`.htaccess` behavior test.
- [ ] upload/media test.
- [ ] plugin installation/update policy test.
- [ ] scheduled-task/cron strategy test.
- [ ] database privilege compatibility test.
- [ ] Cloudflare Tunnel/publication test.
- [ ] backup/export/restore dry run.

Exit criterion: tag `wp-dev-platform v0.1.0`.

### Phase 4 — Data Inspire instantiation

**Goal:** make Data Inspire the first real consumer of the released platform.

Deliverables:

- [ ] Pin Data Inspire to `wp-dev-platform v0.1.0` and profile `dreamhost-shared`.
- [ ] Establish Data Inspire project overlay/customisation structure.
- [ ] Import a sanitized or controlled copy of the current site as appropriate.
- [ ] Inventory existing theme/plugins/configuration.
- [ ] Separate legacy assets from the new portal implementation.
- [ ] Establish Data Inspire development URL through Cloudflare.
- [ ] Validate functional parity required for migration.

Exit criterion: Data Inspire development is running on Carida using the reusable platform rather than a project-specific ad-hoc stack.

### Phase 5 — New Data Inspire portal development

**Goal:** build the new portal while keeping migration compatibility continuously testable.

Activities:

- [ ] information architecture and UX implementation.
- [ ] theme/component development.
- [ ] plugin/MU-plugin development where justified.
- [ ] content migration strategy.
- [ ] performance/security checks.
- [ ] compatibility checks on every release candidate.
- [ ] maintain project changelog and platform lock.

Exit criterion: release candidate accepted for DreamHost migration.

### Phase 6 — DreamHost migration rehearsal and production deployment

**Goal:** make the production migration repeatable and reversible.

Deliverables:

- [ ] pre-migration backup procedure.
- [ ] file transfer/deployment procedure.
- [ ] database export/import procedure.
- [ ] URL/domain transformation procedure.
- [ ] permissions/configuration validation.
- [ ] post-deploy smoke tests.
- [ ] rollback procedure.
- [ ] full dry run before the production cutover.
- [ ] production migration record.

Exit criterion: Data Inspire production runs the accepted release and the migration procedure is documented as a reusable pattern.

### Phase 7 — Template hardening for future customers

**Goal:** turn the successful Data Inspire implementation into a repeatable customer bootstrap process without making Data Inspire the template.

Deliverables:

- [ ] extract generic improvements back into `wp-dev-platform`.
- [ ] project bootstrap command/script.
- [ ] project naming/volume/network conventions.
- [ ] provider-profile selection mechanism.
- [ ] downstream platform update procedure.
- [ ] automated platform compatibility tests.
- [ ] customer onboarding checklist.
- [ ] disaster-recovery/migration checklist.

Exit criterion: a new customer development project can be created from the platform without copying Data Inspire-specific code.

### Phase 8 — Additional hosting profiles

Potential next profile:

- [ ] `infomaniak` profile, consolidating the operational lessons already learned from HCF.

The provider profile changes production emulation; the platform workflow remains common.

## 6. Versioning strategy

Platform uses Semantic Versioning.

- `0.x.y`: pre-stable platform evolution.
- `v0.1.0-rcN`: release candidates.
- `v0.1.0`: first validated DreamHost profile/platform baseline.
- Breaking platform/profile contract changes increment the appropriate SemVer component.

Consumer projects record at minimum:

```text
PLATFORM=wp-dev-platform
PLATFORM_VERSION=<validated release>
HOSTING_PROFILE=dreamhost-shared
```

A project upgrade to a new platform version is performed as an explicit, reviewable change.

## 7. Branching and release flow

```text
feature/* or fix/* or docs/*
             ↓
            dev
             ↓
      release candidate
             ↓
      validation / dry run
             ↓
             PR
             ↓
            main
             ↓
        version tag
```

`main` must remain deployable/accepted. `dev` is the integration branch.

## 8. Security and repository visibility

At initialisation time both `wp-dev-platform` and `datainspire-web` are public repositories. Therefore:

Never commit:

- production `.env` files;
- DreamHost passwords or SSH keys;
- `wp-config.php` containing credentials;
- raw database dumps;
- raw hosting fingerprints containing private hostnames/usernames;
- customer backups or uploaded content containing personal/private data;
- Cloudflare credentials/tokens;
- SMTP credentials.

Raw operational captures should be stored outside the repository and supplied for analysis through a private channel. The repository receives only sanitized derived configuration.

## 9. Immediate next actions

1. Complete repository scaffolding.
2. Execute the DreamHost fingerprint procedure in `docs/DREAMHOST-FINGERPRINT.md`.
3. Review and sanitize the output.
4. Convert the measured values into the first `profiles/dreamhost-shared` specification.
5. Build `v0.1.0-rc1` only after the fingerprint is understood.
