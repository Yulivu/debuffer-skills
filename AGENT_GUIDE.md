# debuffer-skills Agent Guide

给第一次读取本仓库的 AI agent。人的入口看 [README.md](README.md)，完整技能目录看 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。

这个仓库是轻量化科研 skills 包。工作重心是本地结构化、代码编辑、审计准备、tiny smoke、AutoDL/HPC 运行准备，以及 prompt-only 外部评审。

## 包状态

**Full catalog**: [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md) - **78 skills**.

| 区域 | 路径 | 说明 |
|---|---|---|
| 主线 skills | `skills/<name>/SKILL.md` | 行为源头 |
| Codex mirror | `skills/skills-codex/<name>/SKILL.md` | Codex 路由适配 |
| 共享契约 | `skills/shared-references/*.md` | 轻量包、评审、证据、helper、项目状态协议 |
| 工具 | `tools/` | 安装器、同步器、库存检查和共享 helper |
| 本地登记 | `.debuffer_registry/` | 已安装项目登记表，本机状态，Git 忽略 |
| 文档 | `docs/SKILLS_CATALOG.md` | 中文紧凑技能目录 |
| 活动 MCP | `mcp-servers/` | 只保留 `manual-review` 和 `codex-image2` |
| 归档区 | `archived/` | 历史 MCP、测试和实验性代码，保留在 Git 中 |

## 工作边界

- **本地轻量**：导入检查、单元测试、lint、配置解析、tiny dry-run/smoke、代码和文档编辑。
- **AutoDL 优先**：GPU/HPC 工作准备 preflight、smoke suite、数据清单、结果回传和正式运行审批。
- **远程命令 gate**：`ssh`、`scp`、`rsync`、`screen`、`tmux`、`nohup` 形成命令块、风险说明和审批点。
- **评审 prompt-only**：审查类 skill 产出 `review-prompts/<scope>_review_prompt.md`，独立对话评审，当前对话整理反馈和行动项。
- **文档紧凑**：普通科研 repo 根目录只保留 `README.md`、`PROJECT_STATUS.md` 和工具托管的 `AGENTS.md` / `CLAUDE.md`；其他 Markdown 写入 `docs/project/`、`docs/experiments/`、`docs/evidence/`、`docs/paper/`、`docs/theory/` 等分类目录，输出清单写入 `docs/project/OUTPUT_MANIFEST.md`。
- **AutoSci-lite**：使用 A-E idea 路径、`idea-stage/IDEA_MEMORY.md`、`experiments/NEGATIVE_RESULTS.md`、pilot gate 和明确宏观状态机。
- **证据边界**：smoke 表示工程可跑；论文证据来自 `experiments/runs/` 经审计后的 `experiments/results/`。

## 项目阶段

| 起步状态 | 最小动作 |
|---|---|
| `venue-only` | 目标 venue 风险、问题假设、文献问题、下一步验证问题 |
| `reference-paper` | claim map、复现/扩展计划、最小实验路线 |
| `reference-codebase` | license、入口、环境、测试、可复用边界 |
| `idea-doc` | 假设、非目标、最小可证伪计划 |
| `existing-repo` | inventory、迁移图、小步结构调整 |
| `partial-results` | 日志、图表、配置、证据链、补充审计 |

活跃项目维护 `PROJECT_STATUS.md`：

```text
Current phase: experiment protocol
Startup mode: reference-codebase
Target venue: JMLR
Last accepted artifact: docs/project/PROJECT_BRIEF.md
Next gate: AutoDL smoke readiness
Map: direction -> idea -> method -> repo scaffold -> [experiment protocol] -> local smoke -> AutoDL smoke -> formal runs -> evidence audit -> paper plan -> manuscript -> submission
Blockers: ...
```

## 常用入口

| 场景 | 首选 skill | 产物 |
|---|---|---|
| 建仓/迁移 | `/research-repo-architect` | 轻量结构、项目状态、AutoDL hooks |
| 方向起步 | `/idea-discovery` | 最小 brief、文献问题、review prompt |
| 想法整理 | `/research-refine` | 方法假设和下一步实验 |
| 研究蓝图 | `/research-blueprint` | 总体进度表、理论基础、实验安排、可复现协议和 gate |
| 实验计划 | `/experiment-plan` | 可复现协议、run order、预算 |
| 实验实现 | `/experiment-bridge` | 本地 tiny checks、AutoDL handoff、code review prompt |
| 远程准备 | `/autodl-hpc` | preflight、smoke、数据清单、审批 gate |
| 外部评审 | `/research-review` | review prompt、反馈摘要、行动项 |
| 证据审计 | `/experiment-audit`, `/paper-claim-audit`, `/citation-audit` | 审计 prompt、证据矩阵、修复清单 |
| 论文写作 | `/paper-writing` | 论文计划、LaTeX、图表、提交前检查 |

## 安装 Profile

```bash
bash tools/install_debuffer_codex.sh /path/to/project --repo "$PWD"
```

```powershell
powershell -ExecutionPolicy Bypass -File tools\install_debuffer.ps1 C:\path\to\project -Platform codex -Repo (Get-Location).Path
```

| Profile | 用途 |
|---|---|
| `full` | 默认，全量 78 skills |
| `core-research` | 建仓、idea、实验计划、AutoDL、基础审计 |
| `paper` | 论文写作、编译、图表、审计、rebuttal/resubmit |
| `review` | prompt-only 外部评审和证据审计 |

## 批量更新已安装项目

安装器成功写入项目 manifest 后，会把项目登记到本技能库的 `.debuffer_registry/installed-projects.tsv`。更新技能库后，从本仓库根目录统一刷新：

```bash
git pull
bash tools/reconcile_debuffer_installs.sh
bash tools/reconcile_debuffer_installs.sh --apply
```

```powershell
git pull
powershell -ExecutionPolicy Bypass -File tools\reconcile_debuffer_installs.ps1
powershell -ExecutionPolicy Bypass -File tools\reconcile_debuffer_installs.ps1 -Apply
```

旧项目没有登记时，先用 `--discover <root>` / `-DiscoverRoot <root>` 扫描已有 `.debuffer_skills/installed-skills*.txt`。

## 修改仓库时的校验

```bash
python tools/check_skills_inventory.py
python -m pytest tests/test_codex_skill_mirror.py -q
git diff --check
```

安装器改动：

```bash
python -m pytest tests/test_install_*.py -q
python -m pytest tests/test_codex_install_update.py -q
```
