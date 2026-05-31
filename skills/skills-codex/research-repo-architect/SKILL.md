---
name: research-repo-architect
description: Organize research code and ARIS skill repositories into lightweight reproducible architecture. Use when Codex needs to scaffold or migrate a research repo for different startup stages, separate reusable code from scripts, standardize data/config/results/run directories, add Python src-layout packaging, create AutoDL/HPC-ready entrypoints with smoke/formal gates, keep local work light, or integrate ARIS skills/tools/shared-references with mainline and Codex mirrors.
---

# Research Repo Architect

Use this skill to turn research code or an ARIS skill bundle into a maintainable, reproducible repository. The base style is inspired by SpectralStore: reusable library code lives under `src/`, scripts are thin entrypoints, configs and suites describe experiments, raw runs are kept separate from curated results, and large artifacts stay out of Git.

## Customized Pack Defaults

For research projects, read `../shared-references/lightweight-research-pack.md`
when available. Default to a lightweight, AutoDL-first shape:

- Classify startup mode: `venue-only`, `reference-paper`,
  `reference-codebase`, `idea-doc`, `existing-repo`, or `partial-results`.
- Local repo work should prepare structure, code, configs, tests, tiny smoke
  checks, prompts, and audit scripts. Do not design the scaffold around heavy
  local execution.
- Add AutoDL/HPC hooks when experiments may need GPU time, but keep execution
  gated and manual by default: runbook, preflight, smoke suite, data manifest,
  and formal-run approval.
- Read `../shared-references/project-guide-protocol.md` when creating project
  memory. Keep `PROJECT_STATUS.md` current so future sessions know the macro
  phase; prefer `PROJECT_BRIEF.md`, `NEXT_ACTIONS.md`, `findings.md`, and
  `EXPERIMENT_LOG.md`; create or refresh `PROJECT_GUIDE.md` only at stage gates.
- For external review, create `review-prompts/` rather than wiring direct API,
  agent, or SSH automation into the repository.

## Workflow

Start by deciding which path applies:

- **New repo scaffold**: Create the architecture first, then add code and experiments into the right layer.
- **Existing repo migration**: Audit first, produce a migration map, then move code in small validated phases.
- **ARIS framework or skill repo**: Preserve the `skills/`, `skills/skills-codex/`, `skills/shared-references/`, `tools/`, `templates/`, `docs/`, `tests/`, and `mcp-servers/` contracts instead of forcing everything into `src/` and `scripts/`.
- **ARIS-managed research project**: Combine the SpectralStore experiment layout with ARIS runtime artifacts such as `research-wiki/`, `idea-stage/`, `refine-logs/`, `review-stage/`, `paper/`, and `.aris/`.
- **AutoDL/HPC-ready research project**: Add target-machine setup, preflight, smoke, result-transfer, and formal-run approval boundaries without weakening source/config/run/result separation.
- **Lightweight project start**: When materials are sparse, create only the
  minimal brief, plan, architecture, and next-action files needed for the current
  startup mode. Avoid generating a full research wiki or large Markdown bundle
  until the project has evidence worth preserving.

For detailed directory rules, read `references/architecture.md`. For ARIS-specific work, read `references/aris-architecture.md`. For AutoDL/HPC work, read `references/autodl-hpc.md`. For migration work, also read `references/migration-playbook.md`.

## New Repo Scaffold

1. Identify the project slug, package/module name, research objective, first experiment ids, expected data sources, and whether the repo is primarily Python. If the user did not specify a package name, derive a lowercase underscore Python package name from the repo slug.
2. Copy or recreate `assets/repo-template/` into the target repo. Replace placeholders:
   - `{{project_slug}}`: repository/project slug, usually kebab-case.
   - `{{package_name}}`: importable module name, usually snake_case.
   - `{{project_title}}`: human-facing project title.
3. Keep reusable implementation under `src/<package_name>/`. Do not put reusable algorithms, models, loaders, metrics, or query logic directly in `scripts/`.
4. Put runnable entrypoints under `scripts/`:
   - `scripts/expN/` for paper or study experiments.
   - `scripts/data/` for download and preprocessing.
   - `scripts/analysis/` for figures, tables, and summaries.
   - `scripts/hpc/` for preflight, cluster wrappers, and machine-specific helpers.
5. Put hand-written configs under `experiments/configs/` and suite definitions under `experiments/suites/`. New run outputs must go under `experiments/runs/`, not `experiments/results/`.
6. Add a short root `README.md` for installation, smoke checks, data, and reproduction commands. Use `docs/` for internal runbooks and maintenance notes.
7. Add a conservative `.gitignore` so raw data, generated runs, caches, model checkpoints, and large binary artifacts are not tracked.
8. If the repo will be run through ARIS, keep ARIS runtime state out of Git by default: `.aris/traces/`, `.aris/cache/`, `.aris/runs/`, `.aris/meta/events.jsonl`, and project-local `.agents/skills/` symlinks.

## Startup Mode Scaffolds

- `venue-only`: create `PROJECT_BRIEF.md`, `NEXT_ACTIONS.md`, a concise
  venue-risk checklist, and optional `review-prompts/venue_direction_review_prompt.md`.
- `reference-paper`: add `references/` or `docs/literature/` notes, a claim map,
  and a reproduction/extension plan before writing experiment code.
- `reference-codebase`: first audit the upstream repo, license, entrypoints,
  environment, and tests; add wrapper scripts instead of modifying upstream code
  blindly.
- `idea-doc`: preserve the original idea doc, extract assumptions into
  `PROJECT_BRIEF.md`, and write the smallest falsifiable validation plan.
- `existing-repo`: run the migration workflow; avoid overwriting existing data,
  results, notebooks, or user notes.
- `partial-results`: inventory logs/figures/tables first, write
  `findings.md` and `EXPERIMENT_LOG.md`, then backfill missing configs or audit
  scripts.

For every startup mode, create or update `PROJECT_STATUS.md` with the current
macro phase, target venue, last accepted artifact, next gate, blockers, and the
phase map from `project-guide-protocol.md`.

## Existing Repo Migration

1. Inspect before editing:
   - Run `git status --short`.
   - Use `rg --files` to inventory code, notebooks, scripts, configs, data, and outputs.
   - Read package/build files and the main run scripts.
2. Classify every important file into one of these destinations: `src/`, `scripts/`, `experiments/configs/`, `experiments/suites/`, `experiments/runs/`, `experiments/results/`, `experiments/visualizations/`, `data/`, `docs/`, or archive.
3. Present or record a migration map before moving files when the repo is large or risky. Preserve user changes and do not delete old locations until imports, commands, and tests pass.
4. Move in phases:
   - Package reusable code into `src/<package_name>/`.
   - Convert ad hoc scripts into thin CLI entrypoints.
   - Move hard-coded parameters into YAML configs.
   - Route new outputs to `experiments/runs/`.
   - Move only reviewed, canonical outputs to `experiments/results/` or `experiments/visualizations/`.
5. Update imports, CLI commands, README instructions, tests, and `.gitignore` after each phase.
6. Never overwrite existing `data/raw/`, `experiments/results/`, or user-created run outputs unless the user explicitly asked for that exact replacement.

## ARIS Skill Repo Integration

Use this path when the repository looks like ARIS: it has `skills/<name>/SKILL.md`, `skills/skills-codex/`, `skills/shared-references/`, `tools/`, `AGENT_GUIDE.md`, or installer scripts such as `install_aris.sh`.

1. Read `references/aris-architecture.md` before editing.
2. Treat `skills/<name>/SKILL.md` as the mainline source of behavior. Treat `skills/skills-codex/<name>/SKILL.md` as the Codex mirror that must preserve semantics while changing reviewer/tool routing only.
3. Put reusable cross-skill contracts under `skills/shared-references/`. Put shared executable helpers under `tools/`. Put single-owner helpers under `skills/<owner>/scripts/` and keep legacy `tools/` shims only when existing skills or installs depend on them.
4. Any helper invocation in a skill must use the canonical ARIS resolver chain from `integration-contract.md`: owner layer 0 when applicable, then `.aris/tools/<helper>`, `tools/<helper>`, and `$ARIS_REPO/tools/<helper>`.
5. When adding or renaming a skill in an ARIS repo, update all required surfaces in the same pass:
   - `skills/<name>/SKILL.md`
   - `skills/skills-codex/<name>/SKILL.md`
   - overlays only if reviewer routing differs
   - `docs/SKILLS_CATALOG.md`
   - count-bearing docs/tests such as `AGENT_GUIDE.md`, README files, Codex mirror README files, and inventory tests
6. Run the repository's inventory and targeted tests after integration. In Codex-managed projects, resolve the ARIS repo root from `.aris/installed-skills-codex.txt` or `$ARIS_REPO` first, then run the checks from that repo:

```powershell
$repo = if ($env:ARIS_REPO) { $env:ARIS_REPO } else { (Select-String -Path ".aris/installed-skills-codex.txt" -Pattern "^repo_root`t").Line.Split("`t")[1] }
Push-Location $repo
python "$repo/tools/check_skills_inventory.py"
python -m pytest "$repo/tests/test_codex_skill_mirror.py" "$repo/tests/test_codex_install_update.py" "$repo/tests/test_install_aris_tools_symlink.py"
Pop-Location
```

7. Do not flatten ARIS skill packages into `src/`. `src/` is for reusable project/library code, not for declarative `SKILL.md` bundles.

## ARIS-Managed Research Projects

Use this path when a normal research project is being operated by ARIS workflows.

- Keep reusable implementation in `src/<package_name>/` and experiment runners in `scripts/` as usual.
- Keep ARIS handoff artifacts where downstream skills expect them unless the user asks for a breaking migration: `RESEARCH_BRIEF.md`, `EXPERIMENT_PLAN.md`, `NARRATIVE_REPORT.md`, `idea-stage/`, `refine-logs/`, `review-stage/`, `paper/`, and `research-wiki/`.
- Treat `.aris/` as runtime state. Do not commit traces, caches, wakeup state, or local skill symlinks unless the project explicitly wants reproducible agent provenance.
- If `research-wiki/` exists, preserve it as persistent project memory. Do not move it under `docs/` or `experiments/`.
- Experiment outputs still go under `experiments/runs/`; curated tables and figures still go under `experiments/results/` and `experiments/visualizations/`.

## AutoDL/HPC-Ready Research Projects

Use this path when the repo will run on AutoDL or another SSH GPU/HPC machine.

- Read `references/autodl-hpc.md` before adding or changing remote-run scripts.
- Keep target-machine setup in `scripts/autodl_setup.sh` and machine checks/wrappers in `scripts/hpc/`.
- Keep AutoDL smoke suites under `experiments/suites/`, with raw outputs under `experiments/runs/autodl_smoke/` and preflight reports under `experiments/runs/preflight/`.
- Keep formal suite definitions disabled or explicitly gated by default. Require a dry-run and user approval before formal execution.
- Keep AutoDL operational docs in `docs/runbooks/AUTODL_HPC_RUNBOOK.md` or an equivalent runbook.
- Treat large uploaded data as an explicit manifest concern: expected paths under `data/raw/` or `data/processed/`, with `data/DATA_MANIFEST.md` updated for anything not tracked in Git.
- Preserve the evidence boundary: smoke output validates engineering readiness only; curated claims and paper-facing tables are generated locally from audited raw runs.

## SpectralStore-Style Rules

- Treat `src/<package_name>/` as the source of truth for reusable behavior.
- Treat `scripts/` as orchestration only: parse args, load config, call package APIs, write outputs.
- Treat `experiments/configs/` as hand-written intent and `experiments/suites/` as reproducible task selection.
- Treat `experiments/runs/` as raw run provenance and `experiments/results/` as curated, stable results.
- Prefer `metrics.json`, `summary.md`, `resolved_config.yaml`, and `run_metadata.json` for experiment output bundles.
- Use `--config`, `--out-dir`, and optional `--set key=value` CLI conventions for experiment scripts.
- Keep data directories present with `.gitkeep`, but ignore large files under `data/raw/`, `data/interim/`, and `data/processed/`.
- Add `.gitattributes` with LF line endings for shell scripts when HPC/Linux execution matters.
- In ARIS repos, keep generated runtime traces under `.aris/traces/` and keep reviewer trace references in audit artifacts instead of pasting reviewer summaries into main artifacts.
- For AutoDL/HPC repos, keep deploy-key bootstrap, FileZilla/SFTP data exceptions, smoke pass criteria, and formal-run approval gates in a runbook instead of burying them in terminal history.

## Validation

For Python repos, validate with the smallest reliable sequence:

```powershell
python -m pip install -e ".[dev]"
python -c "import {{package_name}}; print('{{package_name}} import ok')"
python -m pytest
python -m ruff check src scripts
```

For experiment structure, validate one dry run or tiny smoke task that writes only to `experiments/runs/local_checks/...`. Confirm no command writes directly to `experiments/results/` unless it is an explicit curation or visualization step.

## Resource Usage

- Use `assets/repo-template/` for a new repo baseline or as a target shape during migration.
- Read `references/architecture.md` when deciding where files belong.
- Read `references/aris-architecture.md` when the repo contains ARIS skills, shared references, installer scripts, Codex mirrors, or ARIS workflow artifacts.
- Read `references/autodl-hpc.md` when the repo mentions AutoDL, `/root/autodl-tmp`, FileZilla/SFTP, `scripts/autodl_setup.sh`, `scripts/hpc/preflight_autodl.py`, `run_autodl_smoke.sh`, or formal-suite gating.
- Read `references/migration-playbook.md` before reorganizing an existing repo.
- Do not copy SpectralStore's graph-compression domain code; copy only the repository architecture and reproducibility conventions.
