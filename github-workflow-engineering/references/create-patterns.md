# Create Patterns

Use this reference when creating or restructuring workflows.

## Repository Detection

Inspect the repo before writing YAML.

| Signal | Meaning |
| --- | --- |
| `go.mod` | Go build/test workflow likely needed |
| `package.json` | Node frontend or service workflow likely needed |
| `pyproject.toml`, `requirements.txt` | Python build/test workflow likely needed |
| `Cargo.toml` | Rust workflow likely needed |
| `pom.xml`, `build.gradle*` | Java workflow likely needed |
| `Dockerfile` | Container image build path exists |
| `docker-compose*.yml`, service containers | Integration tests may need infra |
| `playwright`, `cypress`, `selenium` | E2E/browser job likely needed |
| `.github/workflows/*.yml` | Existing conventions should usually be preserved |

If multiple ecosystems exist, split by capability instead of forcing one large job.

## Default Composition Rules

### CI workflows

For general CI, prefer:

- `pull_request` for review gates
- `push` for protected branches if branch-level CI is still useful
- separate jobs for build/test concerns that can run in parallel
- artifact upload only when used by downstream jobs or needed for debugging

Default safety baseline:

- `permissions: contents: read`
- `concurrency` on expensive workflows
- `timeout-minutes` on every job
- cache with the ecosystem-native mechanism in `setup-*` actions

### Deploy workflows

For deploy workflows, prefer:

- `push` to a protected branch or `workflow_dispatch`
- a build phase that produces reusable artifacts or images
- a deploy phase that only consumes validated outputs
- explicit `needs:` relationships
- environment-specific variables and secrets, not hardcoded endpoints

## Build And Test Recipes

### Go

- setup: `actions/setup-go`
- version source: `go-version-file: go.mod`
- cache: enable built-in Go cache
- common commands:
  - `go build ./...` or targeted binaries
  - `go test ./... -timeout 60s`

If the repo builds multiple binaries, build only the release artifacts needed for downstream jobs and keep broad `go test ./...` as a separate check.

### Node

- setup: `actions/setup-node`
- cache: `cache: npm|pnpm|yarn`
- install once per job: `npm ci`, `pnpm install --frozen-lockfile`, or `yarn --frozen-lockfile`
- separate commands:
  - build: `npm run build`
  - test: `npm test -- --run` or repo-specific command

Do not repeat package install across unrelated jobs unless the parallelism is worth the cost.

### Python

- setup: `actions/setup-python`
- cache package manager when practical
- install with deterministic lockfiles where available
- split lint/test/build when they provide separate signal

### Rust

- setup: toolchain action or rustup bootstrap
- cache Cargo directories and target output carefully
- common commands:
  - `cargo build --locked`
  - `cargo test --locked`

### Java

- setup: `actions/setup-java`
- use build tool cache
- common commands:
  - Maven: `mvn -B verify`
  - Gradle: `./gradlew build`

### Polyglot repos

When backend and frontend are independent enough to run in parallel:

- `build-backend`
- `build-frontend`
- optional `build-image`
- `deploy` consumes artifacts from the required jobs

Avoid putting frontend and backend build/test in one job unless the repo is very small.

## Artifact Strategy

Use artifacts only when they materially improve correctness or speed:

- use artifacts between build and deploy jobs
- use artifacts for screenshots/logs on failure
- avoid uploading large transient outputs no downstream job uses

Typical aggregation pattern:

1. backend job uploads binary + migrations + scripts
2. frontend job uploads built assets
3. deploy job downloads both into `dist/`
4. deploy job adds platform-specific release files if needed

## Review Checklist

When reviewing a workflow you did not create, check in this order:

1. Are the triggers correct?
2. Are mandatory tests/builds missing from PR CI?
3. Are jobs overly serialized?
4. Are permissions broader than necessary?
5. Are startup checks based on fixed sleeps instead of bounded readiness probes?
6. Are artifacts/caches used correctly?
7. Is deploy isolated from CI and sufficiently diagnosable?
