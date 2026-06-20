---
name: final-experiment-curator
description: Turn a messy research experiment history into a claim-driven final experiment set before submission. Use when the user says "choose final experiments", "clean old experiment package", "decide what belongs in final artifact", "prune research experiments", "投稿前挑实验", or "清理旧实验".
---

# Final Experiment Curator

Use this skill when a project has old runs, exploratory packages, abandoned
datasets, reviewer/debug experiments, or multiple artifact versions, and the
user needs a final evidence set for a paper or artifact.

Do not run heavy experiments. Audit and classify existing evidence; propose
missing work only when a final claim lacks support.

## Workflow

1. Inspect the current state:
   - `git status --short`
   - `rg --files experiments data paper docs | sort`
   - existing claim docs such as `CLAIMS_FROM_RESULTS.md`,
     `EVIDENCE_LEDGER.md`, `PAPER_GUIDE.md`, `NEXT_ACTIONS.md`, and paper
     draft files.
2. Extract the final paper claims. If claims are not explicit, draft a small
   provisional claim list and mark it as provisional.
3. Inventory experiments, tables, figures, datasets, result packages, and
   trace files. Keep raw run paths distinct from promoted/final packages.
4. Map each item to claims:
   - claim id
   - artifact path
   - metric or table/figure role
   - provenance path
   - current/stale/unknown status
   - inclusion decision
5. Classify every item as one of:
   - `keep-main`: necessary for a main-paper claim.
   - `keep-appendix`: useful support but not needed in the main narrative.
   - `internal-only`: useful for writing, rebuttal, or provenance but not
     public artifact content.
   - `archive`: historical, superseded, or exploratory; preserve only if useful.
   - `delete`: generated junk or obsolete output, only after user approval.
6. Detect stale evidence:
   - old datasets that no final claim uses.
   - old baselines replaced by current baselines.
   - appendix traces copied from a prior package.
   - exploratory outputs mixed into submission packages.
   - final package files whose numbers do not match current traces.
7. Produce a compact decision summary in chat. Write files only when the user
   asks.

## Optional Outputs

When asked to write artifacts, prefer:

- `final_claims.md`
- `experiment_inclusion_matrix.md`
- `artifact_keep_delete_plan.md`

Each excluded item must include a reason, not just a decision.

## Guardrails

- Do not include experiments just because they exist.
- Do not preserve old outputs if they do not support final claims.
- Do not mix old exploratory packages with final submission artifacts.
- Prefer a smaller coherent evidence set over a large historical dump.
- Never delete backups, raw runs, or user notes without explicit approval.
- If the final claim set is unclear, stop at a provisional matrix and ask the
  user to accept or edit the claims before curation.
