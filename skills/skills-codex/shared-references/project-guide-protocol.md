# Project Guide Protocol

Use this protocol to keep a research project navigable without generating a
large Markdown bundle on every turn. It abstracts the useful writing pattern of
a full project guidance document: problem framing, method stages, datasets,
baselines, experiment protocols, implementation plan, and reproducibility.

## Default Artifacts

Maintain these compact files whenever the project is active:

- `PROJECT_STATUS.md`: current macro phase, startup mode, target venue, last
  accepted artifact, next gate, blockers, and a one-line phase map with a
  current-position marker.
- `PROJECT_BRIEF.md`: stable problem framing, assumptions, method sketch, and
  venue constraints.
- `NEXT_ACTIONS.md`: the next 3-7 concrete actions, with owner/context and the
  gate they unblock.

Create larger guide documents only at stage gates:

- `RESEARCH_BLUEPRINT.md`: create or substantially refresh when the project is
  ready to move into formal experiment planning, AutoDL/HPC formal runs, or
  paper planning and needs a rigorous whole-project design.
- `BLUEPRINT_GATE.md`: create with `RESEARCH_BLUEPRINT.md`; record
  PASS / CONDITIONAL / BLOCKED for the next allowed stage.
- `PROJECT_GUIDE.md`: create or substantially refresh when the project has a
  stable idea/method and needs a lighter coherent project guide. If
  `RESEARCH_BLUEPRINT.md` exists, treat it as the stricter source and avoid
  duplicating a second long whole-project guide.
- `EXPERIMENT_PROTOCOL.md`: create before implementation or formal runs, and
  freeze before AutoDL/HPC formal execution.
- `EVIDENCE_LEDGER.md`: create after results exist, mapping claims to raw run
  folders, metrics, figures, tables, and unresolved evidence gaps.
- `PAPER_GUIDE.md`: create before manuscript writing, usually by compacting
  `RESEARCH_BLUEPRINT.md` or `PROJECT_GUIDE.md`, `EXPERIMENT_PROTOCOL.md`,
  and `EVIDENCE_LEDGER.md`.

## Macro Phases

Use this phase map unless the project needs a domain-specific variant:

`direction -> idea -> method -> repo scaffold -> experiment protocol -> local smoke -> AutoDL smoke -> formal runs -> evidence audit -> paper plan -> manuscript -> submission`

`PROJECT_STATUS.md` should show the current phase explicitly, for example:

```text
Current phase: experiment protocol
Next gate: AutoDL smoke readiness
Map: direction -> idea -> method -> repo scaffold -> [experiment protocol] -> local smoke -> AutoDL smoke -> formal runs -> evidence audit -> paper plan -> manuscript -> submission
```

Update `PROJECT_STATUS.md` after every meaningful phase transition or accepted
artifact. Keep it short enough to read at the start of every session.

For the stricter AutoSci-lite state contract, read
`autosci-lite-patterns.md`. `PROJECT_STATUS.md` should include at least:
current phase, startup mode, target venue, active idea or method, last accepted
artifact, next gate, blockers, and the phase map with the current phase marked.

## RESEARCH_BLUEPRINT.md Gate

Generate or refresh `RESEARCH_BLUEPRINT.md` only at important handoffs:

- before a stable method becomes a formal experiment protocol;
- before AutoDL/HPC formal suites are prepared or approved;
- after experiments finish and before paper planning begins;
- when the user explicitly asks for a detailed research blueprint.

Do not use this artifact for routine status updates. Patch and compact an
existing `RESEARCH_BLUEPRINT.md` instead of creating another long report.

`RESEARCH_BLUEPRINT.md` must start with:

```markdown
## 0. 总体进度表
| 顺序 | 阶段 | 完成 | 当前证据 / 产物 | 下一步 |
```

Use ordered stages from data acquisition and preprocessing through task
protocol, theory/method freeze, repo/reproducibility readiness, local smoke,
AutoDL smoke, pilot, formal runs, evidence audit, paper plan, manuscript, and
submission. Mark completion with `[x]` only when there is concrete evidence or
a named artifact; use `[ ]` for intended work and `N/A` only with an evidence
note.

The document should then cover background, problem definition, core insight,
theory/proof obligations, system or algorithm details, datasets, baselines,
claim-to-evidence-to-experiment mapping, detailed experiments, AutoDL/HPC
execution, implementation/repo structure, reproducibility, paper prerequisites,
risks, and the next gate.

`BLUEPRINT_GATE.md` is the compact decision companion. It should say whether
the next allowed step is `research-refine`, `experiment-plan`, `autodl-hpc`,
`paper-plan`, or stop.

## PROJECT_GUIDE.md Gate

Generate or refresh `PROJECT_GUIDE.md` when at least one is true:

- the idea/method is stable enough that implementation choices matter;
- the project is moving from exploration into experiment planning;
- the user asks for a complete guidance document;
- a future session needs enough context to resume without rereading long notes.

Do not generate it for a vague `venue-only` start unless the user asks. In early
stages, use `PROJECT_BRIEF.md` plus `NEXT_ACTIONS.md`.

If `RESEARCH_BLUEPRINT.md` is present, keep `PROJECT_GUIDE.md` short or skip it.
The blueprint is the detailed source for formal experiment and paper gates.

Recommended `PROJECT_GUIDE.md` sections:

1. Research background and motivation.
2. Problem definition: inputs, outputs, tasks, success criteria, assumptions.
3. Method overview: system or algorithm stages and interfaces.
4. Datasets and data policy: role of each dataset, scale, access, preprocessing.
5. Baselines: grouped by what each family controls for.
6. Experiment plan overview: each experiment's role in the paper.
7. Implementation plan: repo modules, scripts, configs, outputs.
8. Reproducibility contract: seeds, configs, environment, logging, run bundles.
9. Current gaps and next gates.

## Experiment Protocol Schema

Every experiment block in `EXPERIMENT_PROTOCOL.md` or
`refine-logs/EXPERIMENT_PLAN.md` should use this schema:

- **Goal**: what claim or risk this experiment tests.
- **Dataset / split / task**: exact data source and preprocessing contract.
- **Design**: factors varied, fixed settings, number of seeds, run order.
- **Compared systems**: proposed method, strongest baselines, ablations.
- **Metrics**: primary metric, secondary metrics, system metrics if relevant.
- **Expected result / decision rule**: what result would support, weaken, or
  falsify the claim.
- **Reproducibility entrypoint**: config path, suite path, command, output dir.

Before formal AutoDL/HPC runs, add a pilot gate from
`autosci-lite-patterns.md` unless an equivalent smoke/pilot artifact already
exists. Pilot evidence checks readiness only; formal claims still require
audited runs.

Before a formal run, each block must map to versioned configs under
`experiments/configs/`, suite entries under `experiments/suites/`, and raw
outputs under `experiments/runs/`.

## Reproducibility Contract

For each accepted experiment or formal run, capture:

- exact Git commit and dirty-status note;
- config file and resolved config snapshot;
- random seeds and hardware target;
- Python/package environment or container notes;
- data manifest entries for any data not tracked in Git;
- command line, suite name, and output directory;
- `metrics.json`, `summary.md`, `run_metadata.json`, and logs where possible.

AutoDL/HPC work must preserve the same contract and additionally follow the
AutoDL runbook: preflight, dry-run, smoke, explicit formal approval, raw result
download, and local audit before claims are updated.

## Compaction Rule

When long notes accumulate, merge stable information into the smallest durable
artifact:

- stable framing -> `PROJECT_BRIEF.md`;
- current phase and blockers -> `PROJECT_STATUS.md`;
- detailed stage-gate design -> `RESEARCH_BLUEPRINT.md` plus
  `BLUEPRINT_GATE.md`;
- experiment facts -> `EXPERIMENT_PROTOCOL.md` or `EXPERIMENT_LOG.md`;
- result-to-claim mapping -> `EVIDENCE_LEDGER.md` or `findings.md`;
- manuscript decisions -> `PAPER_GUIDE.md`.

Do not append another long report when an existing guide can be updated.
