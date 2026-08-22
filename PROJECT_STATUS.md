# Project Status

## Current phase

**Phase 0 — Repository and governance baseline**

## Status summary

- Repository baseline created on `main`.
- `dev` integration branch created.
- Project roadmap documented.
- DreamHost environment fingerprint procedure documented.
- Secret-safe repository rules being established.
- No production runtime has been committed yet.

## Blocking input

The first runnable DreamHost profile should not be finalized until the Data Inspire DreamHost environment fingerprint has been collected and reviewed.

Required input:

1. Shell/runtime fingerprint.
2. Database fingerprint.
3. PHP version assigned to the Data Inspire website in the DreamHost panel.
4. Optional WordPress/plugin/theme inventory.

## Next implementation target

`wp-dev-platform v0.1.0-rc1`

Planned after fingerprint review:

- provider profile `dreamhost-shared`;
- Docker Compose baseline;
- WordPress/PHP runtime;
- MySQL 8 runtime and restricted application user;
- QNAP/Portainer-safe initialization;
- Cloudflare network integration;
- health checks and environment doctor;
- migration helpers and compatibility validation.
