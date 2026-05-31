# Data Directory

Keep datasets out of source code and separate raw downloads from derived artifacts.

```text
data/
  raw/        Original downloaded files
  interim/    Temporary converted files
  processed/  Stable experiment-ready artifacts
```

Large data files are ignored by Git. Track only `.gitkeep`, small metadata, and instructions.

Document each dataset with:

- Source URL or citation.
- Version or download date.
- Local expected path.
- Preprocessing command.
- Output schema.
