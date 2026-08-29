# AutoDL/HPC Research Runbook

Use this reference for AutoDL or similar SSH GPU/HPC execution. It is distilled from a real JMLR P5 engineering runbook and generalized with placeholders.

## Status Model

- **Preflight/smoke phase**: environment validation only. It must not change frozen experiment protocols and must not be treated as paper evidence.
- **Formal phase**: disabled by default. Run only after target-machine smoke passes and the user explicitly approves formal execution.
- **Evidence phase**: starts only after raw outputs are downloaded and audited locally. Curated result files are produced from audit/result-to-claim scripts, not by copying raw remote outputs.

## Project Values To Collect

Record these values in `docs/runbooks/AUTODL_HPC_RUNBOOK.md` or the project runbook:

```text
PROJECT: <project_slug>
GitHub SSH URL: <github_ssh_url>
branch: <branch>
server repo dir: /root/autodl-tmp/<repo_name>
local repo: <local_repo_abs_path>
smoke suite: experiments/suites/autodl_smoke.yaml
```

## Direct SSH Connection

AutoDL's connection panel provides the authoritative endpoint. Copy the command
exactly, then replace only the secret values with local shell variables:

```bash
export AUTODL_HOST=connect.<REGION>.seetacloud.com
export AUTODL_PORT=<PORT>
export AUTODL_USER=root

ssh -p "$AUTODL_PORT" "$AUTODL_USER@$AUTODL_HOST"
```

The displayed form may escape the `@` character as `\@`; the shell form is
`root@<HOST>`. Do not save the password in this file, a runbook, shell history,
or an automation command. Password authentication is interactive. For
non-interactive monitoring and shutdown verification, configure a public key or
an `ssh-agent` locally through the provider's supported SSH settings.

Use the same endpoint for all remote operations:

```bash
ssh -p "$AUTODL_PORT" "$AUTODL_USER@$AUTODL_HOST" "<remote command>"
scp -P "$AUTODL_PORT" <local_path> "$AUTODL_USER@$AUTODL_HOST:<remote_path>"
sftp -P "$AUTODL_PORT" "$AUTODL_USER@$AUTODL_HOST"
```

Do not invent a region, port, hostname, alias, or alternate SSH route. If the
instance is recreated, collect the new command from the console again.

## Expected Repo Contracts

Prefer these paths for AutoDL-ready research repos:

```text
scripts/autodl_setup.sh
scripts/hpc/preflight_autodl.py
scripts/hpc/run_autodl_smoke.sh
scripts/run_experiment_suite.py
scripts/analysis/audit_run_bundles.py
experiments/suites/autodl_smoke.yaml
experiments/runs/preflight/
experiments/runs/autodl_smoke/
data/DATA_MANIFEST.md
docs/runbooks/AUTODL_HPC_RUNBOOK.md
```

Shell scripts should have LF line endings. Add a `.gitattributes` rule if the repo may be edited from Windows:

```gitattributes
*.sh text eol=lf
```

## Optional GitHub Bootstrap

Direct AutoDL SSH login and GitHub authentication are separate concerns. The
following machine-specific deploy-key setup is optional and is needed only when
the server must clone or pull a private repository without interactive GitHub
authentication. Never copy a local private key to AutoDL.

### 1. Generate a machine-specific key on AutoDL

Create one key per AutoDL machine and private repository as an isolation
default. The values below are placeholders and must be filled from the current
task; never copy a local computer's private key to AutoDL.

```bash
mkdir -p /root/.ssh /root/autodl-tmp
chmod 700 /root/.ssh

ssh-keygen -t ed25519 \
  -C "autodl_<project_slug>_$(date +%Y%m%d_%H%M)" \
  -f /root/.ssh/id_ed25519_<project_slug> \
  -N ""
```

The resulting files are:

```text
private key: /root/.ssh/id_ed25519_<project_slug>
public key:  /root/.ssh/id_ed25519_<project_slug>.pub
```

### 2. Show only the public key to the user

The fingerprint is not the value to paste into GitHub:

```bash
ssh-keygen -lf /root/.ssh/id_ed25519_<project_slug>.pub
```

Print the complete public key instead:

```bash
cat /root/.ssh/id_ed25519_<project_slug>.pub
```

The output must be one complete line beginning with `ssh-ed25519`. The private
key must never be sent, uploaded, committed, screenshotted, or written to logs.

### 3. User adds the GitHub Deploy Key

The user opens the target private repository in GitHub and chooses:

```text
Settings -> Deploy keys -> Add deploy key
```

Use a descriptive title such as `AutoDL <project_slug>`, paste the complete
`.pub` line, and leave `Allow write access` disabled unless server-side pushes
are explicitly required. A read-only Deploy Key is sufficient for clone/pull.
The user, not the skill, performs this web-console action and confirms when it
is complete before the server continues.

### 4. Configure the server to select this key

After the user confirms that the key was added to the correct repository:

```bash
cat > /root/.ssh/config <<'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile /root/.ssh/id_ed25519_<project_slug>
  IdentitiesOnly yes
EOF

chmod 600 /root/.ssh/config
chmod 600 /root/.ssh/id_ed25519_<project_slug>
chmod 644 /root/.ssh/id_ed25519_<project_slug>.pub
```

`IdentitiesOnly yes` prevents SSH from trying unrelated keys first. Do not
assume that the default SSH agent selects the newly generated key.

### 5. Verify in layers

First verify GitHub authentication:

```bash
ssh -T git@github.com
```

GitHub's successful response normally says that authentication succeeded but
shell access is not provided. This confirms key authentication, not repository
access. Next verify the exact private repository and branch:

```bash
git ls-remote git@github.com:<owner>/<private_repo>.git \
  HEAD refs/heads/<branch>
```

A returned commit hash confirms the Deploy Key can access that repository.
Only then clone or update:

```bash
cd /root/autodl-tmp
git clone git@github.com:<owner>/<private_repo>.git
cd /root/autodl-tmp/<repo_name>
git checkout <branch>
git rev-parse --short HEAD
git status --short
```

### 6. Diagnose key-selection failures

Use an explicit identity to separate key validity from default SSH selection:

```bash
ssh -i /root/.ssh/id_ed25519_<project_slug> \
  -o IdentitiesOnly=yes \
  -T git@github.com
```

Interpret failures in this order:

```text
explicit -i succeeds, ordinary ssh/git fails
=> inspect ~/.ssh/config, IdentityFile, permissions, and IdentitiesOnly

explicit -i also fails
=> check the private-key path, file permissions, and whether the matching
   .pub line was added to the correct private repository

ssh -T succeeds, git ls-remote fails
=> check the repository SSH URL, owner/repository name, branch, and Deploy Key
   association
```

Inspect the effective SSH configuration without revealing private key contents:

```bash
ssh -G git@github.com | grep -E '^(user|identityfile|identitiesonly) '
```

For an existing server clone:

```bash
cd /root/autodl-tmp/<repo_name>
git stash push -u -m autodl-pre-run-$(date +%Y%m%d)
git pull --ff-only origin <branch>
git rev-parse --short HEAD
git status --short
```

Before remote sync, the local repo should already be a clean package: syntax
checks, suite dry-run, manifest generation, and job-count inspection passed;
then `git commit` and `git push`. Do not hand-edit formal-run code on AutoDL.

## Data Policy

Treat AutoDL as offline except for GitHub access.

- Data needed by smoke or formal runs must be either tracked in Git or explicitly uploaded before execution.
- Upload large original data files with FileZilla/SFTP into the exact expected path, usually under `data/raw/`.
- Update `data/DATA_MANIFEST.md` when data is uploaded outside Git.
- Do not rely on runtime downloads from UCI, Kaggle, Hugging Face, or other external data sources on AutoDL unless the runbook explicitly says that source is reachable and allowed.

Validate data before setup or smoke when project scripts exist:

```bash
python scripts/data/verify_data.py --strict
```

## Network Acceleration And Downloads

Run the provider's network acceleration setup in the same shell as the download:

```bash
source /etc/network_turbo
```

Check the route before starting a large transfer:

```bash
curl -I --max-time 15 https://github.com
curl -I --max-time 15 https://huggingface.co
```

If Hugging Face remains slow, use the domestic mirror explicitly for
Hugging Face clients that support `HF_ENDPOINT`:

```bash
source /etc/network_turbo
export HF_ENDPOINT=https://hf-mirror.com
```

After any mirror download, verify the requested repository revision, file list,
and available SHA-256 or framework-provided checksums. Do not silently mix
mirror output with an official artifact claim.

For a direct archive URL that supports HTTP range requests, `aria2c` (not
`ariac2`) can accelerate a resumable download:

```bash
aria2c -c -x 16 -s 16 -k 1M \
  -d <download_dir> -o <archive_name> <direct_archive_url>
sha256sum <download_dir>/<archive_name>
```

Use `aria2c` only for direct, range-capable URLs. Do not use it as a substitute
for authenticated Hugging Face snapshot handling, Git repositories, Git LFS,
or expiring URLs unless the source explicitly supports that workflow.

## Setup, Preflight, And Smoke

AutoDL non-interactive shells often miss `python`. Start command blocks with:

```bash
export PATH=/root/miniconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PYTHON=/root/miniconda3/bin/python
```

First command on the machine:

```bash
bash scripts/autodl_setup.sh
```

Preflight:

```bash
$PYTHON scripts/hpc/preflight_autodl.py \
  --suite experiments/suites/autodl_smoke.yaml \
  --report experiments/runs/preflight/autodl_preflight.json
```

Optional stricter CUDA check:

```bash
$PYTHON scripts/hpc/preflight_autodl.py \
  --suite experiments/suites/autodl_smoke.yaml \
  --strict-cuda
```

Dry-run the smoke suite before full execution:

```bash
python scripts/run_experiment_suite.py \
  --suite experiments/suites/autodl_smoke.yaml \
  --dry-run
```

Run the smoke suite:

```bash
bash scripts/hpc/run_autodl_smoke.sh
```

Expected smoke outputs should stay under `experiments/runs/autodl_smoke/...`.

## Pass Criteria

P5 target-machine preparation passes only when all relevant gates pass on the AutoDL/HPC machine:

```bash
python scripts/analysis/audit_run_bundles.py \
  --runs-dir experiments/runs/autodl_smoke \
  --require <smoke_run_id_1> <smoke_run_id_2>

python -m pytest
python -m ruff check src scripts
```

If any gate fails, stop. Report the failing command, failing artifact path, and the smallest local-code fix needed. Do not continue into formal suites.

## Formal Run Gate

Before a formal suite:

1. Confirm target-machine smoke has passed.
2. Confirm the formal protocol is frozen and reviewed.
3. Confirm the formal suite is disabled by default or otherwise gated.
4. Ask for explicit user approval for the exact suite and output path.
5. Run the formal suite with `dry-run` first, then generate manifests.

Preferred gate sequence when project wrappers exist:

```bash
bash scripts/hpc/run_formal.sh dry-run
bash scripts/hpc/run_formal.sh manifests
```

Only after explicit approval, launch a detached screen session:

```bash
screen -dmS formal_run -L -Logfile experiments/runs/formal_run/_screen.log bash -lc '
set -euo pipefail
export PATH=/root/miniconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PYTHON=/root/miniconda3/bin/python
echo START
date -Is

bash scripts/hpc/run_formal.sh execute
bash scripts/hpc/run_formal.sh aggregate

echo FORMAL_SUCCESS
date -Is
try_poweroff() {
  command_path="$1"
  [ -x "$command_path" ] || return 1
  "$command_path" -h now && return 0
  "$command_path" && return 0
  return 1
}
for command_path in \
  "$(command -v shutdown 2>/dev/null || true)" \
  /sbin/shutdown /usr/sbin/shutdown /usr/bin/shutdown \
  "$(command -v poweroff 2>/dev/null || true)" \
  /sbin/poweroff /usr/sbin/poweroff /usr/bin/poweroff; do
  [ -n "$command_path" ] || continue
  try_poweroff "$command_path" && exit 0
done
echo "ERROR: no working shutdown or poweroff command found" >&2
exit 127
'
```

With `set -euo pipefail`, a failed command stops the script before
`FORMAL_SUCCESS` and before shutdown, preserving the machine for debugging.
Move the shutdown block only if the project has a different all-success
sentinel; never put it before the aggregate/success lines. Resolve shutdown
and poweroff binaries at runtime rather than assuming they live under `/sbin`.

## Remote Shutdown From Local SSH

Shutdown is an explicit user action, not an automatic cleanup side effect.
Before issuing it, check that no required process is still running and that
all results/logs needed for local transfer are available.

The official documentation describes instance control and SSH access but does
not define a provider-specific SSH shutdown command. Use the compatible
shutdown/poweroff fallback below and treat the machine as shut down only after
a later SSH connection attempt fails:

```bash
ssh -p "$AUTODL_PORT" "$AUTODL_USER@$AUTODL_HOST" \
  'nohup sh -c '"'"'
    sleep 2
    try_shutdown() {
      command_path="$1"
      [ -x "$command_path" ] || return 1
      "$command_path" -h now >/dev/null 2>&1 && return 0
      "$command_path" >/dev/null 2>&1 && return 0
      return 1
    }
    for command_path in \
      "$(command -v shutdown 2>/dev/null || true)" \
      /sbin/shutdown /usr/sbin/shutdown /usr/bin/shutdown \
      "$(command -v poweroff 2>/dev/null || true)" \
      /sbin/poweroff /usr/sbin/poweroff /usr/bin/poweroff; do
      [ -n "$command_path" ] || continue
      try_shutdown "$command_path" && exit 0
    done
    echo "ERROR: no working shutdown or poweroff command found" >&2
    exit 127
  '"'"' >/tmp/autodl-shutdown.log 2>&1 &'
```

For automated verification, key or agent authentication must already work in
batch mode. First verify that the check is meaningful:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 -o ConnectionAttempts=1 \
  -p "$AUTODL_PORT" "$AUTODL_USER@$AUTODL_HOST" true
```

Then poll without reusing a persistent SSH connection:

```bash
for attempt in $(seq 1 12); do
  sleep 5
  if ssh -o BatchMode=yes -o ControlPath=none \
      -o ConnectTimeout=5 -o ConnectionAttempts=1 \
      -p "$AUTODL_PORT" "$AUTODL_USER@$AUTODL_HOST" true \
      >/dev/null 2>&1; then
    continue
  fi
  echo "AUTODL_SHUTDOWN_CONFIRMED: SSH unreachable"
  exit 0
done

echo "ERROR: SSH is still reachable; shutdown not confirmed" >&2
exit 1
```

With password-only authentication, do not use `sshpass` or put the password in
the command. Issue the shutdown command, then manually retry the exact SSH
command until it cannot connect. A transient timeout is not enough if a later
retry succeeds; record the final failed connection attempt and timestamp.

If the shutdown command returns but SSH remains reachable, treat shutdown as
unconfirmed and inspect `/tmp/autodl-shutdown.log` after reconnecting. Never
declare success merely because the remote shell accepted the command.

Audit formal bundles on the server before download when an audit script exists:

```bash
python scripts/analysis/audit_run_bundles.py \
  --runs-dir experiments/runs/<formal_block> \
  --require <formal_run_id_1> <formal_run_id_2>
```

Monitor:

```bash
screen -ls
tail -80 experiments/runs/formal_run/_screen.log
nvidia-smi
find experiments/runs/formal_run/rows -name '*decision.json' | wc -l
```

Interpretation:

- `screen` still exists: task still running.
- `screen` ended and log has `FORMAL_SUCCESS`: success, shutdown has usually
  happened or is imminent.
- `screen` ended and log lacks `FORMAL_SUCCESS`: failed; inspect the tail and
  keep the machine.
- SSH fails after success was observed: likely intentional shutdown.

## FileZilla/SFTP Policy

Upload:

- Upload only missing large data files.
- Use expected data paths such as `/root/autodl-tmp/<repo_name>/data/raw/`.
- Never upload the whole local repo over the server clone.
- Never upload or sync `.git/`.

Download:

- Download raw result folders after completion.
- Preserve the same `experiments/runs/...` shape locally.
- Audit locally before copying or summarizing into `experiments/results/`.

Example:

```text
server: /root/autodl-tmp/<repo_name>/experiments/runs/autodl_smoke/
local:  <local_repo_abs_path>/experiments/runs/autodl_smoke/
```

## Do Not

- Do not write smoke output into `experiments/results/`.
- Do not interpret smoke metrics as paper evidence.
- Do not start formal runs during preflight/smoke preparation.
- Do not start long formal runs in the foreground SSH shell.
- Do not auto-shutdown on failure; success-only shutdown is the default.
- Do not enable a disabled formal suite without explicit user approval.
- Do not edit frozen protocols after seeing outputs unless making an explicit protocol revision.
- Do not hand-edit server code for formal experiments. Change locally, commit, push, then `git pull --ff-only` on AutoDL.
- Do not copy a local private key to AutoDL.
