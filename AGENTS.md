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
- `docs/TOOLCHAIN_FRESHNESS_POLICY.md` before substantive development that depends on material tooling

Do not infer current QNAP state from historical validation files in this repository.

## 2. QNAP bootstrap gate

Before mutation-capable, capacity-sensitive or substantive development work on QNAP, record:

```text
QNAP_GOVERNANCE_READ=PASS
QNAP_CURRENT_STATE_READ=PASS
QNAP_EVIDENCE_INDEX_READ=PASS
QNAP_EXECUTION_SUBSTRATE_POLICY_READ=PASS|NOT_APPLICABLE
QNAP_TOOLCHAIN_FRESHNESS_POLICY_READ=PASS|NOT_APPLICABLE
QNAP_LIVE_SNAPSHOT_REQUIRED=YES|NO
QNAP_LIVE_SNAPSHOT_RUN_ID=<run-or-NOT_REQUIRED>
HOST_TOOL_ASSUMPTION_ALLOWED=NO
TOOLCHAIN_FRESHNESS_GATE=PASS|BLOCKED|NOT_APPLICABLE
TOOLCHAIN_UPDATE_AUTHORIZED=NO
MUTATION_AUTHORIZED=NO
```

A fresh same-window QNAP snapshot is required whenever current capacity, runtime health, Docker identity, storage, VM capability or platform mutation can affect the decision.

## 3. Execution context — never treat the QNAP as a generic developer workstation

The QNAP host is a control/orchestration/storage plane with a governed support-tool layer. The project profile/runtime owns runtime-representative application tooling, but verified host QPKG/Entware tooling may be used for suitable development/support work.

Never infer that PHP, Composer, WP-CLI, Node.js, npm/pnpm/yarn, Python packages, database clients, browsers, FFmpeg, GNU utilities or another project runtime/tool is present or absent merely from common Linux expectations or the shell `PATH`.

Before first use of an optional host tool:

1. inspect same-window `host-capabilities.tsv` and `qpkg-inventory.tsv` when available;
2. otherwise perform one bounded read-only `command -v` probe;
3. if App Center/QPKG or Entware indicates an installed package outside `PATH`, resolve the package `Install_Path`, executable path and version once;
4. use the execution context that matches what the validation must prove.

If the tool or required option is absent, do not retry variants blindly. If the capability exists neither in the verified host support layer nor in the approved project runtime, stop with:

```text
EXECUTION_CAPABILITY_MISSING
```

and propose the smallest controlled host-support or repository-owned tooling addition through the normal review/authorization path.

Examples:

- PHP/WordPress runtime acceptance belongs in the applicable PHP/WordPress container unless host PHP is explicitly part of the compatibility claim.
- A verified host Node.js package may be used for suitable lint/build/support work when its exact path/version is compatible; Node runtime acceptance belongs to the declared project runtime when that differs.
- database utilities belong in the applicable database/project container unless a verified host client is sufficient for the exact non-runtime-sensitive task.
- shell scripts intended for the NAS must use conservative POSIX/QNAP-compatible constructs and must not assume GNU-only flags or optional commands without a capability check.

Controlled Entware/QPKG support-tool installation or update is permitted only under the central governance authorization/retention/removal policy. Incidental/untracked host installation remains prohibited.

## 4. Pre-development toolchain freshness gate

Before substantive development begins, identify the material tools/runtimes used for implementation, validation, build, packaging or deployment and classify them under the central QNAP freshness policy.

Required classifications include:

```text
CURRENT_SUPPORTED
UPDATE_AVAILABLE_COMPATIBLE
PINNED_COMPATIBILITY
SECURITY_UPDATE_REQUIRED
UNSUPPORTED_OR_EOL
UNKNOWN
NOT_USED
```

Normal implementation requires:

```text
TOOLCHAIN_FRESHNESS_GATE=PASS
```

Do not blindly update to the newest version. A deliberate supported/compatible pin may PASS. `SECURITY_UPDATE_REQUIRED`, `UNSUPPORTED_OR_EOL` or `UNKNOWN` for a material tool blocks normal development until resolved or explicitly excepted.

An update recommendation does not authorize mutation. Host QPKG/Entware updates require explicit central authorization; project Dockerfile/Compose/dependency updates follow this repository's normal branch/PR/validation workflow.

## 5. Docker authority

Normal project workloads use the Container Station Docker engine:

```text
/var/run/docker.sock
```

The QNAP system Docker engine at `/var/run/system-docker.sock` is intentionally distinct. Never collapse, substitute or redirect one engine to the other.

Prefer existing project services with `docker compose exec -T ...` or a documented project-owned disposable validation service when runtime-representative execution is required. Adding/pulling a new utility image or changing Dockerfile/Compose dependencies is a project environment change, not an automatic workaround.

## 6. Evidence and mutation discipline

- PASS requires observed evidence from the correct execution context and a material-tool freshness state compatible with the claim.
- A failure caused by running a tool in the wrong context is not evidence that application code is invalid.
- Do not modify the QNAP merely to satisfy a verifier.
- Do not edit Portainer-managed stack Compose files directly.
- Keep `MUTATION_AUTHORIZED=NO` until a task-specific explicit mutation gate exists.
- Keep `TOOLCHAIN_UPDATE_AUTHORIZED=NO` until a specific host/project tooling update is reviewed.
- Use branch + PR for repository changes; do not merge without explicit user authorization.

Project-local profile documentation may be stricter than the central QNAP policy but must never weaken it.
