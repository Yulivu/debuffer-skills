---
name: research-blueprint
description: Create or refresh a detailed, PDF-level executable research plan after an idea is selected and frozen. Use when Codex needs a project-specific `RESEARCH_BLUEPRINT.md` with positioning corrections, formal model layers, theory, capability matrix, datasets, baselines, claim-driven experiments, numeric gates, pivots, timeline, implementation, reproducibility, risks, and paper packaging. This skill is not manuscript drafting.
---

# Research Blueprint

## Capability Routing

This is a first-layer entry skill. Keep it loaded as the user-facing route; when a request needs a specialized capability below, resolve the debuffer repo root from `.debuffer_skills/installed-skills-codex.txt` (`repo_root`) when available, read the referenced library `SKILL.md`, then follow that skill. Do not copy the whole library skill into this file.

- `/formula-derivation`: read `../../skills-codex-library/idea-method/formula-derivation/SKILL.md`.
- `/ablation-planner`: read `../../skills-codex-library/idea-method/ablation-planner/SKILL.md`.
- `/research-refine`: read `../../skills-codex-library/idea-method/research-refine/SKILL.md`.
- `/paper-plan`: read `../../skills-codex-library/paper/paper-plan/SKILL.md`.


Create a detailed, carefully reasoned research design document for:
**$ARGUMENTS**

This skill produces the **Executable Research Plan**. It is the detailed,
stage-gated artifact that follows Idea Freeze and corresponds to the kind of
research plan represented by a strong reference PDF: not a paper draft, not a
candidate list, and not only an experiment checklist.

The plan must be detailed enough that a future session can implement the method,
challenge its claims, run the first de-risking experiments, and package the
eventual paper without rereading all notes. It should not be regenerated on
every status update.

## PDF-Compatible Output Contract

For a selected idea, produce the following argument chain:

```text
one-sentence thesis
  -> problem and positioning
  -> corrections to the raw idea
  -> formal model / method layers
  -> theory and proof obligations
  -> exactness and approximation boundaries
  -> capability matrix against relevant baselines
  -> task and query protocol
  -> claim-driven experiments and metrics
  -> numeric decision gates and predeclared pivots
  -> week-by-week execution roadmap
  -> code modules, compute, risk register, paper package, appendices
```

The reference document is structural guidance only. Never copy its prose,
claims, equations, datasets, or numerical gates. Replace every project-specific
item with evidence from the selected idea and local/retrieved sources.

## Outputs

Write or refresh:

- `docs/project/RESEARCH_BLUEPRINT.md` — canonical whole-project research blueprint.
- `docs/project/BLUEPRINT_GATE.md` — concise pass/fail gate for moving into
  `experiment-plan`, AutoDL formal runs, `experiment-audit`, or
  evidence-audited `paper-plan`. It must never route directly to
  `paper-writing`.
- `PROJECT_STATUS.md` — update current phase, last accepted artifact, next
  gate, blockers, and phase map.
- `docs/project/NEXT_ACTIONS.md` — only the next 3-7 concrete actions.

The canonical long blueprint path is `docs/project/RESEARCH_BLUEPRINT.md`.

## When To Create Or Refresh

Create or substantially refresh `docs/project/RESEARCH_BLUEPRINT.md` when at
least one is true:

- the method is stable enough that experiment design choices now matter;
- the project is moving from method refinement into experiment protocol;
- the project is about to launch formal AutoDL/HPC runs;
- the project has completed experiments and is moving into paper planning;
- the user explicitly asks for a complete guidance/blueprint document.

Otherwise update only compact project memory (`docs/project/PROJECT_BRIEF.md`,
`PROJECT_STATUS.md`, `docs/project/NEXT_ACTIONS.md`,
`docs/evidence/findings.md`, `docs/experiments/EXPERIMENT_LOG.md`). If a prior
`docs/project/RESEARCH_BLUEPRINT.md` exists, patch and compact it instead of
appending another long report.

## Inputs To Inspect

Read the most relevant available files first:

- `PROJECT_STATUS.md`, `docs/project/PROJECT_BRIEF.md`,
  `docs/project/NEXT_ACTIONS.md` (fall back to legacy root files if needed)
- `refine-logs/FINAL_PROPOSAL.md`, `refine-logs/REFINEMENT_REPORT.md`,
  `refine-logs/EXPERIMENT_PLAN.md`
- `docs/experiments/EXPERIMENT_PROTOCOL.md`,
  `docs/evidence/EVIDENCE_LEDGER.md`, `docs/evidence/findings.md`,
  `docs/experiments/EXPERIMENT_LOG.md`, `CLAIMS_FROM_RESULTS.md`
  (fall back to legacy root files if needed)
- `idea-stage/IDEA_REPORT.md`, `idea-stage/IDEA_MEMORY.md`
- `experiments/NEGATIVE_RESULTS.md`
- `docs/runbooks/AUTODL_HPC_RUNBOOK.md`, `data/DATA_MANIFEST.md`
- paper sources or outline files only when paper planning is already underway
  after formal-run evidence audit.

If information is absent, mark it as a gap. Do not invent citations, results,
datasets, theorem statements, or implementation details.

Read `../shared-references/project-guide-protocol.md`,
`../shared-references/autosci-lite-patterns.md`, and
`../shared-references/venue-profiles.md` when available.

When the eventual paper is likely to be a systems, memory, benchmark, or
query-processing paper, shape the blueprint so it can later map cleanly into an
`ICDE_YU_Memory`-style package: thin main manuscript file, modular sections,
explicit methodology decomposition, optional benchmark-construction section,
RQ-driven experiments, and separate discussion.

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

Add one more required section near the end when paper planning is foreseeable:

```markdown
## 16. 预期论文包结构
```

`docs/project/RESEARCH_BLUEPRINT.md` must start with this section before any
background text:

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

Then include the following sections. The first 15 sections are the project and
evidence backbone; sections 16-18 make the document match a detailed research
plan rather than a generic project guide:

```markdown
## 1. 研究背景与动机
## 2. 问题定义与边界
## 2.5 Raw Idea 纠偏与已有工作定位
## 3. 核心洞察与方法总览
## 3.1 模型 / 方法层 1
## 3.2 模型 / 方法层 2
## 3.3 模型 / 方法层 3
## 3.4 推断、训练与复杂度
## 3.5 Insight 与独特性
## 4. 理论基础与待证明命题
## 5. 能力矩阵与竞品边界
## 6. 数据集、任务与查询协议
## 7. Baseline 与对照组设计
## 8. Claim -> Evidence -> Experiment Map
## 9. 详细实验安排
## 9.1 指标、金标准与评估协议
## 9.2 图表清单与论文叙事
## 10. 决策 Gate 与失败转向
## 11. 周级执行路线图
## 12. AutoDL/HPC 执行计划
## 13. 实现计划与仓库结构
## 14. 可复现性协议
## 15. 风险登记表、反例与失败解释
## 16. 论文写作前置条件与预期论文包
## 17. 当前缺口与下一道 gate
## 18. 附录：符号、关键推导、参考文献台账
```

### Section Requirements

- **Background**: explain the field gap, why naive fixes are insufficient, and
  why this project's insight is plausible.
- **Problem definition**: formalize input, output, target tasks, assumptions,
  non-goals, success criteria, and the strongest permissible conclusion.
- **Raw idea correction**: list the initial claims or intuitions, what prior
  work already occupies, what is actually novel, and how the framing changes.
  A correction is required whenever the selected idea came from a paper or raw
  brainstorming note.
- **Method layers**: describe each layer's input, output, mathematical object,
  trainable parameters, objective, interface, and reason it is needed. Keep the
  layers compositional; do not hide a second contribution inside a paragraph.
- **Inference boundary**: distinguish exact identities, numerical truncations,
  approximations, sampling fallbacks, and worst-case complexity. State the
  assumptions under which each guarantee holds.
- **Theory**: list assumptions, variables, propositions/theorems if known,
  proof obligations, approximation arguments, complexity, and what experiments
  will validate if theory is incomplete.
- **Capability matrix**: compare the selected method with strong relevant
  baselines on the capabilities that motivate the work, such as likelihood,
  multimodality, arbitrary queries, conditioning, calibration, consistency,
  evidence, and guarantees. Use `unknown` when evidence is missing.
- **Datasets**: separate synthetic, small real, large real, and optional
  datasets. State each dataset's role, scale, preprocessing, split, access, and
  failure risk.
- **Baselines**: group by baseline family and state what each family controls
  for. Avoid padding with weak baselines.
- **Claim map**: every paper-level claim must map to a theoretical argument,
  experiment block, expected result, and failure interpretation.
- **Experiment plan**: include design, metrics, seeds, run order, decision
  rule, expected artifact path, and paper table/figure target for every block.
- **Metrics and gold standard**: define proper scores first, then diagnostics,
  calibration, mode coverage, efficiency, and task-specific measures. State
  how a gold-standard posterior or oracle is obtained when one exists.
- **Decision gates**: every central assumption needs a predeclared numeric or
  mechanically checkable gate, a time point, and a failure pivot. Never loosen a
  gate after seeing the result.
- **Timeline**: give a sequential week-level or milestone-level route from the
  first de-risking test through paper packaging, with deliverables and gates.
- **Risk register**: for each risk record signal, mitigation, fallback,
  consequence for the paper, and the claim that must be downgraded.
- **Paper package**: map planned figures, tables, theorem statements, appendix
  material, rebuttal questions, and venue alternatives to the claims they serve.
- **AutoDL/HPC**: separate local checks, remote preflight, smoke, pilot, formal
  suite, result transfer, and local audit.
- **Reproducibility**: require commit hash, dirty status, configs, resolved
  configs, seeds, environment, data manifest, run metadata, logs, metrics, and
  raw output folders.
- **Paper readiness**: define what formal-run evidence and audit artifacts are
  needed before `paper-plan`; do not treat validation-only work as paper
  readiness.

## Required Tables

The plan must contain these tables, even when some cells are marked `TBD`:

1. **Positioning table**: closest work, what it solves, what it does not solve,
   and the exact differentiation.
2. **Capability matrix**: capability rows, baseline columns, evidence status,
   and caveats.
3. **Claim map**: claim, support type, experiment, metric, expected result,
   falsifier, artifact path.
4. **Task / dataset / query table**: task, available input, target output,
   gold standard, split, and failure risk.
5. **Gate table**: gate ID, assumption, deadline, pass rule, evidence artifact,
   and pivot.
6. **Milestone table**: ordered week or milestone, work, deliverable, compute,
   and decision.
7. **Risk register**: risk, signal, mitigation, fallback, and claim impact.

## Detail Standard

For a technically ambitious idea, the finished plan should normally include:

- a one-sentence summary and a 2-3 paragraph executive summary;
- 3-6 explicit contributions or claims, with one dominant contribution;
- 2-4 method layers and their interfaces;
- 2-4 theory items or proof obligations, clearly labeled as theorem,
  proposition, conjecture, or empirical check;
- 3-6 task/query blocks and grouped baselines;
- 3-5 core experiment blocks plus appendix experiments;
- 3-5 predeclared gates with numeric or mechanical pass rules;
- a 10-20 week execution route, adjusted to the actual budget;
- a code module plan, compute estimate, risk register, and paper figure/table
  inventory.

Shorter plans are valid for genuinely small ideas, but omitting these categories
because they are inconvenient is not a valid compression strategy.

## Generation Procedure

When the input is a selected candidate, read `refine-logs/FINAL_PROPOSAL.md`
first. If it is absent, create or request an Idea Freeze before writing a
high-confidence blueprint. A speculative blueprint is allowed only when the
user explicitly requests it; label every unverified item as `hypothesis`,
`needs_evidence`, or `TBD`.

Build the document in this order:

1. Write the one-sentence thesis and executive summary.
2. Build the positioning table from the closest papers and methods.
3. Write a raw-idea correction table:
   `initial belief -> evidence -> correction -> consequence for the plan`.
4. Define the problem, non-goals, tasks, observations, outputs, and success
   criteria.
5. Decompose the method into 2-4 layers. For every layer specify interfaces,
   equations or algorithms when justified, parameters, training/estimation,
   inference, complexity, and failure boundary.
6. List theory claims and proof obligations. Separate proven statements from
   conjectures and empirical mechanism checks.
7. Fill the capability matrix and state why each baseline is included.
8. Define datasets and query protocols before selecting metrics. Add synthetic
   controls for the central mechanism whenever possible.
9. Build the claim map, then derive only the necessary experiment blocks.
10. Set numeric or mechanical gates before writing the timeline. Each failed
    gate must have a predeclared downgrade, pivot, or stop decision.
11. Write the week-by-week route, code modules, resource budget, risk register,
    and paper package.
12. Finish with current gaps and the single next gate. Do not mark an intended
    stage complete without an evidence path.

The plan should read as a coherent argument. Every later section must answer a
question raised earlier; do not append disconnected benchmark or feature lists.

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
| Formal runs are complete for paper-level claims | PASS/WARN/BLOCK |  |  |
| Evidence audit / claim ledger is complete | PASS/WARN/BLOCK |  |  |
| Reproducibility contract is defined | PASS/WARN/BLOCK |  |  |
| Paper readiness gaps are explicit | PASS/WARN/BLOCK |  |  |

## Blocking Gaps
- ...

## Allowed Next Step
- `research-refine` / `experiment-plan` / `autodl-hpc` /
  `experiment-audit` / `paper-plan` / stop
```

Decision rules:

- **PASS**: no `BLOCK`, and warnings do not change the validity of the
  selected next stage.
- **CONDITIONAL**: no catastrophic flaw, but one or more fixes must happen
  before formal AutoDL runs or the next paper-readiness gate.
- **BLOCKED**: the project lacks a stable problem, implementable method,
  claim map, data protocol, or reproducibility contract.
- If formal baseline/main/required ablation runs are absent or only
  local-smoke, AutoDL-smoke, pilot, toy, or validation runs exist, the allowed
  next step must be `experiment-plan`, `autodl-hpc`, or stop. It must not be
  `paper-plan` or `paper-writing`.
- If formal runs exist but raw evidence, run metadata, result transfer, or
  `docs/evidence/EVIDENCE_LEDGER.md` / `CLAIMS_FROM_RESULTS.md` is missing, the
  allowed next step must be `experiment-audit` or evidence-ledger completion.
- `paper-plan` is allowed only after formal runs for paper-level claims exist
  and a claim-to-evidence audit maps claims to raw evidence. `paper-writing` is
  never an allowed next step from `BLUEPRINT_GATE.md`.

## Project Status Update

Update `PROJECT_STATUS.md` with:

- current phase;
- startup mode;
- target venue;
- active idea or method;
- last accepted artifact: `docs/project/RESEARCH_BLUEPRINT.md` or prior
  artifact;
- next gate from `docs/project/BLUEPRINT_GATE.md`;
- blockers;
- phase map with current phase marked.

Use the macro map from `project-guide-protocol.md`:

`direction -> idea -> method -> repo scaffold -> experiment protocol -> local smoke -> AutoDL smoke -> formal runs -> evidence audit -> paper plan -> manuscript -> submission`

## Key Rules

- Be detailed where decisions matter; be concise where the information is
  stable and already available elsewhere.
- Do not generate a large document for a vague direction unless the user asks.
  For a selected candidate or an explicit research-plan request, generate the
  full PDF-level structure above.
- Prefer an accepted Idea Freeze from `/research-refine` as the input. If it is
  missing, mark the blueprint speculative and route back to `/research-refine`.
- Do not claim readiness without evidence paths.
- Do not treat pilot, smoke, or toy runs as paper evidence.
- Do not advance from blueprint to `paper-plan` unless formal runs and the
  evidence audit are complete. Validation-only projects stay in experiment or
  audit phases.
- Do not advance from blueprint directly to `paper-writing`.
- Do not run heavy experiments locally. Prepare commands, configs, and gates.
- Do not fabricate citations, theorem guarantees, dataset properties, or
  metrics.
- Prefer updating an existing `docs/project/RESEARCH_BLUEPRINT.md` over
  creating a new long file.

## Handoff

If the gate decision allows experiments, the next skill is usually
`experiment-plan`, which should read `docs/project/RESEARCH_BLUEPRINT.md`
first.

If formal results already exist and the evidence audit is complete, the next
skill is usually `paper-plan`, which should read
`docs/project/RESEARCH_BLUEPRINT.md`,
`docs/experiments/EXPERIMENT_PROTOCOL.md`, and
`docs/evidence/EVIDENCE_LEDGER.md`. If only smoke, pilot, or validation results
exist, route to `experiment-plan`, `autodl-hpc`, or `experiment-audit` instead.
