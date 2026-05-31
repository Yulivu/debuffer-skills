# debuffer-skills

这是一个面向科研项目的轻量化 ARIS/Codex skills 定制包。它保留 79 个可组合 skill 和 Codex mirror，但默认不追求全自动化：本地做结构、代码、审计、测试和 tiny smoke；重型 GPU 任务优先准备 AutoDL/HPC；外部评审优先输出 prompt，让另一个隔离对话执行评审。

当前包含 **79 个 skill**。主线与 Codex mirror 均为 **79 个 skill**，完整清单见 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。

## 设计原则

- 本地轻量：不默认跑大规模训练、长 sweep、重型评测或长时间后台任务。
- AutoDL 优先：需要 GPU 时，优先准备 preflight、smoke、数据清单、结果回传和正式运行审批。
- 评审分离：默认写 `review-prompts/`，把 prompt 交给另一个启用本 skill 包的独立对话评审。
- 放弃默认 SSH 自动化：`ssh`、`scp`、`rsync`、`screen`、`tmux`、`nohup` 只默认输出命令块并等待批准。
- 文档克制：本仓库只保留根中文 `README.md` 和紧凑技能目录；项目文档按阶段生成并定期融合。
- 可复现优先：每个项目都维护宏观阶段、下一道 gate、证据边界和阻塞项。

<a id="quick-start"></a>

## 快速开始

```bash
git clone git@github.com:Yulivu/debuffer-skills.git
cd debuffer-skills
```

给 Codex 项目安装 project-local skills：

```bash
bash tools/install_aris_codex.sh /path/to/project --aris-repo "$PWD" --profile core-research
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File tools\install_aris.ps1 C:\path\to\project -Platform codex -ArisRepo (Get-Location).Path -Profile core-research
```

可用 profile：`core-research`、`paper`、`review`、`full`。默认 `full` 保持兼容；新科研项目建议从 `core-research` 开始。

<a id="skills-catalog"></a>

## 主要入口

- `research-repo-architect`：按不同起步阶段创建或迁移科研仓库，并维护项目宏观状态。
- `autodl-hpc`：准备 AutoDL/HPC 的 deploy key、离线数据策略、preflight、smoke gate、结果传输和正式运行审批。
- `idea-discovery` / `research-refine` / `experiment-plan`：从方向、参考论文、代码库或初步 idea 走到可验证实验计划。
- `research-review` / `auto-review-loop` / `paper-claim-audit` / `citation-audit`：默认生成独立评审 prompt，并消费粘贴回来的反馈。
- `paper-writing` / `paper-write` / `paper-compile`：把已审计证据组织成论文草稿、LaTeX 和提交前检查。
- `rebuttal` / `resubmit-pipeline`：适配会议/期刊反馈、rebuttal 和换 venue 投稿。

完整表见 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。

<a id="startup-modes"></a>

## 起步阶段

`research-repo-architect` 会先判断项目属于哪种状态，再决定生成多少材料：

- `venue-only`：只知道目标期刊/会议和大方向，先生成 brief、风险清单和下一步验证问题。
- `reference-paper`：已有参考论文，先做 claim map、复现/扩展计划和最小实验路线。
- `reference-codebase`：已有代码库，先审查 license、入口、环境、测试和可复用边界。
- `idea-doc`：已有初步想法文档，先抽取假设、非目标和最小可证伪计划。
- `existing-repo`：已有仓库，先做迁移图，再小步调整结构。
- `partial-results`：已有结果，先盘点日志、图表、配置和证据链，再补审计。

每个阶段都应维护 `PROJECT_STATUS.md`：当前宏观阶段、目标 venue、最近接受的产物、下一道 gate、阻塞和下一步。

<a id="autodl--gpu"></a>

## AutoDL 与 GPU

默认策略是“本地准备，远端执行，人工批准”：

- 本地只跑格式检查、单元测试、tiny smoke 和配置解析。
- AutoDL/HPC 项目应生成 `docs/runbooks/AUTODL_HPC_RUNBOOK.md`、`data/DATA_MANIFEST.md`、`experiments/suites/*smoke*` 和 `scripts/hpc/*`。
- preflight 和 smoke 通过只说明工程准备就绪，不自动升级为正式实验。
- 正式 suite、长 sweep、大数据下载和 SSH 执行都需要用户确认。
- 结果回传后，原始输出先进 `experiments/runs/`，审计后再进入 `experiments/results/` 和论文图表。

<a id="review"></a>

## 外部评审

本包不默认要求接入新的 reviewer API。需要独立评审时，skills 优先写：

```text
review-prompts/
  aaai_review_prompt.md
  iclr_review_prompt.md
  jmlr_review_prompt.md
  tpami_review_prompt.md
```

然后在另一个独立对话中加载这个 skill 包，把 prompt、论文、代码路径和结果证据交给评审者。AAAI/ICLR 更重 novelty、实验说服力和叙事；JMLR 更重完整性、严谨性和长期可复现；TPAMI 更重技术深度、视觉/模式识别定位、实验覆盖和工程可信度。

<a id="maintenance"></a>

## 文档维护

本仓库只保留根中文 `README.md` 和 `docs/SKILLS_CATALOG.md`。不要把教程全集、论文 PDF、演示图片、生成 HTML 或平台迁移旧文档放回主包。

项目运行中生成文档也遵循少量、阶段化、可融合：

- 起步阶段只生成 `PROJECT_BRIEF.md`、`PROJECT_STATUS.md`、`NEXT_ACTIONS.md` 等必要文件。
- 形成实验证据后再维护 `findings.md`、`EXPERIMENT_LOG.md`、`PROJECT_GUIDE.md`。
- `PROJECT_GUIDE.md` 只在阶段门或重要交接时刷新，不作为每轮对话默认产物。

## 仓库结构

```text
skills/                         主线 skills
skills/skills-codex/            Codex mirror
skills/shared-references/       跨 skill 契约和协议
tools/                          安装器、同步器和共享 helper
templates/                      项目产物模板
docs/SKILLS_CATALOG.md          中文紧凑技能目录
mcp-servers/                    可选 bridge，默认不强制使用
tests/                          inventory、mirror 和安装器测试
```

## 校验

修改 skill、mirror、目录结构或 README 后至少运行：

```bash
python tools/check_skills_inventory.py
python -m pytest tests/test_codex_skill_mirror.py -q
git diff --check
```

如果改了安装器或 helper，再补跑对应 `tests/test_install_*.py` 和 helper 测试。

<a id="license"></a>

## 许可证

继承上游 MIT License。详见 [LICENSE](LICENSE)。
