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

## 3. Execution context — never treat the QNAP as a developer workstation

The QNAP host is a control/orchestration/storage plane. The project profile/runtime owns application tooling.

Never assume that PHP, Composer, WP-CLI, Node.js, npm/pnpm/yarn, Python packages, database clients, browsers, FFmpeg, GNU utilities or another project runtime/tool exists on the host.

Before first use of an optional host command, perform one bounded read-only capability probe, normally:

```sh
command -v <tool> >/dev/null 2>&1
```

If the tool or required option is absent, do not retry variants blindly. Use the project's existing approved container/tooling environment. If the capability exists neither on the validated host nor in the approved project runtime, stop with:

```text
EXECUTION_CAPABILITY_MISSING
```

and propose the smallest repository-owned tooling addition through the normal review/authorization path.

Examples:

- PHP syntax/runtime validation belongs in the applicable PHP/WordPress container, not host `php` unless host PHP has been explicitly validated for that task.
- Node/JavaScript build, lint or test commands belong in an approved Node-capable project/CI runtime, not host `node`, `npm` or `pnpm` by assumption.
- database utilities belong in the applicable database/project container.
- shell scripts intended for the NAS must use conservative POSIX/QNAP-compatible constructs and must not assume GNU-only flags or optional commands without a capability check.

Do not install missing project runtimes or utility packages on the NAS as an incidental fix. Host package/runtime installation is a separate QNAP platform change requiring its own governance and authorization.

## 4. Docker authority

Normal project workloads use the Container Station Docker engine:

```text
/var/run/docker.sock
```

The QNAP system Docker engine at `/var/run/system-docker.sock` is intentionally distinct. Never collapse, substitute or redirect one engine to the other.

Prefer existing project services with `docker compose exec -T ...` or a documented project-owned disposable validation service. Adding/pulling a new utility image or changing Dockerfile/Compose dependencies is a project environment change, not an automatic workaround.

## 5. Evidence and mutation discipline

- PASS requires observed evidence from the correct execution context.
- A failure caused by running a tool in the wrong context is not evidence that application code is invalid.
- Do not modify the QNAP merely to satisfy a verifier.
- Do not edit Portainer-managed stack Compose files directly.
- Keep `MUTATION_AUTHORIZED=NO` until a task-specific explicit mutation gate exists.
- Use branch + PR for repository changes; do not merge without explicit user authorization.

Project-local profile documentation may be stricter than the central QNAP policy but must never weaken it.
