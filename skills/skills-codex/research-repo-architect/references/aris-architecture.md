# ARIS Repository Architecture

Use this reference when the target repo is an ARIS framework repo, an ARIS skills bundle, or a research project already operated by ARIS workflows.

## Repository Modes

### ARIS framework repository

Signals: `AGENT_GUIDE.md`, `skills/<name>/SKILL.md`, `skills/skills-codex/`, `skills/shared-references/`, `tools/install_aris*.sh`, `mcp-servers/`, or inventory tests.

Contract:

```text
skills/<name>/SKILL.md                 Mainline skill behavior.
skills/<name>/scripts/                 Single-owner helper scripts.
skills/<name>/templates|assets/        Skill-owned resources.
skills/shared-references/              Cross-skill contracts and protocols.
skills/skills-codex/<name>/SKILL.md    Codex-native mirror of mainline skills.
skills/skills-codex/shared-references/ Codex mirror of shared contracts.
skills/skills-codex-*-review/          Optional reviewer-routing overlays only.
tools/                                 Shared helpers and installer/update scripts.
templates/                             User-facing research artifact templates.
docs/                                  Human docs, catalogs, setup guides, examples.
tests/                                 Inventory, installer, helper, and integration tests.
mcp-servers/                           Optional reviewer/integration bridges.
assets/                                Repo-level README/docs media.
```

Do not force this repo into a normal `src/` package layout unless the user is adding reusable application/library code. The `skills/` tree is the product.

### ARIS-managed research project

Signals: `.aris/`, `.agents/skills/`, `research-wiki/`, `idea-stage/`, `refine-logs/`, `review-stage/`, `paper/`, `EXPERIMENT_PLAN.md`, or `NARRATIVE_REPORT.md`.

Combine ARIS workflow artifacts with the SpectralStore experiment layout:

```text
src/<package_name>/              Reusable research implementation.
scripts/                         Thin data, experiment, analysis, HPC entrypoints.
experiments/configs/             Hand-written experiment intent.
experiments/suites/              Reproducible task collections.
experiments/runs/                Raw run provenance and logs.
experiments/results/             Curated result tables/artifacts.
experiments/visualizations/      Paper-facing figures.
research-wiki/                   Persistent papers/ideas/experiments/claims memory.
idea-stage/, refine-logs/        ARIS planning and experiment handoff state.
review-stage/                    ARIS review loop outputs.
paper/                           LaTeX submission workspace and audits.
.aris/                           Runtime state, traces, caches, install manifests.
.agents/skills/                  Codex project-local skill symlinks.
```

Do not move `research-wiki/`, `idea-stage/`, `refine-logs/`, or `paper/` into `docs/` just because they are Markdown-heavy. Downstream ARIS skills expect these paths.

## Adding An ARIS Skill

When adding a new skill to an ARIS framework repo:

1. Create `skills/<name>/SKILL.md` with clear `name` and `description` frontmatter.
2. Add resources only when they are needed:
   - `scripts/` for deterministic single-owner helpers.
   - `references/` for longer instructions loaded on demand.
   - `assets/` or `templates/` for output resources.
3. Add `skills/skills-codex/<name>/SKILL.md`. Preserve mainline semantics; adapt only tool routing, path assumptions, and reviewer protocol.
4. Add or update overlays only when the overlay truly changes reviewer routing. Do not duplicate overlays for every skill by default.
5. Add the skill to `docs/SKILLS_CATALOG.md`.
6. Update count-bearing docs/tests if the repo enforces inventory counts.
7. Run the inventory check and mirror tests.

For Codex mirrors:

- Use `spawn_agent` and `send_input` where the mainline skill used reviewer MCP continuation.
- Do not leave `mcp__codex__codex`, `codex-reply`, `threadId`, or Claude-only paths in Codex skills unless the repo's tests explicitly allow that skill.
- Resolve ARIS helpers from the installed ARIS repo manifest, `.aris/tools`, `tools`, or `$ARIS_REPO`; do not assume helper scripts live in the user's project root.

## Shared References And Helpers

Use `skills/shared-references/` for contracts that multiple skills must obey, such as reviewer independence, citation discipline, experiment integrity, output manifests, helper resolution, and trace schemas.

Use `tools/` for shared executable helpers. A skill that invokes a shared helper must use the resolver chain from `integration-contract.md`:

```text
owner layer 0: $CLAUDE_SKILL_DIR/scripts/<helper>      # owner skill only
layer 1:       .aris/tools/<helper>                    # installed project symlink
layer 2:       tools/<helper>                          # running inside ARIS repo
layer 3:       $ARIS_REPO/tools/<helper>               # explicit/global fallback
```

Choose a failure policy before writing the caller:

- A: load-bearing gate, unresolved helper blocks.
- B: optional side effect, unresolved helper warns and skips.
- C: forensic trace, unresolved helper writes the artifact directly.
- D1: first-success source cascade.
- D2: multi-source aggregate.
- E: diagnostic report, non-zero exit is captured but not propagated.

If the same helper is used by one skill only, prefer `skills/<owner>/scripts/<helper>` and keep a legacy `tools/` shim only when existing installs or docs depend on it.

## Review And Audit Artifacts

Reviewer-class skills must preserve independence:

- Pass file paths and raw artifacts to the reviewer, not executor summaries.
- Use fresh reviewer threads unless the skill explicitly continues the same review.
- Save traces under `.aris/traces/<skill>/<date>_runNN/`.
- Append compact events to `.aris/meta/events.jsonl` when the repo uses meta optimization.

Do not commit `.aris/traces/` by default. Audit artifacts may reference trace paths; they should not paste entire reviewer transcripts into human-facing reports unless the skill contract requires it.

## Experiment Integrity Overlay

ARIS experiment repos still follow the normal experiment layout, but the repo architecture must make integrity auditable:

- Every run bundle should include `metrics.json`, `summary.md`, `resolved_config.yaml`, and `run_metadata.json`.
- Evaluation type must be explicit when results are summarized: `real_gt`, `synthetic_proxy`, `self_supervised_proxy`, `simulation_only`, or `human_eval`.
- Claimed numbers must trace to files, not terminal memory.
- Large multi-seed or phased runs should use a manifest and queue state rather than ad hoc screen names.

## Gitignore Rules

In ARIS-managed projects, ignore runtime and generated state by default:

```gitignore
.aris/traces/
.aris/cache/
.aris/runs/
.aris/meta/events.jsonl
.aris/*.lock.d/
.agents/skills/
experiments/runs/*
data/raw/*
data/interim/*
data/processed/*
wandb/
mlruns/
checkpoints/
```

Do not blindly ignore `research-wiki/`, `EXPERIMENT_PLAN.md`, `NARRATIVE_REPORT.md`, or curated paper/audit artifacts; these are often intentional project memory and handoff files.

## Validation Checklist

For an ARIS framework repo:

```powershell
python tools/check_skills_inventory.py
python -m pytest tests/test_codex_skill_mirror.py
python -m pytest tests/test_codex_install_update.py tests/test_install_aris_tools_symlink.py
```

For an ARIS-managed research project:

```powershell
python -m pip install -e ".[dev]"
python -m pytest
python scripts/exp1/run_example.py --config experiments/configs/exp1/example.yaml --out-dir experiments/runs/local_checks/exp1_example
```

Adjust commands to the repo's actual test runner, but keep the distinction: ARIS framework validation checks skill inventory and mirrors; research project validation checks package imports, tests, and tiny experiment runs.
