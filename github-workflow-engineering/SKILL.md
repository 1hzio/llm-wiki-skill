---
name: github-workflow-engineering
description: >
  Create, refactor, and troubleshoot GitHub Actions workflows for CI/CD and deployment.
  Use when working on .github/workflows/*.yml, GitHub Actions pipelines, build/test matrices,
  release artifacts, or deploy failures such as SSH exit code 255, flaky startup checks,
  missing caches, over-broad permissions, or unclear workflow structure.
  Best for designing workflow baselines and for deploy methods with strong diagnostics:
  SSH/scp/rsync, container image publish, and Kubernetes rollout.
---

# GitHub Workflow Engineering

Build GitHub Actions workflows that are fast enough to use, structured enough to maintain, and explicit enough to debug when deployment fails.

This skill is intentionally narrow on deployment methods and deep on diagnostics. Prefer strong templates and observable failure modes over clever one-liners.

## When To Use

Use this skill when the user asks to:

- create or redesign workflows in `.github/workflows/`
- add CI for a repository or monorepo
- split jobs for parallel build/test/deploy
- add cache, matrix, artifacts, concurrency, or minimal permissions
- implement deployment through SSH/scp/rsync, container image publishing, or Kubernetes rollout
- debug opaque deploy failures such as `exit code 255`, host key problems, failed startup checks, or remote script issues

Do not use this skill for provider-specific cloud setup unless the repository already has a strong provider convention and the task is still mostly GitHub Actions engineering.

## Workflow

### 1. Detect the repository shape first

Before proposing YAML, inspect the repo and classify:

- build stack: `go.mod`, `package.json`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `build.gradle`, `Dockerfile`
- test stack: unit/integration/e2e, service containers, browser automation
- delivery target: artifact only, SSH file copy, image registry, Kubernetes
- repo shape: single-service, frontend/backend split, polyglot monorepo

Read [references/create-patterns.md](references/create-patterns.md) and use the closest recipe. If the repo is polyglot, compose the workflow from capability blocks instead of forcing a single-language template.

### 2. Create the workflow baseline

For every new or rewritten workflow, default to this baseline unless the repo clearly requires otherwise:

- use narrow triggers: `pull_request`, `push`, `workflow_dispatch` only where needed
- set minimal `permissions`
- add `concurrency` for long-running CI or deploy workflows
- add `timeout-minutes` to each job
- enable ecosystem-appropriate caching
- split backend/frontend/image/test jobs when they can run in parallel
- upload artifacts only when they are reused downstream or needed for debugging
- keep deploy and CI responsibilities separate unless the repo is intentionally tiny

Use [references/create-patterns.md](references/create-patterns.md) for the composition rules and build/test recipes.

### 3. Choose a supported deployment style

This skill is strongest for these deployment styles:

1. SSH/scp/rsync deploy
2. Container image publish and remote rollout
3. Kubernetes rollout

Use [references/deploy-recipes.md](references/deploy-recipes.md) and pick the smallest pattern that fits the target system. Do not mix multiple deploy styles in one workflow unless the repository already does so.

### 4. Make deployment observable

Deployment workflows must fail with useful signals.

Always prefer:

- a configuration validation step before any network action
- a host trust / login / auth test before the first mutating command
- separate steps for stop, upload, permissions, migration, and restart
- explicit startup checks with bounded retries instead of fixed `sleep`
- log or artifact upload on failure when the runner has local files worth preserving

For SSH deploys, never hide network errors behind `|| true`, and never put dangerous `pkill -f ...` patterns directly in the remote command line if they could match the shell that is executing them. Use `ssh ... 'bash -s' <<'EOF'` for remote scripts when pattern matching or multi-line logic is involved.

Use [references/deploy-diagnostics.md](references/deploy-diagnostics.md) whenever a deploy step fails or when you are designing a deploy workflow from scratch.

### 5. Keep the structure reviewable

When editing workflows:

- prefer one concern per job
- name jobs for the outcome, not the implementation detail
- keep environment-wide values in `env` only when they are truly shared
- avoid repeating complex shell logic across steps; if repetition appears, simplify the workflow or move logic into a checked-in script
- keep shell scripts strict: `set -euo pipefail`

If the user asks for a review, findings come first. Focus on broken triggers, missing gates, unsafe secret usage, non-deterministic startup checks, poor deploy diagnostics, and over-coupled jobs.

## References

- [references/create-patterns.md](references/create-patterns.md): repo detection, workflow composition, build/test recipes, artifact strategy
- [references/deploy-recipes.md](references/deploy-recipes.md): strong deployment templates for SSH/scp/rsync, container image publish, and Kubernetes
- [references/deploy-diagnostics.md](references/deploy-diagnostics.md): failure classification and diagnosis patterns for deploy workflows
