# SpectralStore-Style Research Repo Architecture

This reference covers ordinary research code repositories. If the repo contains skill-pack infrastructure such as `skills/<name>/SKILL.md`, `skills/skills-codex/`, `skills/shared-references/`, `.debuffer_skills/`, `research-wiki/`, `idea-stage/`, or `refine-logs/`, also read `skill-pack-architecture.md` before moving files.

## Directory Contract

```text
data/                    Dataset staging area; large artifacts ignored.
docs/                    Internal runbooks, analysis notes, and maintenance docs.
  project/               Briefs, status companions, blueprints, project guides.
  experiments/           Experiment protocols, logs, trackers, audit notes.
  evidence/              Findings, evidence ledgers, claim maps.
  paper/                 Paper guides, narrative reports, outline notes.
  theory/                Proof, theorem, and derivation packages.
  runbooks/              AutoDL/HPC and operational runbooks.
experiments/
  configs/               Hand-written logical experiment configs.
  suites/                Reproducible task collections.
  runs/                  Raw run outputs, logs, status files, and provenance.
  results/               Curated canonical result tables or artifacts.
  visualizations/        Paper-facing figures and figure summary CSVs.
scripts/
  exp1/ ... expN/        Experiment entrypoints.
  analysis/              Figure, table, and result-summary generation.
  data/                  Dataset download and preprocessing.
  diagnostics/           One-off checks that should not be paper entrypoints.
  hpc/                   Cluster wrappers, generated configs, and preflight checks.
src/<package_name>/      Reusable implementation.
```

Root Markdown is intentionally sparse. Ordinary research repos should keep only
`README.md`, `PROJECT_STATUS.md`, and tool-managed `AGENTS.md` / `CLAUDE.md` in
the root. Skill workflow directories may coexist at the repo root and should
remain in their workflow paths: `idea-stage/`, `refine-logs/`, `review-stage/`,
`paper/`, and `research-wiki/`.

When creating or refreshing Markdown project artifacts, prefer these paths:

```text
docs/project/PROJECT_BRIEF.md
docs/project/NEXT_ACTIONS.md
docs/project/RESEARCH_BLUEPRINT.md
docs/project/BLUEPRINT_GATE.md
docs/project/PROJECT_GUIDE.md
docs/experiments/EXPERIMENT_PLAN.md
docs/experiments/EXPERIMENT_PROTOCOL.md
docs/experiments/EXPERIMENT_LOG.md
docs/evidence/findings.md
docs/evidence/EVIDENCE_LEDGER.md
docs/paper/NARRATIVE_REPORT.md
docs/paper/PAPER_GUIDE.md
docs/theory/DERIVATION_PACKAGE.md
docs/theory/PROOF_PACKAGE.md
```

Read legacy root-level files as fallback in older projects, but do not write new
or refreshed Markdown to the root unless it is on the allowlist.

## Source Code Rules

- Put reusable models, algorithms, data loaders, metrics, stores, evaluators, and domain APIs in `src/<package_name>/`.
- Keep `scripts/` thin. A script should parse CLI args, load config, call package functions, and write outputs.
- Use package submodules by responsibility, not by experiment number, unless the code is truly experiment-specific.
- Export stable public objects from `__init__.py` only when they are intended for reuse.
- Put tests beside the package modules when the repo follows SpectralStore's lightweight style, or under `tests/` if the existing repo already uses that convention.

## Experiment Flow

Use this flow for reproducible research:

```text
raw data or synthetic generator
  -> data loader / preprocessing
  -> reusable algorithm or model
  -> experiment runner
  -> experiments/runs/<suite>/<run-id>/
  -> curated experiments/results/
  -> scripts/analysis/
  -> experiments/visualizations/
```

Each experiment runner should accept:

- `--config <path>` for YAML config.
- `--out-dir <path>` for output routing.
- Optional `--set key=value` overrides if the project needs CLI overrides.

Each run output bundle should prefer:

- `metrics.json` for machine-readable metrics.
- `summary.md` for human-readable notes.
- `resolved_config.yaml` for the effective config.
- `run_metadata.json` for command, timestamp, platform, package versions, and Git commit when available.

## Config And Suite Rules

- `experiments/configs/` contains hand-written logical experiment configs.
- Generated machine-specific configs may live in ignored directories such as `experiments/configs_cpu/` or `experiments/configs_gpu/`.
- `experiments/suites/current_repro.yaml` is the main reproducibility index.
- Suite tasks should have stable `id`, `script`, `config`, `output_subdir`, `tags`, and `enabled` fields.
- Tags should encode experiment id, workload, dataset, machine, and external dependencies, for example `exp3`, `real`, `machine:gpu`, or `needs:neo4j`.

## Data And Artifact Policy

- Keep `data/raw/`, `data/interim/`, and `data/processed/` as staging areas.
- Track `.gitkeep` and documentation, not large data files.
- Ignore generated run outputs by default.
- Treat `experiments/results/` as curated. Do not point ordinary runners there by default.
- Track paper-facing PDFs and small summary CSVs only when intentionally curated.
- If project-local skills are installed, ignore `.debuffer_skills/traces/`, `.debuffer_skills/cache/`, `.debuffer_skills/runs/`, `.debuffer_skills/meta/events.jsonl`, and project-local `.agents/skills/` symlinks by default.

## README Contract

The root `README.md` should be reviewer-facing and concise:

- What the project does.
- Python/runtime requirements.
- Installation commands.
- Import and test smoke checks.
- How to obtain or preprocess data.
- How to run a tiny local experiment.
- How to run the reproducible suite or representative tasks.
- Repository layout.

Put internal operational detail in `docs/`, not in the root README.

## Root Markdown Cleanup

During migration, inventory root `*.md` files. Keep only the allowlist in root,
then move the rest into the nearest `docs/` category:

- project framing and status companions -> `docs/project/`
- experiment plans, logs, trackers, run notes -> `docs/experiments/`
- findings, claim maps, evidence ledgers -> `docs/evidence/`
- paper outlines, narrative reports, writing plans -> `docs/paper/`
- theory notes, proof packages, derivation packages -> `docs/theory/`
- setup notes, AutoDL/HPC instructions, maintenance notes -> `docs/runbooks/`
- obsolete notes -> `docs/archive/`

Preserve backlinks or add a short index in `docs/README.md` only if the project
already uses docs indexing. Otherwise keep categories discoverable by path.
