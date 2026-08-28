# AutoDL/HPC Architecture Addendum

Use this addendum when shaping a research repo for AutoDL or similar SSH GPU/HPC execution. It complements the normal `src/`, `scripts/`, `experiments/`, and `data/` architecture; it does not replace it.

## Directory Contract

```text
docs/runbooks/AUTODL_HPC_RUNBOOK.md   Target-machine runbook.
scripts/autodl_setup.sh               First command on a fresh AutoDL clone.
scripts/hpc/preflight_autodl.py       Environment/data/suite preflight checks.
scripts/hpc/run_autodl_smoke.sh       Smoke wrapper for the target machine.
experiments/suites/autodl_smoke.yaml  Target-machine smoke suite.
experiments/runs/preflight/           Preflight JSON reports.
experiments/runs/autodl_smoke/        Smoke raw outputs.
data/DATA_MANIFEST.md                 Manifest for uploaded large data.
```

Keep shell scripts LF-normalized. Add `.gitattributes` when Windows editing is expected:

```gitattributes
*.sh text eol=lf
```

## Runbook Sections

An AutoDL runbook should include:

- Project values: project slug, GitHub SSH URL, branch, server repo dir, and local repo path.
- Preconditions: local protocol status, data availability, Python version, and "no formal run before smoke passes."
- Direct SSH connection: the exact provider-issued host/port command, without storing the password.
- Optional GitHub bootstrap: machine-specific deploy key only when the server must authenticate to GitHub non-interactively.
- Data policy: tracked data paths, FileZilla/SFTP upload exceptions, and `data/DATA_MANIFEST.md` update rules.
- Network acceleration: `source /etc/network_turbo`, explicit Hugging Face mirror fallback, and checksum verification.
- First command: `bash scripts/autodl_setup.sh`.
- Preflight and smoke commands.
- Pass criteria: bundle audit, tests, and lint.
- Formal-run gate: disabled by default, dry-run first, explicit user approval required.
- FileZilla/SFTP paths for uploading missing data and downloading raw run folders.
- Shutdown protocol: issue standard Linux shutdown only after explicit approval, then require SSH unreachability.
- Do-not list for smoke evidence, protocol edits, full-repo upload, `.git/` sync, and server hand edits.

## Operational Boundaries

- Treat AutoDL as network-restricted by default; enable `/etc/network_turbo` only in the download shell.
- Never store the provider password in the repository, runbook, shell history, or automation command.
- Use a machine-specific key only for optional non-interactive GitHub access or batch SSH verification.
- Keep server code immutable during formal runs: edit locally, commit, push, then `git pull --ff-only` on AutoDL.
- Upload only missing large data files with FileZilla/SFTP, never the whole repo and never `.git/`.
- Use `aria2c` only for direct range-capable archive URLs, followed by hash verification.
- Keep smoke output in `experiments/runs/autodl_smoke/`; it is not paper evidence.
- Keep formal raw outputs in `experiments/runs/<formal_block>/`; copy into `experiments/results/` only after local audit/result-to-claim scripts produce curated artifacts.

## Gate Sequence

Use this order for target-machine validation:

```bash
bash scripts/autodl_setup.sh

python scripts/hpc/preflight_autodl.py \
  --suite experiments/suites/autodl_smoke.yaml \
  --report experiments/runs/preflight/autodl_preflight.json

python scripts/run_experiment_suite.py \
  --suite experiments/suites/autodl_smoke.yaml \
  --dry-run

bash scripts/hpc/run_autodl_smoke.sh

python scripts/analysis/audit_run_bundles.py \
  --runs-dir experiments/runs/autodl_smoke \
  --require <smoke_run_id_1> <smoke_run_id_2>

python -m pytest
python -m ruff check src scripts
```

If a project does not use `pytest` or `ruff`, replace those commands with the repo's actual test/lint gates, but keep the setup -> preflight -> dry-run -> smoke -> audit -> tests order.

## Formal Suite Requirements

Formal suites should be explicit YAML files under `experiments/suites/`, dry-runnable with `scripts/run_experiment_suite.py`, and output only to `experiments/runs/...`.

Before formal execution:

1. Confirm target-machine smoke passed.
2. Confirm the frozen protocol or formal plan file path.
3. Confirm the suite is disabled by default or otherwise approval-gated.
4. Ask for explicit approval naming the suite and output directory.
5. Run `--dry-run`.

Do not start formal suites while the repo is still in preflight/smoke preparation.
