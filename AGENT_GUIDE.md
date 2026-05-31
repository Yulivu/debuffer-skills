# debuffer-skills Agent Guide

> 给第一次读取本仓库的 AI agent。人的入口看 [README.md](README.md)，完整技能目录看 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。

这个仓库是一个轻量化科研 skills 包，不是全自动科研平台。默认行为是：本地做结构、代码、审查准备和 tiny smoke；重型计算交给 AutoDL/HPC；外部评审优先写 prompt 到 `review-prompts/`，让另一个独立对话评审。

如果本文件和具体 `skills/<name>/SKILL.md` 冲突，以 `SKILL.md` 为准；跨技能默认规则看 `skills/shared-references/lightweight-research-pack.md`。

## 包状态

**Full catalog**: [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md) — **79 skills**.

| 区域 | 路径 | 说明 |
|---|---|---|
| 主线 skills | `skills/<name>/SKILL.md` | 行为源头 |
| Codex mirror | `skills/skills-codex/<name>/SKILL.md` | Codex 路由适配，语义应与主线一致 |
| 共享契约 | `skills/shared-references/*.md` | 轻量包、评审、证据、helper、项目状态协议 |
| 工具 | `tools/` | 安装器、同步器、审计 helper |
| 文档 | `docs/` | 只保留必要专题文档和技能目录 |

## 默认规则

- **本地轻量**：本地只跑导入检查、单元测试、lint、配置解析、tiny dry-run/smoke。不要默认跑重型训练、长 sweep 或正式评测。
- **AutoDL 优先**：需要 GPU/HPC 时，准备 AutoDL preflight、smoke suite、数据清单、结果回传和正式运行审批，不直接开长 SSH 任务。
- **远程手动 gate**：涉及 `ssh`、`scp`、`rsync`、`screen`、`tmux`、`nohup` 的步骤，默认只输出命令块并等待用户运行或批准。
- **评审 prompt-only**：审查类 skill 默认写 `review-prompts/<scope>_review_prompt.md`，要求用户在另一个独立对话里评审并粘贴结果。不要默认调用 MCP/API/subagent reviewer。
- **文档克制**：维护 `PROJECT_STATUS.md`、`PROJECT_BRIEF.md`、`NEXT_ACTIONS.md`、`findings.md`、`EXPERIMENT_LOG.md` 等小文件。`PROJECT_GUIDE.md` 只在阶段门或用户明确要求时生成。
- **证据边界**：smoke 只说明工程可跑，不构成论文证据。正式结果必须从 `experiments/runs/` 经本地审计后进入 `experiments/results/`。

## 项目阶段

先判断起步状态，再决定生成多少内容：

| 起步状态 | 最小动作 |
|---|---|
| `venue-only` | 写目标 venue 风险、问题假设、下一步文献/验证问题 |
| `reference-paper` | 做 claim map、复现/扩展计划、最小实验路线 |
| `reference-codebase` | 审 license、入口、环境、测试和可复用边界 |
| `idea-doc` | 抽取假设、非目标、最小可证伪计划 |
| `existing-repo` | 先 inventory 和迁移图，再小步编辑 |
| `partial-results` | 先盘点日志/图表/配置/证据链，再补审计 |

每个活跃项目都应维护 `PROJECT_STATUS.md`：

```text
Current phase: experiment protocol
Startup mode: reference-codebase
Target venue: JMLR
Last accepted artifact: PROJECT_BRIEF.md
Next gate: AutoDL smoke readiness
Map: direction -> idea -> method -> repo scaffold -> [experiment protocol] -> local smoke -> AutoDL smoke -> formal runs -> evidence audit -> paper plan -> manuscript -> submission
Blockers: ...
```

## 常用入口

| 场景 | 首选 skill | 默认动作 |
|---|---|---|
| 建仓/迁移 | `/research-repo-architect` | 轻量结构、项目状态、AutoDL hooks |
| 只知道方向/venue | `/idea-discovery` | 生成最小 brief、文献问题和 review prompt |
| 已有想法 | `/research-refine` | 收敛方法假设和下一步实验 |
| 形成实验计划 | `/experiment-plan` | 产出可复现协议，不直接跑正式实验 |
| 实现实验 | `/experiment-bridge` | 本地 tiny checks + AutoDL handoff + code review prompt |
| 准备远程跑 | `/autodl-hpc` | preflight、smoke、数据清单、审批 gate |
| 外部评审 | `/research-review` | 写 prompt，等待独立对话反馈 |
| 论文证据审计 | `/experiment-audit`, `/paper-claim-audit`, `/citation-audit` | 写审计 prompt 或执行显式批准的 legacy backend |
| 写论文 | `/paper-writing` | 用已审计证据组织 LaTeX，不补造结果 |

## 安装 Profile

安装器支持 profile，默认 `full`：

```bash
bash tools/install_aris_codex.sh /path/to/project --profile core-research
```

```powershell
powershell -ExecutionPolicy Bypass -File tools\install_aris.ps1 C:\path\to\project -Platform codex -Profile core-research
```

| Profile | 用途 |
|---|---|
| `core-research` | 建仓、idea、实验计划、AutoDL、基础审查 |
| `paper` | 论文写作、编译、图表、审计、rebuttal/resubmit |
| `review` | prompt-only 外部评审和证据审计 |
| `full` | 全量安装 79 skills |

## 修改仓库时必须验证

```bash
python tools/check_skills_inventory.py
python -m pytest tests/test_codex_skill_mirror.py -q
git diff --check
```

如果改安装器：

```bash
python -m pytest tests/test_install_aris_ps1.py -q
```

## 禁止默认行为

- 不要新增 README-like 文件；仓库只保留根 `README.md`。
- 不要把教程全集、论文 PDF、演示图片或 generated HTML 放回主包。
- 不要默认接入新的 API reviewer；先输出 prompt。
- 不要默认 SSH 到远程机器启动长任务。
- 不要在每轮对话生成新的长 Markdown 报告；先更新已有小文件或阶段 guide。
