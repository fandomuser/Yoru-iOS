#!/usr/bin/env python3
"""
Captures log tail, prints GitHub workflow annotations, and posts the log
as a public commit comment so it can be retrieved without repository admin rights.
"""
import os
import sys
import json
import urllib.request

if len(sys.argv) < 2:
    sys.exit(0)

log_path = sys.argv[1]
lines = []
try:
    with open(log_path, "r", encoding="utf-8", errors="replace") as f:
        lines = [line.strip() for line in f if line.strip()]
except Exception as e:
    lines = [f"Failed to read {log_path}: {e}"]

tail_lines = lines[-80:]
log_content = "\n".join(tail_lines)

# 1. Print workflow commands
for l in tail_lines[-20:]:
    msg = l.replace("%", "%25").replace("\r", "").replace("\n", "%0A")
    print(f"::error file=Package.swift,line=1::{msg}")

# 2. Post as commit comment if token is present
sha = os.environ.get("GITHUB_SHA", "")
repo = os.environ.get("GITHUB_REPOSITORY", "")
token = os.environ.get("GITHUB_TOKEN", "")

if sha and repo and token:
    try:
        url = f"https://api.github.com/repos/{repo}/commits/{sha}/comments"
        body_text = f"### CI Failure Log for `{log_path}` (Run {os.environ.get('GITHUB_RUN_NUMBER', '')})\n```text\n{log_content}\n```"
        payload = json.dumps({"body": body_text}).encode("utf-8")
        req = urllib.request.Request(
            url,
            data=payload,
            headers={
                "Authorization": f"token {token}",
                "User-Agent": "Yoru-CI-Reporter",
                "Accept": "application/vnd.github.v3+json",
                "Content-Type": "application/json"
            }
        )
        with urllib.request.urlopen(req) as resp:
            print(f"[+] Posted failure log comment to commit {sha[:8]} (HTTP {resp.status})")
    except Exception as e:
        print(f"[!] Could not post commit comment: {e}")
