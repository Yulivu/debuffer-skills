# debuffer-skills

这是一个面向科研项目的轻量化 Codex skills 定制包。总能力数：**94**。默认入口：**13**。

默认采用分层加载：项目里只直接暴露少量第一层入口 skill，细分能力放在 `skills/library/` 和 `skills/skills-codex-library/`，由入口 skill 按 `Capability Routing` 读取。需要旧式全部 slash 直调时，安装 `full-flat` profile。

## 当前提供

- 本地轻量工作流：建仓、代码编辑、审查准备、测试、lint、配置解析和 tiny smoke。
- AutoDL/HPC 优先：本地只做轻量验证，重型 GPU/HPC 任务使用控制台直连 SSH、preflight、smoke gate、网络加速和结果回传；关机必须以 SSH 不可再次连接为准。
- prompt-only 外部评审：生成 `review-prompts/`，交给独立对话评审，再把反馈整理成行动项。
- 研究完整性审计：检查自动化流程是否越过用户授权、证据边界、数据隔离和结论权限，并保留可追溯的审计记录。
- 发现与义务台账：用 append-only findings / obligations ledger 记录发现、待办、证据来源、责任边界和关闭条件，避免流程状态被覆盖。
- 自动 reviewer loop：支持显式开启的连续评审模式，固定轮数和修复范围，保留原始 reviewer 回复，并防止 scope drift。
- 安全夜间推进：通过 opt-in heartbeat 检查外部状态、恢复停滞阶段和报告阻塞，不自动判断质量、novelty、idea 或论文是否成立。
- 论文链路：blueprint、实验计划、evidence audit、claim/citation/proof 审查、LaTeX、图表、Overleaf 打包、rebuttal 和 resubmit。
- 紧凑项目记忆：根目录保留 `PROJECT_STATUS.md`，其它项目材料进入 `docs/` 分区。

## 最近更新

- 新增强循环工具：支持循环状态监控、停滞检测、结构性 pivot 和人工介入阈值。
- 新增实验声明证据预检：先机械确认结果文件和值存在，再进入 claim 判断。
- 新增计算环境合同：用 env spec、hash ledger 和 smoke witness 管理 AutoDL/HPC/远端环境。
- 升级 research-wiki：paper、idea、experiment、claim 统一走确定性写入和 query_pack 重建。
- 升级安装更新检查：旧版本原样安装不再误判为用户自定义。
- 新增 novelty audit：分别审计问题、范围和方法的新颖性，并区分 `direct`、`partial`、`incomparable` 与 `insufficient-evidence`。
- 自动化只推进已授权流程，不替用户接受 idea、论文、质量或 novelty 结论。
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

可用 profile：`full`、`core-research`、`paper`、`review`、`full-flat`。默认 `full` 只安装第一层入口；`full-flat` 安装全部能力用于直接 slash 调用。

Windows 可双击根目录的 `Install Debuffer Skills.cmd` 打开中文图形界面。macOS 可双击 `Install Debuffer Skills.command`。

<a id="skills-catalog"></a>

## 技能目录

完整表格见 [docs/SKILLS_CATALOG.md](docs/SKILLS_CATALOG.md)。默认入口包括：

| 入口 | 用途 |
|---|---|
| `research-pipeline` | 串联方向、实验、评审、论文和再投稿流程 |
| `research-repo-architect` | 建仓、迁移、项目结构和本地/AutoDL 边界 |
| `idea-discovery` | 发现、筛选并让用户选择 evidence-bounded candidate，不提前生成完整方案 |
| `research-blueprint` | 从 Idea Freeze 生成与参考 PDF 同等结构和详细度的可执行研究计划 |
| `experiment-plan` | 将已冻结的研究计划转成实验协议、pilot gate 和 run order |
| `experiment-bridge` | 本地 tiny checks 到 AutoDL/HPC handoff |
| `autodl-hpc` | AutoDL/HPC preflight、smoke、数据和结果回传 |
| `research-review` | prompt-only 外部评审和证据审计入口 |
| `human-tone` | 学术改稿、润色、去防御性表达和经典论文语气改写 |
| `paper-writing` | 论文计划、正文、编译、Overleaf 和提交检查 |
| `paper-visualization` | 数据图、架构图、PPT 矢量重绘和图表审查 |
| `rebuttal` | rebuttal 和审稿意见处理 |
| `resubmit-pipeline` | 换 venue、补实验和再投稿流程 |

<a id="startup-modes"></a>

## 起步阶段

| 阶段 | 最小产物 |
|---|---|
| `venue-only` | venue 风险、问题假设、文献问题、下一步验证问题 |
| `reference-paper` | claim map、复现/扩展计划、最小实验路线 |
| `reference-codebase` | license、入口、环境、测试和可复用边界 |
| `idea-doc` | 假设、非目标、最小可证伪计划 |
| `existing-repo` | inventory、迁移图、小步结构调整 |
| `partial-results` | 日志、图表、配置、证据链和补充审计 |

<a id="autodl--gpu"></a>

## AutoDL / GPU

本包默认本地轻量、远程重型：本地只做导入检查、单元测试、tiny smoke 和配置解析；正式 GPU/HPC 工作应通过 `autodl-hpc` 准备命令、数据清单、preflight、smoke suite、结果回传路径和正式运行审批点。

<a id="review"></a>

## 外部评审

审查类 skill 不直接接外部 API。它们生成 `review-prompts/<scope>_review_prompt.md`，你把 prompt 和必要证据上下文复制到独立 AI 对话，再把反馈贴回当前项目整理为行动项。

<a id="maintenance"></a>

## 维护

修改技能包后运行：

```bash
python tools/check_skills_inventory.py
python tools/audit_skill_library.py
python -m pytest tests/test_codex_skill_mirror.py -q
git diff --check
```

全库审计报告见
[`docs/SKILL_LIBRARY_AUDIT.md`](docs/SKILL_LIBRARY_AUDIT.md)。它区分立即修复、
保留但 opt-in、候选合并和后续拆分，不会自动改写技能。

安装器改动后补跑：

```bash
python -m pytest tests/test_codex_install_update.py tests/test_copilot_install.py -q
```

<a id="license"></a>

## License

见 [LICENSE](LICENSE)。
