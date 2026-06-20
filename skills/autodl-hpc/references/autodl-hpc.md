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

## Server Bootstrap

Create an AutoDL machine-specific SSH key. Never copy a local private key to AutoDL.

```bash
mkdir -p /root/.ssh /root/autodl-tmp
chmod 700 /root/.ssh

ssh-keygen -t ed25519 \
  -C "autodl_<project_slug>_$(date +%Y%m%d_%H%M)" \
  -f /root/.ssh/id_ed25519_<project_slug> \
  -N ""

cat > /root/.ssh/config <<'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile /root/.ssh/id_ed25519_<project_slug>
  IdentitiesOnly yes
EOF

chmod 600 /root/.ssh/config /root/.ssh/id_ed25519_<project_slug>
chmod 644 /root/.ssh/id_ed25519_<project_slug>.pub
cat /root/.ssh/id_ed25519_<project_slug>.pub
```

Add the printed public key to the GitHub repository as a deploy key. Usually do not enable write access. Then test and clone:

```bash
ssh -T git@github.com

cd /root/autodl-tmp
git clone <github_ssh_url>
cd /root/autodl-tmp/<repo_name>
git checkout <branch>
git rev-parse --short HEAD
git status --short
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
/sbin/shutdown -h now
'
```

With `set -euo pipefail`, a failed command stops the script before
`FORMAL_SUCCESS` and before shutdown, preserving the machine for debugging.
Move `/sbin/shutdown -h now` only if the project has a different all-success
sentinel; never put it before the aggregate/success lines.

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
