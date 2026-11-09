#!/usr/bin/env python3
"""
Reads the tail of a log file and emits each line as a GitHub Actions workflow error annotation.
"""
import sys

if len(sys.argv) < 2:
    sys.exit(0)

log_path = sys.argv[1]
try:
    with open(log_path, "r", encoding="utf-8", errors="replace") as f:
        lines = [line.strip() for line in f if line.strip()]
        for l in lines[-25:]:
            print(f"::error::{l}")
except Exception as e:
    print(f"::error::Failed reading {log_path}: {e}")
