---
name: research-blueprint
description: Create or refresh a detailed stage-gate research blueprint before formal experiment planning, AutoDL formal runs, or paper planning. Use when Codex needs a project-specific `RESEARCH_BLUEPRINT.md` with rigorous theory, method, dataset, baseline, experiment, implementation, reproducibility, writing plans, and a sequential macro progress table; when the user asks for a complete research design document, project guide, pre-experiment blueprint, pre-paper blueprint, or wants to know whether the project is ready to run experiments or write the paper.
---

# Research Blueprint

Create a detailed, carefully reasoned research design document for:
**$ARGUMENTS**

This skill produces a stage-gate artifact. It should be detailed enough that a
future session can implement experiments or plan the paper without rereading all
notes, but it should not be regenerated on every turn.

## Outputs

Write or refresh:

- `RESEARCH_BLUEPRINT.md` — canonical whole-project research blueprint.
- `BLUEPRINT_GATE.md` — concise pass/fail gate for moving into
  `experiment-plan`, AutoDL formal runs, or `paper-plan`.
- `PROJECT_STATUS.md` — update current phase, last accepted artifact, next
  gate, blockers, and phase map.
- `NEXT_ACTIONS.md` — only the next 3-7 concrete actions.

The canonical long blueprint path is `RESEARCH_BLUEPRINT.md`.

## When To Create Or Refresh

Create or substantially refresh `RESEARCH_BLUEPRINT.md` when at least one is
true:

- the method is stable enough that experiment design choices now matter;
- the project is moving from method refinement into experiment protocol;
- the project is about to launch formal AutoDL/HPC runs;
- the project has completed experiments and is moving into paper planning;
- the user explicitly asks for a complete guidance/blueprint document.

Otherwise update only compact project memory (`PROJECT_BRIEF.md`,
`PROJECT_STATUS.md`, `NEXT_ACTIONS.md`, `findings.md`,
`EXPERIMENT_LOG.md`). If a prior `RESEARCH_BLUEPRINT.md` exists, patch and
compact it instead of appending another long report.

## Inputs To Inspect

Read the most relevant available files first:

- `PROJECT_STATUS.md`, `PROJECT_BRIEF.md`, `NEXT_ACTIONS.md`
- `refine-logs/FINAL_PROPOSAL.md`, `refine-logs/REFINEMENT_REPORT.md`,
  `refine-logs/EXPERIMENT_PLAN.md`
- `EXPERIMENT_PROTOCOL.md`, `EVIDENCE_LEDGER.md`, `findings.md`,
  `EXPERIMENT_LOG.md`, `CLAIMS_FROM_RESULTS.md`
- `idea-stage/IDEA_REPORT.md`, `idea-stage/IDEA_MEMORY.md`
- `experiments/NEGATIVE_RESULTS.md`
- `docs/runbooks/AUTODL_HPC_RUNBOOK.md`, `data/DATA_MANIFEST.md`
- paper sources or outline files when paper planning is already underway.

If information is absent, mark it as a gap. Do not invent citations, results,
datasets, theorem statements, or implementation details.

Read `../shared-references/project-guide-protocol.md`,
`../shared-references/autosci-lite-patterns.md`, and
`../shared-references/venue-profiles.md` when available.

## Blueprint Standard

The blueprint must be detailed, not decorative. It must answer:

- What exact problem is being solved?
- Why is the problem technically important and not already solved?
- What is the core insight or mechanism?
- What assumptions, theory, proofs, or mechanism arguments support it?
- What experiments prove or falsify each claim?
- What baselines isolate each variable?
- What data, preprocessing, configs, seeds, hardware, and logging make the
  results reproducible?
- What runs must happen locally, and what must be prepared for AutoDL/HPC?
- What evidence is still missing before writing the paper?

Prefer explicit tables, claim maps, and decision rules over broad prose.

## Required RESEARCH_BLUEPRINT.md Structure

`RESEARCH_BLUEPRINT.md` must start with this section before any background
text:

```markdown
# Research Blueprint: <project title>

## 0. 总体进度表

| 顺序 | 阶段 | 完成 | 当前证据 / 产物 | 下一步 |
|---:|---|:---:|---|---|
| 1 | 数据获取与许可确认 | [ ] |  |  |
| 2 | 数据清洗与预处理 | [ ] |  |  |
| 3 | 任务定义与评测协议冻结 | [ ] |  |  |
| 4 | 理论假设与核心机制冻结 | [ ] |  |  |
| 5 | 仓库结构与可复现入口就绪 | [ ] |  |  |
| 6 | 本地 tiny smoke / 单元测试通过 | [ ] |  |  |
| 7 | AutoDL/HPC preflight 通过 | [ ] |  |  |
| 8 | Pilot gate 通过 | [ ] |  |  |
| 9 | Baseline 正式实验完成 | [ ] |  |  |
| 10 | 主方法正式实验完成 | [ ] |  |  |
| 11 | 消融 / 鲁棒性 / 扩展性实验完成 | [ ] |  |  |
| 12 | 结果审计与 claim-evidence 映射完成 | [ ] |  |  |
| 13 | 论文大纲与图表计划冻结 | [ ] |  |  |
| 14 | 论文初稿完成 | [ ] |  |  |
| 15 | 论文 claim / citation / proof 审计通过 | [ ] |  |  |
| 16 | 投稿材料准备完成 | [ ] |  |  |
```

Use `[x]` only when there is concrete local evidence or a named artifact. Use
`[ ]` for missing or merely intended work. If a stage is not applicable, mark
`N/A` and explain in the evidence cell.

Then include the following sections:

```markdown
## 1. 研究背景与动机
## 2. 问题定义与边界
## 3. 核心洞察与方法总览
## 4. 理论基础与待证明命题
## 5. 系统 / 算法设计细节
## 6. 数据集与数据处理计划
## 7. Baseline 与对照组设计
## 8. Claim -> Evidence -> Experiment Map
## 9. 详细实验安排
## 10. AutoDL/HPC 执行计划
## 11. 实现计划与仓库结构
## 12. 可复现性协议
## 13. 论文写作前置条件
## 14. 风险、反例与失败解释
## 15. 当前缺口与下一道 gate
```

### Section Requirements

- **Background**: explain the field gap, why naive fixes are insufficient, and
  why this project's insight is plausible.
- **Problem definition**: formalize input, output, target tasks, assumptions,
  non-goals, and success criteria.
- **Theory**: list assumptions, variables, propositions/theorems if known,
  proof obligations, approximation arguments, complexity, and what experiments
  will validate if theory is incomplete.
- **Method**: specify modules, interfaces, training/inference paths,
  hyperparameters to freeze, and what is deliberately excluded.
- **Datasets**: separate synthetic, small real, large real, and optional
  datasets. State each dataset's role, scale, preprocessing, split, access, and
  failure risk.
- **Baselines**: group by baseline family and state what each family controls
  for. Avoid padding with weak baselines.
- **Claim map**: every paper-level claim must map to a theoretical argument,
  experiment block, expected result, and failure interpretation.
- **Experiment plan**: include design, metrics, seeds, run order, decision
  rule, expected artifact path, and paper table/figure target for every block.
- **AutoDL/HPC**: separate local checks, remote preflight, smoke, pilot, formal
  suite, result transfer, and local audit.
- **Reproducibility**: require commit hash, dirty status, configs, resolved
  configs, seeds, environment, data manifest, run metadata, logs, metrics, and
  raw output folders.
- **Paper readiness**: define what evidence is needed before `paper-plan`.

## BLUEPRINT_GATE.md

Write a compact gate document:

```markdown
# Blueprint Gate

**Date**:
**Target venue**:
**Current phase**:
**Decision**: PASS / CONDITIONAL / BLOCKED

## Gate Checks
| Check | Status | Evidence | Required Fix |
|---|---|---|---|
| Problem and non-goals are stable | PASS/WARN/BLOCK |  |  |
| Theory/mechanism basis is explicit | PASS/WARN/BLOCK |  |  |
| Method is implementable | PASS/WARN/BLOCK |  |  |
| Claim map is complete | PASS/WARN/BLOCK |  |  |
| Datasets and preprocessing are specified | PASS/WARN/BLOCK |  |  |
| Baselines are sufficient and grouped | PASS/WARN/BLOCK |  |  |
| Experiments are claim-driven | PASS/WARN/BLOCK |  |  |
| Pilot gate is defined before formal runs | PASS/WARN/BLOCK |  |  |
| Reproducibility contract is defined | PASS/WARN/BLOCK |  |  |
| Paper readiness gaps are explicit | PASS/WARN/BLOCK |  |  |

## Blocking Gaps
- ...

## Allowed Next Step
- `research-refine` / `experiment-plan` / `autodl-hpc` / `paper-plan` / stop
```

Decision rules:

- **PASS**: no `BLOCK`, and warnings do not change experiment validity.
- **CONDITIONAL**: no catastrophic flaw, but one or more fixes must happen
  before formal AutoDL runs or paper writing.
- **BLOCKED**: the project lacks a stable problem, implementable method,
  claim map, data protocol, or reproducibility contract.

## Project Status Update

Update `PROJECT_STATUS.md` with:

- current phase;
- startup mode;
- target venue;
- active idea or method;
- last accepted artifact: `RESEARCH_BLUEPRINT.md` or prior artifact;
- next gate from `BLUEPRINT_GATE.md`;
- blockers;
- phase map with current phase marked.

Use the macro map from `project-guide-protocol.md`:

`direction -> idea -> method -> repo scaffold -> experiment protocol -> local smoke -> AutoDL smoke -> formal runs -> evidence audit -> paper plan -> manuscript -> submission`

## Key Rules

- Be detailed where decisions matter; be concise where the information is
  stable and already available elsewhere.
- Do not generate a large document for a vague direction unless the user asks.
- Do not claim readiness without evidence paths.
- Do not treat pilot, smoke, or toy runs as paper evidence.
- Do not run heavy experiments locally. Prepare commands, configs, and gates.
- Do not fabricate citations, theorem guarantees, dataset properties, or
  metrics.
- Prefer updating an existing `RESEARCH_BLUEPRINT.md` over creating a new long
  file.

## Handoff

If the gate decision allows experiments, the next skill is usually
`experiment-plan`, which should read `RESEARCH_BLUEPRINT.md` first.

If results already exist and the project is moving to writing, the next skill is
usually `paper-plan`, which should read `RESEARCH_BLUEPRINT.md`,
`EXPERIMENT_PROTOCOL.md`, and `EVIDENCE_LEDGER.md`.
