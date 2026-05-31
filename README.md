# debuffer-skills

这是一个面向科研项目的 ARIS/Codex skills 定制包。它保留 ARIS 的技能化工作流和 Codex mirror，但默认更轻量：本地只做结构化、审查、代码改动、tiny smoke 和可复现准备；重型 GPU 任务优先交给 AutoDL/HPC，并且需要显式的人工确认。

当前包包含 **79 个 skill**。主线与 Codex mirror 均为 **79 个 skill**，完整清单见 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。

## 设计原则

- 本地轻量：不在本地默认跑大规模训练、长 sweep、重型评测或长时间后台任务。
- AutoDL 优先：需要 GPU 时，优先准备 AutoDL/HPC 的 preflight、smoke、数据清单和结果回传流程。
- 评审分离：外部评审默认输出 prompt 到 `review-prompts/`，让另一个独立对话接入这些 skills 后评审；不把新的 API 集成当作默认路径。
- 放弃全自动 SSH：涉及 SSH、远程 GPU、正式实验和数据下载的动作默认停在命令准备、检查清单和人工审批边界。
- 文档克制：只保留这个中文根 README。项目文档按阶段生成，阶段门处再融合、精简，避免每轮都堆出大量 Markdown。
- 可复现优先：每个项目都要知道自己处于宏观阶段、下一道 gate 是什么、已有证据和阻塞在哪里。

<a id="quick-start"></a>

## 快速开始

克隆这个定制包：

```bash
git clone git@github.com:Yulivu/debuffer-skills.git
cd debuffer-skills
```

给一个 Codex 项目安装 project-local skills：

```bash
bash tools/install_aris_codex.sh /path/to/your/project --aris-repo "$PWD"
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File tools\install_aris.ps1 C:\path\to\project -Platform codex -ArisRepo (Get-Location).Path
```

如果只是维护一个 copied Codex skills 目录：

```bash
bash tools/smart_update_codex.sh --local ~/.codex/skills --apply
```

<a id="skills-catalog"></a>

## 主要入口

- `research-repo-architect`：新建或迁移研究仓库，按项目起步阶段生成最小可用结构，并维护项目宏观状态。
- `autodl-hpc`：准备 AutoDL/HPC 运行，包括 deploy key、离线数据策略、preflight、smoke gate、结果传输和正式运行审批。
- `idea-discovery` / `research-refine` / `experiment-plan`：从方向、参考论文、代码库或初步 idea 走到可验证实验计划。
- `research-review` / `auto-review-loop` / `paper-claim-audit` / `citation-audit`：生成或执行审查流程；本定制包默认优先输出独立评审 prompt。
- `paper-writing` / `paper-write` / `paper-compile`：把已有证据组织成论文草稿、LaTeX 和提交前检查。
- `rebuttal` / `resubmit-pipeline`：适配会议/期刊反馈、rebuttal 和换 venue 投递。

完整技能表、依赖和用途见 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。

<a id="startup-modes"></a>

## 起步阶段

`research-repo-architect` 会先判断项目属于哪种起步状态，再决定生成多少内容：

- `venue-only`：只知道目标期刊/会议和大方向，先生成 brief、风险清单、下一步验证问题。
- `reference-paper`：已有参考论文，先做 claim map、复现/扩展计划和最小实验路线。
- `reference-codebase`：已有代码库，先审查 license、入口、环境、测试和可复用边界。
- `idea-doc`：已有初步想法文档，先抽取假设、非目标和最小可证伪计划。
- `existing-repo`：已有仓库，先做迁移图，再小步调整结构。
- `partial-results`：已有部分结果，先盘点日志、图表、配置和证据链，再补缺失审计。

每个阶段都应维护 `PROJECT_STATUS.md`：当前宏观阶段、目标 venue、最近接受的产物、下一道 gate、阻塞和下一步。

<a id="autodl--gpu"></a>

## AutoDL 与 GPU

默认策略是“本地准备，远端执行，人工批准”：

- 本地只跑格式检查、单元测试、tiny smoke 和配置解析。
- AutoDL/HPC 项目应生成 `docs/runbooks/AUTODL_HPC_RUNBOOK.md`、`data/DATA_MANIFEST.md`、`experiments/suites/*smoke*` 和 `scripts/hpc/*`。
- preflight 和 smoke 通过只说明工程准备就绪，不自动升级为正式实验。
- 正式 suite、长 sweep、下载大数据和 SSH 执行都需要用户确认。
- 结果回传后，先把原始输出放进 `experiments/runs/`，再从审计过的结果生成 `experiments/results/` 和论文图表。

Vast.ai 等其他 GPU 路径仍可保留为备选，但本定制包的默认经验会优先落到 AutoDL/HPC。

<a id="review"></a>

## 外部评审

本包不默认要求接入新的 reviewer API。需要独立评审时，skills 应优先写出：

```text
review-prompts/
  aaai_review_prompt.md
  iclr_review_prompt.md
  jmlr_review_prompt.md
  tpami_review_prompt.md
```

然后在另一个独立对话中加载这个 skill 包，把 prompt、论文、代码路径和结果证据交给评审者。这样保留跨对话隔离和跨模型审查效果，同时避免把 API key、MCP bridge 或 SSH 自动化变成默认依赖。

评审口径需要按 venue 调整：AAAI/ICLR 更关注 novelty、实验说服力和清晰叙事；JMLR 更关注完整性、严谨性和长期可复现；TPAMI 更关注技术深度、视觉/模式识别领域定位、实验覆盖和工程可信度。

<a id="maintenance"></a>

## 文档维护

这个仓库只保留根目录的中文 `README.md`。新增说明优先放进已有专题文档或 skill 内部 contract；项目运行中生成的 Markdown 也要遵循“少量、阶段化、可融合”的原则：

- 起步阶段只生成 `PROJECT_BRIEF.md`、`PROJECT_STATUS.md`、`NEXT_ACTIONS.md` 等必要文件。
- 形成实验证据后再维护 `findings.md`、`EXPERIMENT_LOG.md`、`PROJECT_GUIDE.md`。
- `PROJECT_GUIDE.md` 只在阶段门或重要交接时刷新，不作为每轮对话的默认产物。
- 长文档定期合并，旧草稿移入 archive 或删除，避免仓库变成 Markdown 堆积场。

## 仓库结构

```text
skills/                         主线 skills
skills/skills-codex/            Codex mirror
skills/shared-references/       跨 skill 契约和协议
tools/                          安装器、同步器和共享 helper
templates/                      项目产物模板
docs/                           专题文档和技能目录
mcp-servers/                    可选 bridge，默认不强制使用
tests/                          inventory、mirror 和安装器测试
```

## 校验

修改 skill、mirror、目录结构或 README 后至少运行：

```bash
python tools/check_skills_inventory.py
python -m pytest tests/test_codex_skill_mirror.py
git diff --check
```

如果改了安装器或 helper，再补跑对应的 `tests/test_install_*.py` 和 helper 测试。

<a id="license"></a>

## 许可证

继承上游 MIT License。详见 [LICENSE](LICENSE)。
