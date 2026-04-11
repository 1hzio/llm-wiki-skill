# Deploy Diagnostics

Use this reference when a deployment workflow fails or when writing deploy steps that need strong observability.

## Failure Classification

Classify failures before changing the workflow.

### SSH exit code 255

Usually means one of:

- DNS or routing failure
- port 22 blocked or wrong host
- host key verification failure
- authentication failure
- remote shell terminated before the command completed

If a plain connectivity test succeeds but a later SSH step returns `255`, suspect the remote command itself.

Common example:

- `pkill -f 'pattern'` kills the shell that is executing the command because the pattern appears in the remote command line

Mitigation:

- move complex remote logic into `ssh ... 'bash -s' <<'EOF'`

### Timeout or flaky startup

Usually means:

- fixed `sleep` is too short
- service starts but binds slowly
- process exits immediately and no one checks PID or logs

Mitigation:

- use bounded retry loops
- check both process liveness and service health
- print or upload logs when readiness never arrives

### Upload step fails after SSH login succeeds

Usually means:

- destination path missing
- permissions wrong
- shell expansion or glob mismatch
- artifact layout in CI does not match deploy script assumptions

Mitigation:

- create directories in a dedicated step
- print local `dist/` tree before upload if the layout is unclear
- keep artifact names and remote paths deterministic

## Diagnostic Sequence

For SSH-style deploys, use this order:

1. validate workflow vars/secrets
2. trust or verify host key
3. run `ssh ... "echo connected"` to prove login works
4. run non-mutating remote checks if needed
5. stop services
6. upload files
7. set permissions
8. run deploy/migrate/restart
9. verify health

If one of these fails, the step name should tell the user exactly where it failed.

## Mandatory Deploy Diagnostics

For deployment workflows, prefer all of the following:

- dedicated config validation step
- explicit `ConnectTimeout`
- strict host key checking
- one concern per step
- no blanket `|| true` except for intentionally idempotent cleanup
- remote scripts executed with `set -euo pipefail`
- failure artifacts when the runner has useful logs/screenshots

## Remote Command Patterns

### Good: remote script over stdin

```bash
ssh user@host 'bash -s' <<'EOF'
set -euo pipefail
mkdir -p /opt/app/bin
pkill -f 'app-server' 2>/dev/null || true
EOF
```

### Good: readiness probe with bounded retries

```bash
for _ in {1..30}; do
  if curl -sf http://127.0.0.1:8080/health > /dev/null; then
    exit 0
  fi
  sleep 1
done
echo "service did not become ready" >&2
exit 1
```

### Bad: opaque remote one-liner

```bash
ssh user@host "pkill -f 'app'; cp -r dist/* /srv/app; ./deploy.sh"
```

It is too easy to hide the real failure, too easy to self-match with `pkill -f`, and too hard to diagnose.
