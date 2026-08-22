# Contributing

## Branch model

- `main`: accepted, validated baseline.
- `dev`: integration branch.
- Short-lived branches: `feature/*`, `fix/*`, `docs/*`, `chore/*`.
- Meaningful changes are merged through pull requests.

## Versioning

The platform follows Semantic Versioning.

- Development snapshots: `0.x.y-dev.N`
- Release candidates: `v0.x.y-rcN`
- Accepted releases: `v0.x.y`

Hosting profiles are versioned with the platform and must document compatibility-impacting changes.

## Required updates

When a change affects runtime behavior or deployment:

1. update `PROJECT_STATUS.md`;
2. update `CHANGELOG.md`;
3. update provider compatibility documentation if relevant;
4. run the applicable validation/dry-run procedure before merging to `main`.

## Security

Never commit credentials, raw hosting fingerprints, customer backups, database dumps, private hostnames/usernames, SSH keys, API tokens, or production `.env` files.

## Platform/consumer boundary

Generic infrastructure and provider behavior belong in `wp-dev-platform`.

Customer/project-specific themes, plugins, branding, content, and configuration overlays belong in the consumer repository such as `datainspire-web`.
