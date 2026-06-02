# Skills Catalog

这个目录是 `debuffer-skills` 的紧凑技能清单。当前主线与 Codex mirror 均为 **78 skills**。

默认流程：本地轻量检查，AutoDL/HPC 运行准备，prompt-only 评审，紧凑项目记忆。

| Skill | 类别 | 干什么 | 如何做到 |
|---|---|---|---|
| [`/ablation-planner`](../skills/ablation-planner/SKILL.md) | 想法与方法 | 把假设、方法和 venue 风险整理成可验证计划。 | 建立 claim map、实验路线、风险表和最小验证集。 |
| [`/alphaxiv`](../skills/alphaxiv/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/analyze-results`](../skills/analyze-results/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/arxiv`](../skills/arxiv/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/auto-paper-improvement-loop`](../skills/auto-paper-improvement-loop/SKILL.md) | 其他 | 提供对应场景的专项处理能力。 | 遵循 SKILL.md 的触发条件和轻量包默认边界。 |
| [`/auto-review-loop`](../skills/auto-review-loop/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/auto-review-loop-llm`](../skills/auto-review-loop-llm/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/auto-review-loop-minimax`](../skills/auto-review-loop-minimax/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/autodl-hpc`](../skills/autodl-hpc/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/citation-audit`](../skills/citation-audit/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/claims-drafting`](../skills/claims-drafting/SKILL.md) | 专利 | 围绕发明点、现有技术和法域格式生成专利草案。 | 检索先有技术，结构化发明点，生成权利要求和说明书。 |
| [`/comm-lit-review`](../skills/comm-lit-review/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/deepxiv`](../skills/deepxiv/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/dse-loop`](../skills/dse-loop/SKILL.md) | 流程编排 | 串联多个 skill，把方向、实验、评审和论文推进到阶段产物。 | 读取项目状态，选择下游 skill，输出紧凑记录和下一步。 |
| [`/embodiment-description`](../skills/embodiment-description/SKILL.md) | 专利 | 围绕发明点、现有技术和法域格式生成专利草案。 | 检索先有技术，结构化发明点，生成权利要求和说明书。 |
| [`/exa-search`](../skills/exa-search/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/experiment-audit`](../skills/experiment-audit/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/experiment-bridge`](../skills/experiment-bridge/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/experiment-plan`](../skills/experiment-plan/SKILL.md) | 想法与方法 | 把假设、方法和 venue 风险整理成可验证计划。 | 建立 claim map、实验路线、风险表和最小验证集。 |
| [`/experiment-queue`](../skills/experiment-queue/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/feishu-notify`](../skills/feishu-notify/SKILL.md) | 辅助输出 | 生成项目本地辅助材料、通知或学习文档。 | 把输出写到目标项目，配套简短审查或通知流程。 |
| [`/figure-description`](../skills/figure-description/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/figure-spec`](../skills/figure-spec/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/formula-derivation`](../skills/formula-derivation/SKILL.md) | 想法与方法 | 把假设、方法和 venue 风险整理成可验证计划。 | 建立 claim map、实验路线、风险表和最小验证集。 |
| [`/gemini-search`](../skills/gemini-search/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/grant-proposal`](../skills/grant-proposal/SKILL.md) | 辅助输出 | 生成项目本地辅助材料、通知或学习文档。 | 把输出写到目标项目，配套简短审查或通知流程。 |
| [`/idea-creator`](../skills/idea-creator/SKILL.md) | 想法与方法 | 把假设、方法和 venue 风险整理成可验证计划。 | 建立 claim map、实验路线、风险表和最小验证集。 |
| [`/idea-discovery`](../skills/idea-discovery/SKILL.md) | 流程编排 | 串联多个 skill，把方向、实验、评审和论文推进到阶段产物。 | 读取项目状态，选择下游 skill，输出紧凑记录和下一步。 |
| [`/interview-cheatsheet`](../skills/interview-cheatsheet/SKILL.md) | 辅助输出 | 生成项目本地辅助材料、通知或学习文档。 | 把输出写到目标项目，配套简短审查或通知流程。 |
| [`/invention-structuring`](../skills/invention-structuring/SKILL.md) | 专利 | 围绕发明点、现有技术和法域格式生成专利草案。 | 检索先有技术，结构化发明点，生成权利要求和说明书。 |
| [`/jurisdiction-format`](../skills/jurisdiction-format/SKILL.md) | 专利 | 围绕发明点、现有技术和法域格式生成专利草案。 | 检索先有技术，结构化发明点，生成权利要求和说明书。 |
| [`/kill-argument`](../skills/kill-argument/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/mermaid-diagram`](../skills/mermaid-diagram/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/meta-optimize`](../skills/meta-optimize/SKILL.md) | 流程编排 | 串联多个 skill，把方向、实验、评审和论文推进到阶段产物。 | 读取项目状态，选择下游 skill，输出紧凑记录和下一步。 |
| [`/monitor-experiment`](../skills/monitor-experiment/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/novelty-check`](../skills/novelty-check/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/openalex`](../skills/openalex/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/overleaf-sync`](../skills/overleaf-sync/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-claim-audit`](../skills/paper-claim-audit/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/paper-compile`](../skills/paper-compile/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-figure`](../skills/paper-figure/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-illustration`](../skills/paper-illustration/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-illustration-image2`](../skills/paper-illustration-image2/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-plan`](../skills/paper-plan/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-poster`](../skills/paper-poster/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-slides`](../skills/paper-slides/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-talk`](../skills/paper-talk/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-write`](../skills/paper-write/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/paper-writing`](../skills/paper-writing/SKILL.md) | 论文与图表 | 在正式实验与 evidence audit 通过后，把已接受的 paper plan 推进为 LaTeX 正文。 | 先检查 manuscript-entry gate；未通过时只输出 gap / next actions，不生成正文。 |
| [`/patent-novelty-check`](../skills/patent-novelty-check/SKILL.md) | 专利 | 围绕发明点、现有技术和法域格式生成专利草案。 | 检索先有技术，结构化发明点，生成权利要求和说明书。 |
| [`/patent-pipeline`](../skills/patent-pipeline/SKILL.md) | 流程编排 | 串联多个 skill，把方向、实验、评审和论文推进到阶段产物。 | 读取项目状态，选择下游 skill，输出紧凑记录和下一步。 |
| [`/patent-review`](../skills/patent-review/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/pixel-art`](../skills/pixel-art/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/prior-art-search`](../skills/prior-art-search/SKILL.md) | 专利 | 围绕发明点、现有技术和法域格式生成专利草案。 | 检索先有技术，结构化发明点，生成权利要求和说明书。 |
| [`/proof-checker`](../skills/proof-checker/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/proof-writer`](../skills/proof-writer/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/qzcli`](../skills/qzcli/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/rebuttal`](../skills/rebuttal/SKILL.md) | 流程编排 | 串联多个 skill，把方向、实验、评审和论文推进到阶段产物。 | 读取项目状态，选择下游 skill，输出紧凑记录和下一步。 |
| [`/render-html`](../skills/render-html/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/research-blueprint`](../skills/research-blueprint/SKILL.md) | 想法与方法 | 在正式实验、AutoDL 正式运行或论文证据准入前生成严密研究蓝图。 | 写 `docs/project/RESEARCH_BLUEPRINT.md` 的总体进度表、理论/方法/数据/实验/可复现计划，并用 `docs/project/BLUEPRINT_GATE.md` 判定下一步；不能直接路由到正文写作。 |
| [`/research-lit`](../skills/research-lit/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/research-pipeline`](../skills/research-pipeline/SKILL.md) | 流程编排 | 串联多个 skill，把方向、实验、评审和论文推进到阶段产物。 | 读取项目状态，选择下游 skill，输出紧凑记录和下一步。 |
| [`/research-refine`](../skills/research-refine/SKILL.md) | 想法与方法 | 把假设、方法和 venue 风险整理成可验证计划。 | 建立 claim map、实验路线、风险表和最小验证集。 |
| [`/research-repo-architect`](../skills/research-repo-architect/SKILL.md) | 其他 | 提供对应场景的专项处理能力。 | 遵循 SKILL.md 的触发条件和轻量包默认边界。 |
| [`/research-review`](../skills/research-review/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/research-wiki`](../skills/research-wiki/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/resubmit-pipeline`](../skills/resubmit-pipeline/SKILL.md) | 流程编排 | 串联多个 skill，把方向、实验、评审和论文推进到阶段产物。 | 读取项目状态，选择下游 skill，输出紧凑记录和下一步。 |
| [`/result-to-claim`](../skills/result-to-claim/SKILL.md) | 评审与审计 | 生成 prompt-only 评审和证据审计产物。 | 写入 review-prompts/，按照独立对话反馈整理行动项。 |
| [`/run-experiment`](../skills/run-experiment/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/semantic-scholar`](../skills/semantic-scholar/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/serverless-modal`](../skills/serverless-modal/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/slides-polish`](../skills/slides-polish/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |
| [`/specification-writing`](../skills/specification-writing/SKILL.md) | 专利 | 围绕发明点、现有技术和法域格式生成专利草案。 | 检索先有技术，结构化发明点，生成权利要求和说明书。 |
| [`/system-profile`](../skills/system-profile/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/training-check`](../skills/training-check/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/vast-gpu`](../skills/vast-gpu/SKILL.md) | 实验与算力 | 准备实验代码、本地轻量检查和 AutoDL/HPC 运行交接。 | 运行本地 tiny checks，写出远程命令块、数据清单和结果回传路径。 |
| [`/wiki-enrich`](../skills/wiki-enrich/SKILL.md) | 文献与知识库 | 检索、整理和补全文献与项目知识。 | 使用本地笔记、论文库和网络检索，保留摘要和证据路径。 |
| [`/writing-systems-papers`](../skills/writing-systems-papers/SKILL.md) | 论文与图表 | 把已审计证据组织成论文、图表、演示和提交前检查。 | 连接证据矩阵、LaTeX、图表脚本和提交前 gate。 |

维护要点：skill 数量、Codex mirror、目录表和库存检查同步更新。
