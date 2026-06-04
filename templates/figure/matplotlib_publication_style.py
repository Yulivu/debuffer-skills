"""Lightweight publication figure style for matplotlib.

Inspired by MLNLP-World/Paper-Picture-Writing-Code, but normalized for this
skills repo: vector-first export, restrained styling, and body-font-matched
typography.
"""

from __future__ import annotations

from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt


def apply_paper_style(
    body_font_size_pt: float = 10.0,
    font_family: str = "Times New Roman",
    dpi: int = 300,
    use_tex: bool = False,
) -> None:
    matplotlib.rcParams.update(
        {
            "font.size": body_font_size_pt,
            "font.family": "serif",
            "font.serif": [font_family, "Times", "Nimbus Roman", "DejaVu Serif"],
            "axes.labelsize": body_font_size_pt,
            "axes.titlesize": body_font_size_pt,
            "xtick.labelsize": body_font_size_pt,
            "ytick.labelsize": body_font_size_pt,
            "legend.fontsize": body_font_size_pt,
            "figure.dpi": dpi,
            "savefig.dpi": dpi,
            "savefig.bbox": "tight",
            "savefig.pad_inches": 0.04,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
            "svg.fonttype": "none",
            "axes.grid": False,
            "axes.spines.top": False,
            "axes.spines.right": False,
            "mathtext.fontset": "stix",
            "text.usetex": use_tex,
        }
    )


def save_publication_figure(fig: plt.Figure, output_path: str | Path) -> None:
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_path)
