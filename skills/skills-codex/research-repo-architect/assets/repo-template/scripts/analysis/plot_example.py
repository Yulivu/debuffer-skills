from __future__ import annotations

import argparse
import json
from pathlib import Path

import matplotlib.pyplot as plt


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate an example PDF figure.")
    parser.add_argument("--input", required=True, help="Path to metrics.json.")
    parser.add_argument("--out-dir", default="experiments/visualizations/exp1")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    metrics_path = Path(args.input)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    metrics = json.loads(metrics_path.read_text(encoding="utf-8"))
    labels = ["rmse"]
    values = [float(metrics["rmse"])]

    fig, ax = plt.subplots(figsize=(4, 3))
    ax.bar(labels, values, color="#4C78A8")
    ax.set_ylabel("Value")
    ax.set_title("Example Experiment Metric")
    fig.tight_layout()

    output = out_dir / "exp1_example_metric.pdf"
    fig.savefig(output)
    plt.close(fig)

    summary = out_dir / "exp1_example_metric_summary.csv"
    summary.write_text(f"metric,value\nrmse,{values[0]}\n", encoding="utf-8")
    print(f"wrote {output}")
    print(f"wrote {summary}")


if __name__ == "__main__":
    main()
