# Deploy Recipes

Use these patterns when creating deployment workflows. Prefer the smallest recipe that fits the target system.

## 1. SSH / scp / rsync Deploy

Best for:

- a VM or bare-metal host
- copying binaries or built frontend assets
- running a checked-in deploy script remotely

Required workflow shape:

1. build artifacts locally in CI
2. validate deploy variables and secrets
3. trust or verify the host key
4. test SSH connectivity before mutating anything
5. stop remote services
6. create directories
7. upload artifacts
8. set permissions
9. run remote deploy commands
10. verify service health

Strong template requirements:

- `ssh -o StrictHostKeyChecking=yes -o ConnectTimeout=10`
- separate steps for connectivity, stop, upload, chmod, deploy
- no opaque all-in-one deploy shell block
- use `bash -s` via stdin for complex remote logic

Important safety rule:

- do not put `pkill -f 'pattern'` directly in the remote command line if the pattern could match the current remote shell command string

Prefer:

```bash
ssh user@host 'bash -s' <<'EOF'
set -euo pipefail
pkill -f 'my-service' 2>/dev/null || true
mkdir -p /opt/myapp/bin
EOF
```

Not:

```bash
ssh user@host "pkill -f 'my-service'; mkdir -p /opt/myapp/bin"
```

## 2. Container Image Publish

Best for:

- repositories that ship a Docker image
- deployments that are driven by image tags rather than file copy

Required workflow shape:

1. checkout
2. authenticate to the registry
3. build image with deterministic tags
4. push immutable tag and, if needed, one moving tag
5. publish metadata or summary for downstream deploy jobs

Prefer:

- commit SHA tags
- optional release branch/environment tags
- explicit registry login step
- buildx/cache if image build cost is high

Avoid:

- tagging only `latest`
- coupling image build and remote runtime mutation in one opaque step

## 3. Kubernetes Rollout

Best for:

- clusters already managed elsewhere
- repos that own manifests, Helm charts, or Kustomize overlays

Required workflow shape:

1. build or fetch deployable image/artifact
2. authenticate to the cluster
3. render or select manifests
4. apply or upgrade
5. wait for rollout
6. capture rollout failure details

Strong diagnostics:

- print selected namespace and workload names
- use rollout status with timeout
- on failure, print events or workload description

Prefer:

- one step to apply
- one separate step to wait
- one failure-oriented step to dump diagnostics

## 4. Artifact-Only Release

Best for:

- downloadable binaries
- desktop or CLI builds
- projects not deploying to a long-running environment

Required workflow shape:

1. matrix build
2. package outputs with predictable names
3. upload artifact
4. optionally attach to a release

Do not add deployment-specific complexity when the workflow only publishes deliverables.
