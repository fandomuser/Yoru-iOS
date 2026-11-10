#!/usr/bin/env python3
import os
import sys

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    bazel_rules = os.path.join(root, 'build-system', 'bazel-rules')
    
    print("=== Patching Bazel rules for Xcode 16 compatibility ===")
    count_bzl = 0
    for dirpath, _, filenames in os.walk(bazel_rules):
        for f in filenames:
            if f.endswith('.bzl'):
                p = os.path.join(dirpath, f)
                with open(p, 'r', encoding='utf-8') as fp:
                    content = fp.read()
                if '"26.0"' in content:
                    content = content.replace('"26.0"', '"16.0"')
                    with open(p, 'w', encoding='utf-8') as fp:
                        fp.write(content)
                    count_bzl += 1
                    print(f"Patched 26.0 -> 16.0 in: {os.path.relpath(p, root)}")
    print(f"Total .bzl files patched: {count_bzl}")

    # Patch plisttool.py for expired fake certificates
    plisttool_path = os.path.join(bazel_rules, 'rules_apple', 'tools', 'plisttool', 'plisttool.py')
    if os.path.exists(plisttool_path):
        with open(plisttool_path, 'r', encoding='utf-8') as fp:
            c = fp.read()
        target = "if expire and expire < datetime.datetime.now():"
        if target in c:
            c = c.replace(target, "if False:")
            with open(plisttool_path, 'w', encoding='utf-8') as fp:
                fp.write(c)
            print("Patched plisttool.py to ignore expired fake provisioning profile")

    # Patch actool.bzl so --app-icon is only passed for .appiconset (not .icon bundles)
    actool_path = os.path.join(bazel_rules, 'rules_apple', 'apple', 'internal', 'resource_actions', 'actool.bzl')
    if os.path.exists(actool_path):
        with open(actool_path, 'r', encoding='utf-8') as fp:
            c = fp.read()
        old_actool = 'app_icon_name = _unique_icon_names(all_icon_dirs = icon_dirs + icon_bundle_dirs).pop()\n            args += ["--app-icon", app_icon_name]'
        new_actool = 'if icon_dirs:\n                app_icon_name = _unique_icon_names(all_icon_dirs = icon_dirs).pop()\n                args += ["--app-icon", app_icon_name]'
        if old_actool in c:
            c = c.replace(old_actool, new_actool)
            with open(actool_path, 'w', encoding='utf-8') as fp:
                fp.write(c)
            print("Patched actool.bzl to avoid passing invalid --app-icon for Icon Composer bundles")
        else:
            print("Note: actool.bzl target already patched or not found")

    # Patch alticonstool.py so CFBundleIcons dictionary is created if missing
    alticonstool_path = os.path.join(bazel_rules, 'rules_apple', 'tools', 'alticonstool', 'alticonstool.py')
    if os.path.exists(alticonstool_path):
        with open(alticonstool_path, 'r', encoding='utf-8') as fp:
            c = fp.read()
        target_iphone = 'plist_data["CFBundleIcons"]["CFBundleAlternateIcons"] = alticons_data'
        target_ipad = 'plist_data["CFBundleIcons~ipad"]["CFBundleAlternateIcons"] = alticons_data'
        rep_iphone = 'plist_data.setdefault("CFBundleIcons", {})["CFBundleAlternateIcons"] = alticons_data'
        rep_ipad = 'plist_data.setdefault("CFBundleIcons~ipad", {})["CFBundleAlternateIcons"] = alticons_data'
        if target_iphone in c:
            c = c.replace(target_iphone, rep_iphone).replace(target_ipad, rep_ipad)
            with open(alticonstool_path, 'w', encoding='utf-8') as fp:
                fp.write(c)
            print("Patched alticonstool.py to use setdefault for CFBundleIcons")

if __name__ == '__main__':
    main()
