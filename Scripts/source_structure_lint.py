#!/usr/bin/env bash
#!/usr/bin/env python3
"""
YORU (夜) — Source Structure and Token Linter
=============================================================================
IMPORTANT: This script performs lexical regular-expression scanning and
bracket balance verification only. It DOES NOT perform Swift AST parsing,
symbol resolution, or type checking. It is designed to catch simple syntax
regressions (e.g., accidental Objective-C string literals or unmatched braces)
on non-macOS workstations before code is submitted to Xcode/CI.

Actual Swift compilation is performed exclusively by swiftc / xcodebuild
in the macOS build environment.
=============================================================================
"""

import os
import re
import sys

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    targets = [os.path.join(root, "Yoru"), os.path.join(root, "Tests")]
    
    errors = []
    total_files = 0
    
    objc_pattern = re.compile(r'(@\"|\b@\[)')
    
    for target in targets:
        for dirpath, _, filenames in os.walk(target):
            for f in filenames:
                if f.endswith('.swift'):
                    total_files += 1
                    full_path = os.path.join(dirpath, f)
                    rel_path = os.path.relpath(full_path, root)
                    with open(full_path, 'r', encoding='utf-8') as fp:
                        content = fp.read()
                    
                    if objc_pattern.search(content):
                        errors.append(f"{rel_path}: Contains invalid Objective-C literal syntax (@\" or @[)")
                    
                    open_b = content.count('{')
                    close_b = content.count('}')
                    if open_b != close_b:
                        errors.append(f"{rel_path}: Mismatched braces (open: {open_b}, close: {close_b})")

    print(f"Scanned {total_files} Swift source files across Yoru and Tests.")
    if errors:
        print(f"[!] FAILED: Found {len(errors)} lexical syntax defects:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)
    else:
        print(f"[+] LINT PASSED: All {total_files} Swift files passed lexical token and delimiter scanning.")
        print("    [NOTE] This is a pre-commit lexical sanity check, NOT Swift compilation.")
        print("    [NOTE] Official compilation is executed via Xcode / swiftc on macOS.")

if __name__ == "__main__":
    main()
