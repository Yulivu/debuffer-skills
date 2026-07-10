# debuffer-skills Agent Guide

给第一次读取本仓库的 AI agent。人的入口看 [README.md](README.md)，完整技能目录看 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。总能力数：**91**。默认入口：**13**。

## 包状态

| 区域 | 路径 | 说明 |
|---|---|---|
| 第一层主线入口 | `skills/<entry>/SKILL.md` | 默认可见的用户入口 |
| 第一层 Codex mirror | `skills/skills-codex/<entry>/SKILL.md` | Codex 默认安装来源 |
| 主线能力库 | `skills/library/<domain>/<skill>/SKILL.md` | 默认折叠的细分能力 |
| Codex 能力库 | `skills/skills-codex-library/<domain>/<skill>/SKILL.md` | `full-flat` 或入口路由使用 |
| 共享契约 | `skills/shared-references/*.md` | 轻量包、评审、证据、helper 和项目状态协议 |
| 工具 | `tools/` | 安装器、同步器、库存检查和共享 helper |
| 本地登记 | `.debuffer_registry/` | 已安装项目登记表，本机状态，Git 忽略 |

## 工作边界

- 本地轻量：导入检查、单元测试、lint、配置解析、tiny dry-run/smoke、代码和文档编辑。
- AutoDL 优先：GPU/HPC 工作准备 preflight、smoke suite、数据清单、结果回传和正式运行审批。
- 评审 prompt-only：审查类 skill 产出 `review-prompts/`，独立对话评审，当前对话整理反馈。
- 文档紧凑：普通科研 repo 根目录只保留必要 Markdown，其它材料进入 `docs/` 分类目录。
- 证据边界：smoke 只证明工程可跑，论文证据来自经审计的 `experiments/runs/` 和 curated results。

## 默认入口

| 场景 | 首选 skill | 说明 |
|---|---|---|
| 总流程 | `/research-pipeline` | 按项目阶段选择下游入口 |
| 建仓/迁移 | `/research-repo-architect` | 结构、状态、AutoDL hooks |
| 方向起步 | `/idea-discovery` | 方向、论文、代码库或 idea 起步 |
| 研究蓝图 | `/research-blueprint` | 理论、实验、可复现协议和 gate |
| 实验计划 | `/experiment-plan` | pilot gate、run order、预算 |
| 实验实现 | `/experiment-bridge` | 本地 tiny checks 到远程 handoff |
| 远程准备 | `/autodl-hpc` | AutoDL/HPC preflight 和 smoke |
| 审查评审 | `/research-review` | prompt-only 外部评审和证据审计 |
| 学术改稿 | `/human-tone` | 改稿、润色、去防御性表达和经典论文语气改写 |
| 论文写作 | `/paper-writing` | paper plan、LaTeX、编译、Overleaf |
| 论文图表 | `/paper-visualization` | 数据图、架构图、PPT 矢量重绘、图表审查 |
| rebuttal | `/rebuttal` | 审稿意见和 rebuttal |
| 再投稿 | `/resubmit-pipeline` | 补实验、换 venue、再投稿 |

入口 skill 内的 `Capability Routing` 会指向下层 library。需要直接调用所有细分 skill 时，使用 `full-flat` profile。

## 安装 Profile

| Profile | 用途 |
|---|---|
| `full` | 默认，分层完整，只暴露第一层入口 |
| `core-research` | 建仓、idea、实验计划、AutoDL、基础审计入口 |
| `paper` | 论文写作、图表、rebuttal/resubmit 入口 |
| `review` | prompt-only 评审和证据审计入口 |
| `full-flat` | 完整直调版，安装 91 个能力 |

## 修改仓库时的校验

```bash
python tools/check_skills_inventory.py
python -m pytest tests/test_codex_skill_mirror.py -q
git diff --check
```

安装器改动：

```bash
python -m pytest tests/test_codex_install_update.py tests/test_copilot_install.py -q
```
