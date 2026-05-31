---
name: autodl-hpc
description: Prepare, validate, and run AutoDL/HPC research experiments with GitHub deploy-key bootstrap, offline data policy, preflight and smoke gates, FileZilla/SFTP result transfer, and formal-run approval boundaries. Use when Codex needs AutoDL, /root/autodl-tmp, remote GPU/HPC smoke tests, preflight_autodl.py, run_autodl_smoke.sh, deploy keys, formal suite gating, or safe download/audit workflows.
---

# AutoDL HPC

Use this skill for AutoDL or similar SSH GPU/HPC machines where a research repo is cloned to a target machine, validated with preflight/smoke commands, and only then allowed to run formal experiment suites.

Read `references/autodl-hpc.md` before issuing commands, writing a runbook, or changing a repo's AutoDL/HPC workflow.

## Workflow

1. Classify the current phase: bootstrap, data staging, setup, preflight, smoke, formal approval, formal execution, result download, or local audit.
2. Confirm the repo has the expected contracts before remote execution:
   - `scripts/autodl_setup.sh`
   - `scripts/hpc/preflight_autodl.py`
   - `scripts/hpc/run_autodl_smoke.sh`
   - `scripts/run_experiment_suite.py`
   - `scripts/analysis/audit_run_bundles.py`
   - `experiments/suites/autodl_smoke.yaml`
   - `data/DATA_MANIFEST.md` when large uploaded data exists
   - `docs/runbooks/AUTODL_HPC_RUNBOOK.md` or equivalent
3. Treat target-machine smoke as engineering validation only. Do not present smoke metrics as paper evidence or formal results.
4. Keep code sync Git-based: create a machine-specific deploy key on AutoDL, add the public key to GitHub, clone/pull with `git pull --ff-only`, and never copy a local private key to the server.
5. Treat AutoDL as offline except for GitHub access. Required data must already be tracked or uploaded explicitly into expected `data/raw/` or `data/processed/` paths.
6. Run setup, preflight, dry-run, smoke, bundle audit, tests, and lint before any formal run.
7. Require explicit user approval before enabling or running any formal suite. Dry-run formal suites first.
8. Download raw run folders back under `experiments/runs/...`; do not copy them into `experiments/results/` until local audit and result-to-claim scripts have passed.

## Key Rules

- Do not hand-edit server code for formal experiments. Change locally, commit, push, then pull fast-forward on AutoDL.
- Do not upload the whole local repository with FileZilla/SFTP, and never sync `.git/`.
- Do not rely on runtime downloads from UCI, Kaggle, or other external data sites on AutoDL.
- Do not write smoke output into `experiments/results/`.
- Do not edit a frozen protocol after seeing smoke or formal outputs unless making an explicit protocol revision.
- Stop at a failed gate and report the failed command, artifact path, and required fix.

## Coordination

If the repo needs structural changes before AutoDL work, use the research-repo architecture conventions first: reusable code in `src/`, thin entrypoints in `scripts/`, suites in `experiments/suites/`, raw outputs in `experiments/runs/`, and curated outputs only in `experiments/results/`.
