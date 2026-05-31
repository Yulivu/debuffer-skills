# SpectralStore-Style Research Repo Architecture

This reference covers ordinary research code repositories. If the repo contains ARIS skill infrastructure such as `skills/<name>/SKILL.md`, `skills/skills-codex/`, `skills/shared-references/`, `tools/install_aris*.sh`, `.aris/`, `research-wiki/`, `idea-stage/`, or `refine-logs/`, also read `aris-architecture.md` before moving files.

## Directory Contract

```text
data/                    Dataset staging area; large artifacts ignored.
docs/                    Internal runbooks, analysis notes, and maintenance docs.
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

ARIS workflow artifacts may coexist at the repo root and should not be automatically moved into `docs/` or `experiments/`: `RESEARCH_BRIEF.md`, `EXPERIMENT_PLAN.md`, `NARRATIVE_REPORT.md`, `idea-stage/`, `refine-logs/`, `review-stage/`, `paper/`, and `research-wiki/`.

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
- If ARIS is installed, ignore `.aris/traces/`, `.aris/cache/`, `.aris/runs/`, `.aris/meta/events.jsonl`, and project-local `.agents/skills/` symlinks by default.

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
