#!/usr/bin/env python3
"""
Reads the tail of a log file and emits each line as a GitHub Actions workflow error annotation
targeted at Package.swift so GitHub check-runs API captures and returns it publicly.
"""
import sys

if len(sys.argv) < 2:
    sys.exit(0)

log_path = sys.argv[1]
try:
    with open(log_path, "r", encoding="utf-8", errors="replace") as f:
        lines = [line.strip() for line in f if line.strip()]
        # Emit last 30 lines
        for l in lines[-30:]:
            # Escape newlines or colons for workflow command
            msg = l.replace("%", "%25").replace("\r", "").replace("\n", "%0A")
            print(f"::error file=Package.swift,line=1::{msg}")
except Exception as e:
    print(f"::error file=Package.swift,line=1::Failed reading {log_path}: {e}")
