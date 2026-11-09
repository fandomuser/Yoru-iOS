#!/usr/bin/env python3
import os
import sys

def print_file(path, title, count=30, from_head=False):
    if not os.path.exists(path):
        print(f"::warning title={title}::File {path} does not exist")
        return
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            lines = [l.strip() for l in f if l.strip()]
        selected = lines[:count] if from_head else lines[-count:]
        for line in selected:
            escaped = line.replace("%", "%25").replace("\r", "").replace("\n", "%0A")
            print(f"::warning title={title}::{escaped}")
    except Exception as e:
        print(f"::warning title={title}::Error reading {path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 2:
        path = sys.argv[1]
        title = sys.argv[2]
        count = int(sys.argv[3]) if len(sys.argv) > 3 else 30
        head = sys.argv[4].lower() == "head" if len(sys.argv) > 4 else False
        print_file(path, title, count, head)
