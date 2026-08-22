# DreamHost Shared profile

**Status:** discovery / fingerprint pending

This profile adapts `wp-dev-platform` to DreamHost Shared Hosting behavior while preserving the common HCF-derived development, validation, deployment, and migration pattern.

## Current documented baseline

Until the Data Inspire fingerprint is reviewed, the profile assumes only provider-documented behavior:

- Apache-hosted PHP using FastCGI.
- Multiple selectable PHP versions.
- Shared MySQL version 8 on a separate database server.
- `localhost` must not be assumed for database access.
- Shared MySQL restrictions apply, including unavailable routines, triggers and events and restricted administrative operations.
- Persistent background processes must not be required by the production application.
- Docker is development infrastructure only and is not a production dependency.

## Authoritative Data Inspire profile

The measured Data Inspire environment will refine this baseline. Raw captures remain outside Git; only sanitized compatibility data belongs under `reference/`.

See:

- `../../docs/DREAMHOST-FINGERPRINT.md`
- `../../ROADMAP.md`

## Pending structure

After fingerprint review this directory is expected to contain:

```text
profiles/dreamhost-shared/
├── README.md
├── compatibility.md
├── compose.override.yaml
├── php/
├── mysql/
└── reference/
    └── sanitized-profile.json
```

Do not add production credentials or raw fingerprint files here.
