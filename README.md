# debuffer-skills

这是一个面向科研项目的轻量化 Codex skills 定制包。当前提供 **78 个 skill**，主线与 Codex mirror 均为 **78 个 skill**，完整清单见 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。

## 当前提供

- 本地轻量工作流：仓库结构、代码编辑、审计准备、测试、lint、配置解析和 tiny smoke。
- AutoDL/HPC 运行准备：preflight、smoke suite、数据清单、结果回传和正式运行审批。
- prompt-only 外部评审：把上下文整理到 `review-prompts/`，交给独立对话评审，再消费粘贴回来的反馈。
- 多起步阶段适配：`venue-only`、`reference-paper`、`reference-codebase`、`idea-doc`、`existing-repo`、`partial-results`。
- AutoSci-lite 启发式：A-E idea 生成路径、轻量失败记忆、pilot gate 和明确项目宏观状态机。
- 论文与审计链路：实验计划、结果审计、claim/citation/proof 检查、LaTeX 写作、rebuttal 和 resubmit。
- 紧凑项目记忆：根目录保留 `PROJECT_STATUS.md`，其他项目记忆进入 `docs/project/`、`docs/experiments/`、`docs/evidence/`、`docs/paper/`、`docs/theory/` 等分类目录。

## 最近更新

- 新增 `research-blueprint`：在正式实验、AutoDL 正式运行或论文写作前生成 `docs/project/RESEARCH_BLUEPRINT.md` 和 `docs/project/BLUEPRINT_GATE.md`。
- `docs/project/RESEARCH_BLUEPRINT.md` 开头固定包含“总体进度表”，按数据获取、预处理、协议冻结、理论/方法、local smoke、AutoDL smoke、pilot、正式实验、证据审计、论文计划、初稿和投稿材料逐步打勾。
- `experiment-plan`、`paper-plan`、`research-pipeline`、`research-repo-architect` 已接入 blueprint gate。
- `research-repo-architect` 增加根目录 Markdown 约束：普通科研 repo 根目录只保留 `README.md`、`PROJECT_STATUS.md` 和工具托管的 `AGENTS.md` / `CLAUDE.md`，其他 Markdown 进入 `docs/` 分类目录。
- 共享输出记录从根目录 `MANIFEST.md` 调整为 `docs/project/OUTPUT_MANIFEST.md`；证明和公式推导默认进入 `docs/theory/`。
- 安装 profile 已包含 `research-blueprint`，当前主线与 Codex mirror 均为 78 个 skill。

<a id="quick-start"></a>

## 快速开始

```bash
git clone git@github.com:Yulivu/debuffer-skills.git
cd debuffer-skills
```

给 Codex 项目安装 project-local skills：

```bash
read -r -p "目标项目路径: " target_repo
bash tools/install_debuffer_codex.sh "$target_repo" --repo "$PWD"
```

Windows PowerShell：

```powershell
$targetRepo = Read-Host "目标项目路径"
powershell -ExecutionPolicy Bypass -File tools\install_debuffer.ps1 $targetRepo -Platform codex -Repo (Get-Location).Path
```

可用 profile：`full`、`core-research`、`paper`、`review`。默认安装 `full`；只想轻量入口时再手动选择 `core-research`。

安装后，目标项目只会增加项目本地入口：`.agents/skills/`（Codex）和 `.debuffer_skills/`（安装 manifest、锁、helper 链接与运行状态）。这些是本地工作区状态，默认不要提交；已有旧版状态目录时，重新运行安装器会自动迁移到 `.debuffer_skills/`。

安装器会在本技能库本地维护 `.debuffer_registry/installed-projects.tsv`，记录哪些项目从这个 checkout 安装过。该登记表只用于本机批量更新，已被 Git 忽略。

Windows 上可以双击根目录的 `Install Debuffer Skills.cmd` 打开中文图形界面。默认安装 `full`，主要操作只有 `安装/重连`、`更新全部`、`扫描旧项目`。

macOS 上可以直接双击根目录的 `Install Debuffer Skills.command`，选择安装到单个 repo 或更新所有登记项目。若 Finder 提示无法执行，先在终端运行：

```bash
chmod +x "Install Debuffer Skills.command"
```

也可以把便携脚本复制到任意项目根目录后运行。脚本会把所在目录作为目标项目，并自动发现中央 `debuffer-skills` 仓库；找不到时可通过 `-Repo` / `--repo` 指定，或使用 clone 选项。

Windows PowerShell：

```powershell
# 在 debuffer-skills 仓库根目录运行
$skillRepo = (Get-Location).Path
$targetRepo = Read-Host "目标项目路径"
Copy-Item (Join-Path $skillRepo "tools\use_debuffer_skills.ps1") $targetRepo
Set-Location $targetRepo
powershell -ExecutionPolicy Bypass -File .\use_debuffer_skills.ps1 -Repo $skillRepo
```

Git Bash / Linux / AutoDL：

```bash
# 在 debuffer-skills 仓库根目录运行
skill_repo="$(pwd)"
read -r -p "目标项目路径: " target_repo
cp "$skill_repo/tools/use_debuffer_skills.sh" "$target_repo/"
cd "$target_repo"
bash use_debuffer_skills.sh --repo "$skill_repo"
```

显式指定中央库：

```powershell
$skillRepo = Read-Host "debuffer-skills repo path"
powershell -ExecutionPolicy Bypass -File .\use_debuffer_skills.ps1 -Repo $skillRepo
```

批量更新所有已安装项目：

```bash
git pull
bash tools/reconcile_debuffer_installs.sh
bash tools/reconcile_debuffer_installs.sh --apply
```

Windows PowerShell：

```powershell
git pull
powershell -ExecutionPolicy Bypass -File tools\reconcile_debuffer_installs.ps1
powershell -ExecutionPolicy Bypass -File tools\reconcile_debuffer_installs.ps1 -Apply
```

如果是已经安装过、但还没有进入登记表的旧项目，先扫描一次项目根目录：

```bash
bash tools/reconcile_debuffer_installs.sh --discover "$HOME/Desktop"
```

```powershell
powershell -ExecutionPolicy Bypass -File tools\reconcile_debuffer_installs.ps1 -DiscoverRoot "$HOME\Desktop"
```

<a id="skills-catalog"></a>

## 主要入口

- `research-repo-architect`：创建或迁移科研仓库，匹配起步阶段，维护项目宏观状态。
- `autodl-hpc`：准备 AutoDL/HPC 运行、数据策略、preflight、smoke gate、结果传输和正式运行审批。
- `idea-discovery` / `research-refine` / `research-blueprint` / `experiment-plan`：从方向、参考论文、代码库或初步 idea 走到严密研究蓝图和可验证实验计划。
- `research-review` / `auto-review-loop` / `paper-claim-audit` / `citation-audit`：生成独立评审 prompt，并整理反馈为行动项。
- `paper-writing` / `paper-write` / `paper-compile`：把已审计证据组织成论文草稿、LaTeX 和提交前检查。
- `rebuttal` / `resubmit-pipeline`：处理会议/期刊反馈、rebuttal 和换 venue 投稿。

完整表见 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。

<a id="startup-modes"></a>

## 起步阶段

| 阶段 | 产物 |
|---|---|
| `venue-only` | 目标 venue 风险、问题假设、文献问题和下一步验证问题 |
| `reference-paper` | claim map、复现/扩展计划和最小实验路线 |
| `reference-codebase` | license、入口、环境、测试和可复用边界审查 |
| `idea-doc` | 假设、非目标和最小可证伪计划 |
| `existing-repo` | inventory、迁移图和小步结构调整 |
| `partial-results` | 日志、图表、配置、证据链和补充审计 |

每个项目维护 `PROJECT_STATUS.md`：当前宏观阶段、目标 venue、最近接受的产物、下一道 gate、阻塞和下一步。

<a id="autodl--gpu"></a>

## AutoDL 与 GPU

推荐流程是“本地准备，远端执行，人工批准”：

- 本地执行格式检查、单元测试、tiny smoke 和配置解析。
- AutoDL/HPC 项目生成 `docs/runbooks/AUTODL_HPC_RUNBOOK.md`、`data/DATA_MANIFEST.md`、`experiments/suites/*smoke*` 和 `scripts/hpc/*`。
- preflight、smoke、formal suite、长 sweep、数据下载和结果回传都有清晰命令块和审批点。
- 原始输出进入 `experiments/runs/`，审计后的稳定证据进入 `experiments/results/` 和论文图表。

<a id="review"></a>

## 外部评审

独立评审入口是 `review-prompts/`：

```text
review-prompts/
  aaai_review_prompt.md
  iclr_review_prompt.md
  jmlr_review_prompt.md
  tpami_review_prompt.md
```

AAAI/ICLR 侧重 novelty、实验说服力和叙事；JMLR 侧重完整性、严谨性和长期可复现；TPAMI 侧重技术深度、视觉/模式识别定位、实验覆盖和工程可信度。

<a id="maintenance"></a>

## 文档维护

仓库文档入口为根中文 `README.md` 和 `docs/SKILLS_CATALOG.md`。项目运行文档采用少量、阶段化、可融合的结构：

- 根目录只保留必要入口和状态 Markdown：`README.md`、`PROJECT_STATUS.md`，以及工具托管的 `AGENTS.md` / `CLAUDE.md`。
- 起步阶段产出 `docs/project/PROJECT_BRIEF.md`、`PROJECT_STATUS.md`、`docs/project/NEXT_ACTIONS.md`。
- 形成实验证据后维护 `docs/evidence/findings.md`、`docs/experiments/EXPERIMENT_LOG.md`、`docs/evidence/EVIDENCE_LEDGER.md`。
- 实验计划、AutoDL 正式运行或论文写作前刷新 `docs/project/RESEARCH_BLUEPRINT.md` 和 `docs/project/BLUEPRINT_GATE.md`；较轻交接可只刷新 `docs/project/PROJECT_GUIDE.md`。
- 输出清单写入 `docs/project/OUTPUT_MANIFEST.md`；理论证明、公式推导等写入 `docs/theory/`。

## 仓库结构

```text
skills/                         主线 skills
skills/skills-codex/            Codex mirror
skills/shared-references/       跨 skill 契约和协议
tools/                          安装器、同步器和共享 helper
templates/                      项目产物模板
docs/SKILLS_CATALOG.md          中文紧凑技能目录
mcp-servers/                    活动 MCP：manual-review、codex-image2
archived/                       归档代码，保留在 Git 中
tests/                          inventory、mirror 和安装器测试
```

## 校验

修改 skill、mirror、目录结构或 README 后运行：

```bash
python tools/check_skills_inventory.py
python -m pytest tests/test_codex_skill_mirror.py -q
git diff --check
```

安装器或 helper 改动再补跑对应 `tests/test_install_*.py` 和 helper 测试。

<a id="license"></a>

## 许可证

MIT License。详见 [LICENSE](LICENSE)。
