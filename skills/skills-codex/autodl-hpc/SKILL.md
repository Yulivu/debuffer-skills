---
name: autodl-hpc
description: Prepare, validate, and gate AutoDL/HPC research experiments through the direct SSH command shown by AutoDL, with network acceleration, preflight and smoke gates, FileZilla/SFTP result transfer, verified remote shutdown, and formal-run approval boundaries. Defaults to command preparation over autonomous SSH execution. Use when Codex needs AutoDL, direct SSH access, /root/autodl-tmp, remote GPU/HPC smoke tests, preflight_autodl.py, run_autodl_smoke.sh, network_turbo, formal suite gating, or safe download/audit workflows.
---

# AutoDL HPC

## Capability Routing

This is a first-layer entry skill. Keep it loaded as the user-facing route; when a request needs a specialized capability below, resolve the debuffer repo root from `.debuffer_skills/installed-skills-codex.txt` (`repo_root`) when available, read the referenced library `SKILL.md`, then follow that skill. Do not copy the whole library skill into this file.

- `/system-profile`: read `../../skills-codex-library/experiments/system-profile/SKILL.md`.
- `/training-check`: read `../../skills-codex-library/experiments/training-check/SKILL.md`.
- `/run-experiment`: read `../../skills-codex-library/experiments/run-experiment/SKILL.md`.
- `/analyze-results`: read `../../skills-codex-library/experiments/analyze-results/SKILL.md`.
- `/hpc-formal-run-gate`: read `../../skills-codex-library/experiments/hpc-formal-run-gate/SKILL.md`.


Use this skill for AutoDL or similar SSH GPU/HPC machines where the exact provider-issued SSH command is used to access a target machine, the repo is validated with preflight/smoke commands, and only then allowed to run formal experiment suites.

Read `references/autodl-hpc.md` before issuing commands, writing a runbook, or changing a repo's AutoDL/HPC workflow. For any nontrivial remote environment setup or rebuild, also read `../shared-references/compute-env-contract.md` and use an env spec + hash ledger + smoke witness before declaring the machine ready.

## Direct SSH Contract

- Always start from the exact SSH command shown in the AutoDL console, for example:
  `ssh -p <PORT> root@connect.<REGION>.seetacloud.com`.
- Treat the host, port, username, and password as session-specific secrets. Never
  commit them, place the password in a command block, or put the password in a
  runbook. The user enters a password interactively, or configures an AutoDL
  public key through the provider console.
- Store the connection as placeholders or an SSH config alias only after the
  user has created it locally. Do not invent a region, port, host, or alias.
- Use the same direct endpoint for `ssh`, `scp`, `sftp`, monitoring, and shutdown
  verification. Do not silently fall back to an old server alias.
- The backslash sometimes shown before `@` is escaping from a display layer; the
  shell command is `root@host`.

## Customized Pack Defaults

- Prefer command preparation over direct SSH execution. If the user has not
  explicitly approved remote execution, output the exact AutoDL command block and
  wait for pasted results. When approved, use the provider-issued direct SSH
  command rather than a generated connection abstraction.
- Keep local work lightweight: repo edits, tests, lint, config validation,
  manifest updates, and result audit. Heavy training belongs on AutoDL/HPC.
- Do not implement fully autonomous SSH workflows. SSH remains a manual or
  explicitly approved boundary, including shutdown.
- Keep runbooks concise. Merge repeated operational notes into
  `docs/runbooks/AUTODL_HPC_RUNBOOK.md` instead of generating new long Markdown
  files for every attempt.
- Read `../shared-references/autosci-lite-patterns.md` for the pilot gate and
  negative-memory rules. Formal suites require a passed pilot or an explicit
  waiver recorded in the runbook.

## Workflow

1. Classify the current phase: bootstrap, data staging, setup, preflight, smoke, pilot gate, formal approval, formal execution, result download, or local audit.
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
4. Prepare a clean local package before touching AutoDL: syntax checks, suite dry-run, manifest generation, job-count inspection, then `git commit` and `git push`. Do not use the server as a development workspace.
5. Keep code sync Git-based when possible: commit and push locally, then use the direct SSH endpoint to run `git pull --ff-only` on the server. If GitHub access from the server is unavailable, use narrowly scoped `scp`/`rsync` transfers; never copy a local private key to the server.
6. Always make the remote Python path explicit in prepared AutoDL command blocks: `export PATH=/root/miniconda3/bin:...` and `export PYTHON=/root/miniconda3/bin/python`. Use `$PYTHON` in gate commands when possible.
7. Treat AutoDL as network-restricted by default. Before a slow GitHub or Hugging Face download, run `source /etc/network_turbo` in the same shell. If Hugging Face remains slow, use the documented `https://hf-mirror.com` endpoint as an explicit fallback, then verify revision and hashes.
8. Run setup, preflight, dry-run, smoke, formal dry-run, and formal manifest generation before any formal execution. If setup changes Python/CUDA/packages/weights, update the compute environment ledger first and rerun the smoke witness.
9. Run or review a bounded pilot gate before formal suites. Pilot output stays under `experiments/runs/pilot/...` or another raw run path and is not paper evidence.
10. Require explicit user approval before enabling or running any formal suite. Dry-run formal suites first.
11. Launch long formal work only in a detached `screen`/`tmux` session with logs. If shutdown is requested, use the shutdown protocol in `references/autodl-hpc.md`; never shut down before the final success sentinel.
12. Download raw run folders back under `experiments/runs/...`; do not copy them into `experiments/results/` until local audit and result-to-claim scripts have passed.

## Key Rules

- Do not hand-edit server code for formal experiments. Change locally, commit, push, then pull fast-forward on AutoDL.
- Do not start a long formal run directly from the SSH foreground shell.
- Do not auto-shutdown on failure. The shutdown command belongs after `FORMAL_SUCCESS` or an equivalent all-success sentinel.
- Do not call shutdown successful because the remote command returned; success
  requires a subsequent SSH connection attempt to fail.
- Do not automate shutdown verification with a plaintext password or
  `sshpass`. Batch verification requires a preconfigured key or agent.
- Do not upload the whole local repository with FileZilla/SFTP, and never sync `.git/`.
- Do not rely on runtime downloads from UCI, Kaggle, or other external data
  sites on AutoDL. Prefer `network_turbo`, then an explicit Hugging Face mirror
  fallback; use `aria2c` only for range-capable direct archive URLs.
- Do not write smoke output into `experiments/results/`.
- Do not treat pilot output as paper evidence; use it only to decide whether
  formal runs are safe to launch.
- Do not edit a frozen protocol after seeing smoke or formal outputs unless making an explicit protocol revision.
- Stop at a failed gate and report the failed command, artifact path, and required fix.
- If pilot or smoke fails, update `experiments/NEGATIVE_RESULTS.md` with the
  run id, artifact path, failure reason, and decision.

## Coordination

If the repo needs structural changes before AutoDL work, use the research-repo architecture conventions first: reusable code in `src/`, thin entrypoints in `scripts/`, suites in `experiments/suites/`, raw outputs in `experiments/runs/`, and curated outputs only in `experiments/results/`.
