---
name: hpc-formal-run-gate
description: Prepare and supervise a clean formal experiment rerun on AutoDL/HPC after smoke tests, with conservative resource planning and safe process/session hygiene. Use when the user says "formal rerun", "AutoDL final run", "HPC experiment gate", "screen重跑", "clean final run", or "正式实验重跑".
---

# HPC Formal Run Gate

Use this skill after local checks and AutoDL/HPC smoke tests pass, when the user
wants a clean formal rerun suitable for final evidence.

Prefer preparing commands for the user to run. Do not execute SSH commands
autonomously unless the user has explicitly configured and approved that mode.

## Gate Workflow

1. Verify the local package is clean before remote work:
   - local syntax checks, suite dry-run, manifest generation, and job-count
     inspection have passed.
   - the run-ready code is committed and pushed.
   - no formal-run code edits are planned on the server.
2. Verify remote source state:
   - `cd /root/autodl-tmp/<repo>`
   - `git stash push -u -m autodl-pre-run-$(date +%Y%m%d)`
   - `git pull --ff-only origin <branch>`
   - `git status --short`
   - `git branch --show-current`
   - `git log -1 --oneline`
   - record the exact commit in the run note or runbook.
3. Preserve existing datasets:
   - identify mounted, downloaded, or copied data paths.
   - do not delete `data/raw/`, `data/processed/`, `/root/autodl-tmp`, or
     equivalent cache paths during cleanup.
4. Check data presence and expected file counts before running:
   - `find data -maxdepth 3 -type f | wc -l`
   - `du -sh data /root/autodl-tmp 2>/dev/null`
5. Make the Python path explicit in every non-interactive command block:
   - `export PATH=/root/miniconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`
   - `export PYTHON=/root/miniconda3/bin/python`
6. Run the gate sequence first. Formal runs require a passed smoke or a written
   waiver.
7. Dry-run the formal suite and inspect:
   - task count, dataset count, expected output directories.
   - GPU/CPU/RAM estimate.
   - worker and thread configuration.
8. Choose conservative resource settings:
   - do not trust `os.cpu_count()` alone in containers.
   - check `nproc`, CPU affinity, cgroup limits, and available RAM.
   - prefer fewer `workers` and `threads-per-job` over unstable parallelism.
9. Start formal work only inside detached `screen` or `tmux` with a logfile.
10. Use a success sentinel (`FORMAL_SUCCESS`) before optional shutdown. Failed
    runs must preserve the machine for debugging.
11. Monitor process tree, logs, run directories, and output counts.
12. For interrupted runs, separate partial failed output from clean final output.
13. Clean old failed runs only after showing disk usage, checking live processes,
    and getting user approval.
14. Require all-success status before promote/package.

## Command Patterns

Prepare project-specific blocks using patterns like:

```bash
cd /root/autodl-tmp/<repo>
git stash push -u -m autodl-pre-run-$(date +%Y%m%d)
git pull --ff-only origin <branch>
git rev-parse --short HEAD
git status --short

export PATH=/root/miniconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PYTHON=/root/miniconda3/bin/python

git log -1 --oneline
screen -ls
tmux ls || true
nproc
$PYTHON - <<'PY'
import os
print("cpu_count", os.cpu_count())
try:
    print("affinity", len(os.sched_getaffinity(0)))
except Exception as exc:
    print("affinity unavailable", exc)
PY
du -sh data experiments/runs /root/autodl-tmp 2>/dev/null || true
find experiments/runs -type f | wc -l
ps -eo pid,ppid,etime,pcpu,pmem,cmd | grep -E "python|run_|suite|screen|tmux" | grep -v grep
tail -f experiments/runs/<run_id>/logs/<job>.log
```

Canonical gate sequence:

```bash
bash scripts/autodl_setup.sh
$PYTHON scripts/hpc/preflight_autodl.py <project-specific args>
bash scripts/hpc/run_autodl_smoke.sh
bash scripts/hpc/run_formal.sh dry-run
bash scripts/hpc/run_formal.sh manifests
```

For long formal execution, prefer this detached-screen pattern:

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

If the project does not provide `scripts/hpc/run_formal.sh`, replace only the
two formal commands inside the `screen` body with the project-specific execute
and aggregate commands. Keep `set -euo pipefail`, `FORMAL_SUCCESS`, and the
success-only shutdown placement.

Monitor with:

```bash
screen -ls
tail -80 experiments/runs/formal_run/_screen.log
nvidia-smi
find experiments/runs/formal_run/rows -name '*decision.json' | wc -l
```

Interpretation:

- `screen` still exists: the task is still running.
- `screen` ended and `_screen.log` contains `FORMAL_SUCCESS`: the run succeeded
  and shutdown has usually happened or is imminent.
- `screen` ended and `_screen.log` lacks `FORMAL_SUCCESS`: the run failed; use
  the log tail and preserve the machine.
- SSH is unreachable after a previously observed `FORMAL_SUCCESS`: treat that
  as successful auto-shutdown, then collect results when the machine is started
  or mounted again.

## Guardrails

- Do not run formal experiments outside a persistent session.
- Do not run formal experiments from a foreground SSH shell.
- Do not place `/sbin/shutdown -h now` before the success sentinel.
- Do not mix partial failed results into submission artifacts.
- Do not kill processes blindly; identify parent/child relationships first.
- Do not clean old runs before showing `du -sh` and active process checks.
- If a run fails, label its output as failed/partial and keep it out of final
  curation until rerun or explicitly accepted.
