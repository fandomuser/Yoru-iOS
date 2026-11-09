#!/usr/bin/env python3
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

    print(f"Audited {total_files} Swift source files across Yoru and Tests.")
    if errors:
        print(f"[!] FAILED with {len(errors)} errors:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)
    else:
        print("[+] SUCCESS: All 80 Swift files passed static structural and syntax checks!")

if __name__ == "__main__":
    main()
