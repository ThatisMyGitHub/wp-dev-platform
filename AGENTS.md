# AGENTS.md — wp-dev-platform assistant contract

This repository defines and validates WordPress development-platform profiles that may execute on the shared QNAP/Carida host. This file is mandatory reading for assistants and agents before repository or NAS-side work.

## 1. Project context

Before changing this repository, read the current project documents relevant to the task, including `README.md`, `PROJECT_STATUS.md`, `ROADMAP.md`, the active profile documentation and its validation procedure.

For any task that uses, deploys to, troubleshoots, sizes, or otherwise depends on Carida/QNAP, also read the canonical external platform governance repository:

```text
ThatisMyGitHub/qnap-platform-governance
```

Mandatory QNAP files:

- `AGENTS.md`
- `CURRENT_STATE.yaml`
- `docs/QNAP_PLATFORM_CANONICAL_BASELINE_v1.0.0.md`
- `docs/EVIDENCE_INDEX.md`
- `docs/EXECUTION_SUBSTRATE_POLICY.md` for NAS-side code/tool execution

Do not infer current QNAP state from historical validation files in this repository.

## 2. QNAP bootstrap gate

Before mutation-capable or capacity-sensitive QNAP work, record:

```text
QNAP_GOVERNANCE_READ=PASS
QNAP_CURRENT_STATE_READ=PASS
QNAP_EVIDENCE_INDEX_READ=PASS
QNAP_EXECUTION_SUBSTRATE_POLICY_READ=PASS|NOT_APPLICABLE
QNAP_LIVE_SNAPSHOT_REQUIRED=YES|NO
QNAP_LIVE_SNAPSHOT_RUN_ID=<run-or-NOT_REQUIRED>
HOST_TOOL_ASSUMPTION_ALLOWED=NO
MUTATION_AUTHORIZED=NO
```

A fresh same-window QNAP snapshot is required whenever current capacity, runtime health, Docker identity, storage, VM capability or platform mutation can affect the decision.

## 3. Execution context — governed host support layer

The QNAP host is primarily a control/orchestration/storage plane with a governed support-tool layer. The project profile/runtime still owns runtime-representative application validation.

Never assume that PHP, Composer, WP-CLI, Node.js, npm/pnpm/yarn, Python packages, database clients, browsers, FFmpeg, GNU utilities or another project runtime/tool exists or does not exist solely from the current shell `PATH`.

Before first use of an optional host command:

1. inspect same-window `host-capabilities.tsv` and `qpkg-inventory.tsv` when available;
2. otherwise perform one bounded `command -v` probe;
3. if App Center/QPKG or Entware indicates an installed package outside `PATH`, resolve its package-owned executable path once and record the exact path/version/provenance;
4. select host or project runtime according to what the validation must prove.

If the capability exists neither in the verified host support layer nor in the approved project runtime, stop with:

```text
EXECUTION_CAPABILITY_MISSING
```

Examples:

- PHP syntax/runtime acceptance belongs in the applicable PHP/WordPress container unless host PHP is explicitly part of the compatibility claim.
- Verified host Node.js may be used for suitable development support such as syntax/lint/build steps when its exact path/version is compatible; project runtime acceptance still belongs in the project's declared Node/tooling runtime when that distinction matters.
- database utilities belong in the applicable database/project container for DB-runtime acceptance, unless an exact verified host support tool is sufficient for a non-runtime-sensitive operation.
- shell scripts intended for the NAS must use conservative POSIX/QNAP-compatible constructs and must not assume GNU-only flags or optional commands without a capability check.

Do not repeatedly try aliases, package-manager variants or guessed executable paths.

A bounded host support utility may be installed through Entware/QPKG only under the central QNAP controlled-tooling policy with explicit authorization and a recorded package, purpose, version, install location, executable paths, owner scope, retention and removal plan. Incidental/untracked host installation remains prohibited.

## 4. Docker authority

Normal project workloads use the Container Station Docker engine:

```text
/var/run/docker.sock
```

The QNAP system Docker engine at `/var/run/system-docker.sock` is intentionally distinct. Never collapse, substitute or redirect one engine to the other.

Prefer existing project services with `docker compose exec -T ...` or a documented project-owned disposable validation service when runtime-representative validation is required. Adding/pulling a new utility image or changing Dockerfile/Compose dependencies is a project environment change, not an automatic workaround.

## 5. Evidence and mutation discipline

- PASS requires observed evidence from the execution context appropriate to the claim.
- A failure caused by running a tool in the wrong context is not evidence that application code is invalid.
- Failure of `command -v` alone is not proof that an App Center/QPKG package is absent.
- Do not modify the QNAP merely to satisfy a verifier.
- Controlled host-support-tool installation is allowed only under the central authorization/retention contract.
- Do not edit Portainer-managed stack Compose files directly.
- Keep `MUTATION_AUTHORIZED=NO` until a task-specific explicit mutation gate exists.
- Use branch + PR for repository changes; do not merge without explicit user authorization.

Project-local profile documentation may be stricter than the central QNAP policy but must never weaken it.
