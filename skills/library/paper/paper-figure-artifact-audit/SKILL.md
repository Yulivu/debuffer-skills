---
name: paper-figure-artifact-audit
description: Audit paper/artifact figures and tables after final results are generated, focusing on visual clarity, caption consistency, numeric provenance, and submission-readiness. Use when the user says "check figures", "visualization audit", "图挤了", "caption/table audit", "artifact figure QA", or "投稿前检查图表".
---

# Paper Figure Artifact Audit

Use this skill after final results are generated and before paper submission,
artifact packaging, or Overleaf upload.

## Workflow

1. Enumerate visuals and tables:
   - PDF/PNG/SVG figures.
   - CSV, Markdown, TeX, and notebook-generated tables.
   - plotting scripts and trace CSV/provenance files.
2. Render PDF figures to PNG previews when visual inspection is needed.
3. Inspect visual clarity:
   - axes, tick labels, legends, colorbars, annotations, panel labels.
   - clipped text and PDF bounding boxes.
   - crowded captions or captions pretending to be x-axis labels.
4. Verify numeric provenance:
   - table values match current trace CSVs or promoted result files.
   - figure curves/bars are generated from current final results.
   - no old package data is silently reused.
5. Check captions:
   - caption describes what the figure/table actually measures.
   - caption does not strengthen the claim beyond the data.
   - metric names are consistent across paper, artifact, and trace files.
6. Distinguish metrics carefully:
   - latency speedup.
   - storage ratio.
   - fidelity/quality.
   - recall.
   - break-even or amortization metrics.
7. Fix visuals by editing plotting code/specs when possible, then regenerate.
   Avoid manual edits to generated PDFs.
8. Re-render previews and rerun checks before marking ready.

## Visual Checks

- Legends must not cover data lines.
- Colorbars need labels separate from axes.
- X-axis labels must not look like panel captions.
- Multiline tick labels must remain readable.
- Heatmap annotation text must contrast with cell colors.
- PDF bounding boxes must not clip labels, legends, or captions.
- Any text inside figures should match the paper body font size unless the venue
  requires a documented exception.

## Guardrails

- Do not alter numeric results during visual fixes.
- Do not change captions to stronger claims than the data supports.
- Public artifact visuals must stay clean and English.
- Internal writing visuals can match public visuals, but READMEs may differ.
- If provenance cannot be established, mark the item as blocked instead of
  approving it.
