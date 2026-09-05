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
- `START_HERE.md`
- `CURRENT_STATE.yaml`
- `docs/QNAP_PLATFORM_CANONICAL_BASELINE_v1.0.0.md`
- `docs/EVIDENCE_INDEX.md`
- `docs/EXECUTION_SUBSTRATE_POLICY.md` for NAS-side code/tool execution
- `docs/TOOLCHAIN_FRESHNESS_POLICY.md` before substantive development that depends on material tooling
- `docs/CANONICAL_DEVELOPMENT_TOOLCHAIN_POLICY.md` before shared tooling is consumed or changed
- `docs/CANONICAL_TOOLCHAIN_REGISTRY.md` to resolve current shared tool identity/state
- `docs/TOOLCHAIN_ASSISTANT_EXECUTION_CONTRACT.md` before consuming any shared QNAP development/support command

Do not infer current QNAP state, shared-tool version, backend or activation method from historical validation files in this repository.

## 2. QNAP bootstrap gate

Before mutation-capable, capacity-sensitive or substantive development work on QNAP, record:

```text
QNAP_GOVERNANCE_READ=PASS
QNAP_CURRENT_STATE_READ=PASS
QNAP_EVIDENCE_INDEX_READ=PASS
QNAP_EXECUTION_SUBSTRATE_POLICY_READ=PASS|NOT_APPLICABLE
QNAP_TOOLCHAIN_FRESHNESS_POLICY_READ=PASS|NOT_APPLICABLE
QNAP_CANONICAL_TOOLCHAIN_POLICY_READ=PASS|NOT_APPLICABLE
QNAP_TOOLCHAIN_ASSISTANT_EXECUTION_CONTRACT_READ=PASS|NOT_APPLICABLE
QNAP_LIVE_SNAPSHOT_REQUIRED=YES|NO
QNAP_LIVE_SNAPSHOT_RUN_ID=<run-or-NOT_REQUIRED>
HOST_TOOL_ASSUMPTION_ALLOWED=NO
CANONICAL_TOOLCHAIN_IDENTITY_RESOLVED=YES|NO|NOT_APPLICABLE
CANONICAL_TOOLCHAIN_INTERFACE_STATE=ACTIVE|TRANSITION|NOT_APPLICABLE
CANONICAL_TOOLCHAIN_BOOTSTRAP=PASS|BLOCKED|NOT_APPLICABLE
PROJECT_BACKEND_KNOWLEDGE_REQUIRED=NO|NOT_APPLICABLE
NON_CANONICAL_HOST_TOOL_USE=NO|NOT_APPLICABLE
TOOLCHAIN_FRESHNESS_GATE=PASS|BLOCKED|NOT_APPLICABLE
TOOLCHAIN_UPDATE_AUTHORIZED=NO
MUTATION_AUTHORIZED=NO
```

A fresh same-window QNAP snapshot is required whenever current capacity, runtime health, Docker identity, storage, VM capability or platform mutation can affect the decision.

## 3. Stable shared-tool interface — no project relearning

This project inherits the central QNAP assistant execution contract. The implementation backend of a **shared** tool is central platform knowledge and must not be redefined here.

Read central `CURRENT_STATE.yaml` before consuming shared tooling:

- if the canonical projection is active, bootstrap it once using the central activation helper;
- if it is still in transition, use only the identity currently allowed by the central registry and do not activate candidate providers locally.

After central bootstrap, assistants continue to use ordinary command names and semantics, for example:

```sh
git status
git pull --ff-only
git commit -m "..."
python script.py
pip --version
node --version
npm ci
npx <tool>
```

This repository must not teach or require Entware roots, QPKG paths, uv provider paths, Docker image names or `docker run` syntax merely to consume a shared canonical tool. Project-owned WordPress/PHP/DB/Node runtime containers may still define their own runtime-specific commands; that is a separate project-runtime contract.

If a candidate central backend cannot preserve ordinary CLI semantics transparently, the platform must reject that backend. `wp-dev-platform` must not be changed to compensate for a shared-tool backend incompatibility.

## 4. Execution context — never treat the QNAP as a generic developer workstation

The QNAP host is a control/orchestration/storage plane with a governed support-tool layer. The project profile/runtime owns runtime-representative application tooling, but verified shared QNAP tooling may be used for suitable development/support work through the governed interface.

Never infer that PHP, Composer, WP-CLI, Node.js, npm/pnpm/yarn, Python packages, database clients, browsers, FFmpeg, GNU utilities or another project runtime/tool is present or absent merely from common Linux expectations or the shell `PATH`.

Before first use of an optional host tool:

1. inspect same-window `host-capabilities.tsv` and `qpkg-inventory.tsv` when available;
2. otherwise perform one bounded read-only `command -v` probe;
3. if App Center/QPKG or Entware indicates an installed package outside `PATH`, resolve the package `Install_Path`, executable path and version once;
4. for a shared canonical tool, prefer the central stable interface over package-specific paths;
5. use the execution context that matches what the validation must prove.

If the tool or required option is absent, do not retry variants blindly. If the capability exists neither in the verified shared support layer nor in the approved project runtime, stop with:

```text
EXECUTION_CAPABILITY_MISSING
```

and propose the smallest controlled shared-support or repository-owned tooling addition through the normal review/authorization path.

Examples:

- PHP/WordPress runtime acceptance belongs in the applicable PHP/WordPress container unless host PHP is explicitly part of the compatibility claim.
- Shared canonical Node.js may be used for suitable lint/build/support work when compatible; Node runtime acceptance belongs to the declared project runtime when that differs.
- database utilities belong in the applicable database/project container unless a verified host client is sufficient for the exact non-runtime-sensitive task.
- shell scripts intended for the NAS must use conservative POSIX/QNAP-compatible constructs and must not assume GNU-only flags or optional commands without a capability check.

Controlled shared support-tool installation or update is permitted only under the central governance authorization/retention/removal policy. Incidental/untracked host installation remains prohibited.

## 5. Pre-development toolchain freshness gate

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

An update recommendation does not authorize mutation. Shared QNAP tool updates require explicit central authorization; project Dockerfile/Compose/dependency updates follow this repository's normal branch/PR/validation workflow.

## 6. Docker authority

Normal project workloads use the Container Station Docker engine:

```text
/var/run/docker.sock
```

The QNAP system Docker engine at `/var/run/system-docker.sock` is intentionally distinct. Never collapse, substitute or redirect one engine to the other.

Prefer existing project services with `docker compose exec -T ...` or a documented project-owned disposable validation service when runtime-representative execution is required. Adding/pulling a new utility image or changing Dockerfile/Compose dependencies is a project environment change, not an automatic workaround.

## 7. Evidence and mutation discipline

- PASS requires observed evidence from the correct execution context and a material-tool freshness state compatible with the claim.
- A failure caused by running a tool in the wrong context is not evidence that application code is invalid.
- Do not modify the QNAP merely to satisfy a verifier.
- Do not edit Portainer-managed stack Compose files directly.
- Keep `MUTATION_AUTHORIZED=NO` until a task-specific explicit mutation gate exists.
- Keep `TOOLCHAIN_UPDATE_AUTHORIZED=NO` until a specific shared/project tooling update is reviewed.
- Use branch + PR for repository changes; do not merge without explicit user authorization.

Project-local profile documentation may be stricter than the central QNAP policy but must never weaken it or redefine the backend implementation of a shared canonical tool.
