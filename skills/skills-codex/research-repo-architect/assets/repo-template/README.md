# {{project_title}}

{{project_title}} contains reusable research code, experiment entrypoints, configs, and reproducible outputs for {{project_slug}}.

## Requirements

- Python 3.10 or newer.
- pip and a standard virtual environment.

## Installation

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -e ".[dev,experiments]"
```

## Quick Start

Verify the package imports:

```powershell
python -c "import {{package_name}}; print('{{package_name}} import ok')"
```

Run tests:

```powershell
python -m pytest
```

Run a tiny local experiment:

```powershell
python scripts/exp1/run_example.py `
  --config experiments/configs/exp1/example.yaml `
  --out-dir experiments/runs/local_checks/exp1_example
```

Generate example visualizations:

```powershell
python scripts/analysis/plot_example.py `
  --input experiments/runs/local_checks/exp1_example/metrics.json `
  --out-dir experiments/visualizations/exp1
```

## Repository Layout

```text
data/                 Dataset staging area and dataset notes.
docs/                 Internal runbooks and maintenance notes.
experiments/          Configs, suites, raw runs, curated results, and figures.
scripts/              Data, experiment, analysis, diagnostics, and HPC entrypoints.
src/{{package_name}}/ Reusable package source code.
```

If this project is operated with ARIS, project-local runtime state lives under `.aris/` and `.agents/skills/`. Those directories are ignored by default. Persistent research memory, if enabled, lives under `research-wiki/`.

## Data

Dataset files are expected under `data/`. Raw and derived artifacts are ignored by Git by default. Keep provenance and preprocessing instructions in `data/README.md`.

## Experiments

Hand-written experiment configs live under `experiments/configs/`. Reproducible suite definitions live under `experiments/suites/`. New run outputs should be written under `experiments/runs/`. Move only curated outputs into `experiments/results/` or `experiments/visualizations/`.
