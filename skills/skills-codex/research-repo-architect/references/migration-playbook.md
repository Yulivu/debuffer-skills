# Existing Repo Migration Playbook

## Audit

Start with read-only inspection:

```powershell
git status --short
rg --files
```

Then inspect likely sources of truth:

- Build metadata: `pyproject.toml`, `setup.py`, `requirements*.txt`, `environment.yml`, `renv.lock`, `Project.toml`.
- Main scripts: files under `scripts/`, `run*.py`, `train*.py`, `main*.py`, notebooks, shell wrappers.
- Configs: YAML, JSON, TOML, Hydra config folders, command examples in README.
- Artifacts: `data/`, `outputs/`, `results/`, `runs/`, `wandb/`, `mlruns/`, checkpoints, figures.
- Skill-pack state: `skills/`, `skills/skills-codex/`, `skills/shared-references/`, `tools/`, `.debuffer_skills/`, `.agents/skills/`, `research-wiki/`, `idea-stage/`, `refine-logs/`, `review-stage/`, `paper/`.

## Migration Map

Before moving a large repo, make a table with:

```text
current path | proposed path | reason | risk | validation
```

Use these default mappings:

- Reusable algorithm/model/data/evaluation code -> `src/<package_name>/`.
- Experiment runners -> `scripts/expN/`.
- Dataset download/preprocess scripts -> `scripts/data/`.
- Plotting/table scripts -> `scripts/analysis/`.
- Cluster wrappers/preflights -> `scripts/hpc/`.
- YAML/JSON experiment parameters -> `experiments/configs/`.
- Repro task collections -> `experiments/suites/`.
- Raw run outputs/logs -> `experiments/runs/`.
- Reviewed result tables -> `experiments/results/`.
- Paper-facing figures -> `experiments/visualizations/`.
- Internal notes -> `docs/`.
- Skill definitions -> keep under `skills/<name>/SKILL.md`.
- Codex mirrors -> keep under `skills/skills-codex/<name>/SKILL.md`.
- Shared contracts -> keep under `skills/shared-references/`.
- Shared helpers -> keep under `tools/`, or `skills/<owner>/scripts/` for single-owner helpers.
- Runtime traces/caches/runs -> keep under `.debuffer_skills/` and ignore by default.

## Phased Execution

1. Add or repair `.gitignore`, `.gitattributes`, `pyproject.toml`, and directory skeleton first.
2. Move reusable code into `src/<package_name>/` and update imports.
3. Convert scripts into thin CLIs with `--config` and `--out-dir`.
4. Move parameters into `experiments/configs/`.
5. Create or update `experiments/suites/current_repro.yaml`.
6. Update README with the new install, smoke, data, and experiment commands.
7. Run import checks, tests, and one tiny smoke experiment.

For skill-pack repos, insert a skill inventory phase before step 7:

- Update `docs/SKILLS_CATALOG.md`, Codex mirrors, overlay boundaries, and count-bearing docs/tests when adding or removing skills.
- Verify every helper invocation follows the resolver chain from `skills/shared-references/integration-contract.md`.
- Run `python tools/check_skills_inventory.py` before claiming the integration is complete.

## Safety Rules

- Do not delete old files until the new commands pass.
- Do not overwrite `data/raw/`, `experiments/results/`, or historical outputs without explicit user instruction.
- Keep `research-wiki/`, `idea-stage/`, `refine-logs/`, `review-stage/`, and `paper/` in their workflow paths unless downstream skill paths are updated in the same change.
- Update the upstream skill repo or rerun the installer/reconcile flow when project-local `.agents/skills/` symlinks need refreshing.
- Preserve unrelated user changes in a dirty worktree.
- Prefer moving code in small commits or clearly separated phases.
- If notebooks are the only source of truth, extract reusable code to `src/` and keep notebooks as documentation or exploration artifacts.

## Acceptance Criteria

A migration is done when:

- The package imports from `src/<package_name>/`.
- Tests or smoke checks pass.
- A tiny experiment writes to `experiments/runs/local_checks/...`.
- README commands match the new structure.
- `.gitignore` prevents accidental tracking of raw data, generated runs, caches, and checkpoints.
- The repo has a clear distinction between raw runs, curated results, and visualizations.
