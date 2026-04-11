# Review And Repair

Use this reference when reviewing or repairing existing GitHub Actions workflows.

## Review Output Format

When the user asks for a review:

1. findings first
2. order by severity
3. include file references
4. keep the summary brief and secondary

Focus on:

- behavioral regressions
- missing CI gates
- broken trigger logic
- unsafe secret or permission usage
- low-observability deploy steps
- flaky readiness checks
- over-coupled jobs that hide failures

If there are no concrete findings, say so explicitly and mention any residual risks or gaps.

## Severity Model

### High

Use high severity when the workflow can:

- silently skip mandatory verification
- deploy broken artifacts
- expose secrets or grant unnecessary mutation capability
- fail in production with weak or misleading diagnostics
- make recovery materially harder

### Medium

Use medium severity when the workflow:

- wastes substantial CI time
- has significant flake risk
- obscures failure location
- has maintainability problems likely to cause future regressions

### Low

Use low severity for:

- minor inefficiencies
- style issues
- opportunities to simplify naming, caching, or artifact layout

## Review Checklist

Check these areas in order:

1. trigger coverage
2. version alignment with the repo
3. required build/test gates
4. job topology and unnecessary serialization
5. permissions and secret boundaries
6. cache correctness
7. artifact correctness
8. deploy diagnostics and rollback friendliness

## Common Repair Patterns

### Missing PR verification

Symptom:

- build or tests run only on `push main`

Repair:

- add or split a dedicated CI workflow for `pull_request`
- keep deploy workflows scoped to protected branches or manual dispatch

### Version drift

Symptom:

- workflow hardcodes tool versions inconsistent with the repo's real configuration

Repair:

- source versions from files when possible:
  - Go: `go-version-file: go.mod`
  - Node: keep runner version explicit but aligned with project expectations

### Over-serialized jobs

Symptom:

- frontend and backend build/test run in one job even though they are largely independent

Repair:

- split into `build-backend`, `build-frontend`, `test-*`, or image build jobs
- aggregate only where artifacts must meet

### Flaky startup checks

Symptom:

- fixed `sleep 3` / `sleep 5` before tests or deploy verification

Repair:

- replace with bounded readiness loops
- verify either health endpoints, process liveness, or service-specific logs

### Opaque deploy failures

Symptom:

- one large shell block does stop/upload/deploy in a single step

Repair:

- split into validation, connectivity, stop, upload, chmod, deploy, verify

### Dangerous remote shell matching

Symptom:

- `ssh host "pkill -f 'pattern'; ..."`

Repair:

- move remote logic into `ssh host 'bash -s' <<'EOF'`
- keep `pkill -f` patterns out of the remote shell argv when self-match is possible

### Over-broad permissions

Symptom:

- workflows inherit broad default token access without need

Repair:

- set explicit minimal `permissions`
- grant write scopes only to the jobs that truly need them

## Repair Philosophy

Prefer the smallest defensible fix that:

- restores correctness
- improves observability
- preserves team conventions where reasonable

Do not rewrite the entire workflow unless the current structure is actively blocking a correct fix.
