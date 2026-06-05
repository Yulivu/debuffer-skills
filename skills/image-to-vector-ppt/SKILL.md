---
name: image-to-vector-ppt
description: "Redraw reference screenshots, PNG, or JPG figures as editable PowerPoint vector figures and export sharp PDF output. Use when the user wants an academic figure recreated in PPT/PPTX/PDF with editable text, native Office Math formulas, close visual fidelity, and no visible raster base layer in the final deliverable."
---

# Image To Vector PPT

## Goal

Rebuild a reference figure as an editable PowerPoint artifact using native PPT objects, then export a PDF that stays sharp under zoom.

Use this when the source is a screenshot or bitmap figure and the user wants a deliverable that remains editable in PowerPoint instead of a pasted image.

## Hard Rules

- Visible content must be native PowerPoint objects: shapes, connectors, freeforms, text boxes, tables, and Office Math.
- Do not leave the source image, SVG, EMF, or PNG as the visible final base layer.
- Formulas must use Office Math when they are part of the visible figure. Do not ship formula PNGs as the visible answer.
- Final PPTX should not contain visible `<p:pic>` slide objects for the recreated figure.
- Final PDF should not degrade into a full-page raster figure.
- Preserve source aspect ratio and relative layout. Do not stretch to fit a convenient slide size.
- Fix geometry or object placement directly. Do not cover mistakes with white patches or masking hacks.
- Keep normal text editable. Match the requested manuscript font where applicable; formulas may use Cambria Math.

## Workflow

1. Inspect the reference carefully.
   - Identify containers, groups, arrows, icons, formulas, tables, legends, and repeated blocks.
   - Note any user-requested deletion or modification before drawing.

2. Set up the slide around the figure.
   - Match slide aspect ratio to the source figure bounds.
   - Use fixed coordinates and shared dimensions for repeated elements.
   - Remove accidental outer white margins by sizing the slide to the real content.

3. Rebuild the figure with native PPT primitives.
   - Draw large containers first, then inner boxes, then arrows, then text, then formulas.
   - Set rounded-rectangle adjustment explicitly; do not rely on PowerPoint defaults.
   - Small boxes should not become pills unless the reference is actually pill-shaped.

4. Handle text defensively.
   - Use fixed `Left`, `Top`, `Width`, and `Height`.
   - Disable harmful autosize behavior where layout must stay stable.
   - Set vertical anchoring deliberately and leave enough internal padding.
   - Reserve extra left padding when labels share space with icons or bullets.

5. Handle connectors defensively.
   - Arrowheads should stop at borders instead of entering text regions.
   - Curved or forked connectors may need slight overlap at joints to avoid PDF hairline gaps.
   - Do not allow arrows to cover text, formulas, icons, or borders.

6. Handle formulas as native math.
   - Insert equations as Office Math objects.
   - Keep them above background shapes.
   - Remove duplicate placeholder text or vector traces left over from temporary extraction steps.

7. QA from rendered output, not package structure alone.
   - Export slide previews to PNG at source resolution or higher.
   - Compare both full-slide layout and zoomed crops against the reference.
   - Check overflow, centering drift, inconsistent radii, arrow collisions, and alignment breaks.

8. Export and verify.
   - Export PPTX to PDF from PowerPoint.
   - Inspect the PDF for visible rasterization.
   - Inspect the PPTX package for Office Math presence and absence of visible image-backed slide content.

## Validation Checklist

- No text extends outside its intended box.
- Repeated blocks share consistent size, padding, and corner radius.
- Arrowheads do not intrude into readable text.
- Row and lane contents are vertically centered where expected.
- Formulas render correctly and remain editable.
- Final PDF stays sharp under zoom.
- Final PPTX remains editable and structurally valid.

## Common Failure Modes

- Default rounded rectangles are too round.
- Text boxes silently autosize and drift away from container geometry.
- Arrowheads enter boxes and cover labels.
- Local alignment fixes break icon padding elsewhere.
- Formula fallbacks look acceptable in preview but blur in PDF export.
- SVG or EMF content survives as a hidden rasterized dependency in export.
