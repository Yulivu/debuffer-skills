from __future__ import annotations

import argparse
import json
import platform
import random
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import yaml


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run a tiny example experiment.")
    parser.add_argument("--config", required=True, help="Path to YAML config.")
    parser.add_argument("--out-dir", default=None, help="Output directory.")
    parser.add_argument("--set", action="append", default=[], dest="overrides")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    started = time.perf_counter()
    config = load_config(Path(args.config), args.overrides)
    out_dir = Path(args.out_dir or config.get("output_dir", "experiments/runs/example"))
    seed = int(config.get("random_seed", 0))
    random.seed(seed)

    dataset = config.get("dataset", {})
    num_samples = int(dataset.get("num_samples", 32))
    noise = float(dataset.get("noise", 0.0))
    observations = [1.0 + random.uniform(-noise, noise) for _ in range(num_samples)]
    prediction = sum(observations) / len(observations)
    rmse = (sum((value - prediction) ** 2 for value in observations) / len(observations)) ** 0.5

    metrics = {
        "num_samples": num_samples,
        "prediction": prediction,
        "rmse": rmse,
    }
    summary = f"# Example Experiment\n\n- samples: {num_samples}\n- rmse: {rmse:.6f}\n"
    write_outputs(
        out_dir=out_dir,
        metrics=metrics,
        summary=summary,
        config_path=Path(args.config),
        config=config,
        started_at=started,
    )
    print(json.dumps(metrics, indent=2))


def load_config(path: Path, overrides: list[str]) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        config = yaml.safe_load(handle) or {}
    if not isinstance(config, dict):
        raise ValueError(f"Config must be a mapping: {path}")
    for override in overrides:
        key, value = split_override(override)
        apply_dotted_override(config, key, parse_scalar(value))
    return config


def split_override(value: str) -> tuple[str, str]:
    if "=" not in value:
        raise ValueError(f"Override must use key=value syntax: {value}")
    key, raw = value.split("=", 1)
    return key.strip(), raw.strip()


def parse_scalar(value: str) -> Any:
    try:
        return yaml.safe_load(value)
    except yaml.YAMLError:
        return value


def apply_dotted_override(config: dict[str, Any], key: str, value: Any) -> None:
    current = config
    parts = key.split(".")
    for part in parts[:-1]:
        next_value = current.setdefault(part, {})
        if not isinstance(next_value, dict):
            raise ValueError(f"Cannot override through non-mapping key: {key}")
        current = next_value
    current[parts[-1]] = value


def write_outputs(
    *,
    out_dir: Path,
    metrics: dict[str, Any],
    summary: str,
    config_path: Path,
    config: dict[str, Any],
    started_at: float,
) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "metrics.json").write_text(
        json.dumps(metrics, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    (out_dir / "summary.md").write_text(summary, encoding="utf-8")
    (out_dir / "resolved_config.yaml").write_text(
        yaml.safe_dump(config, sort_keys=False),
        encoding="utf-8",
    )
    metadata = {
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "command": sys.argv,
        "config_path": str(config_path),
        "outputs": {
            "out_dir": str(out_dir),
            "metrics": "metrics.json",
            "summary": "summary.md",
            "resolved_config": "resolved_config.yaml",
            "metadata": "run_metadata.json",
        },
        "timing": {"duration_seconds": time.perf_counter() - started_at},
        "python": {"version": sys.version, "executable": sys.executable},
        "platform": {
            "system": platform.system(),
            "release": platform.release(),
            "machine": platform.machine(),
        },
        "git": git_metadata(),
    }
    (out_dir / "run_metadata.json").write_text(
        json.dumps(metadata, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


def git_metadata() -> dict[str, str | bool | None]:
    return {
        "branch": git_output(["git", "rev-parse", "--abbrev-ref", "HEAD"]),
        "commit": git_output(["git", "rev-parse", "HEAD"]),
        "dirty": bool(git_output(["git", "status", "--porcelain"])),
    }


def git_output(command: list[str]) -> str | None:
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
    except (OSError, subprocess.CalledProcessError):
        return None
    return result.stdout.strip()


if __name__ == "__main__":
    main()
