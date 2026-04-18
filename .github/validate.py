#!/usr/bin/env python3
"""Validate registry YAML files."""
import sys
from pathlib import Path
import yaml

TOOL_REQUIRED = ["id", "name", "type", "description", "github", "arch_map"]
SCRIPT_REQUIRED = ["id", "name", "type", "description", "raw_url"]
VALID_ARCHS = {"amd64", "arm64", "armv7", "arm64v8", "386"}

errors = []

for path in sorted(Path("tools").glob("*.yaml")):
    try:
        with open(path) as f:
            cfg = yaml.safe_load(f)
    except yaml.YAMLError as e:
        errors.append(f"{path}: invalid YAML: {e}")
        continue

    for field in TOOL_REQUIRED:
        if field not in cfg:
            errors.append(f"{path}: missing required field '{field}'")

    if cfg.get("id") != path.stem:
        errors.append(f"{path}: id '{cfg.get('id')}' must match filename '{path.stem}'")

    for arch in cfg.get("arch_map", {}):
        if arch not in VALID_ARCHS:
            errors.append(f"{path}: unknown arch '{arch}' (valid: {', '.join(sorted(VALID_ARCHS))})")
        arch_cfg = cfg["arch_map"][arch]
        if "asset_pattern" not in arch_cfg:
            errors.append(f"{path}: arch '{arch}' missing 'asset_pattern'")

for path in sorted(Path("scripts").glob("*.yaml")):
    try:
        with open(path) as f:
            cfg = yaml.safe_load(f)
    except yaml.YAMLError as e:
        errors.append(f"{path}: invalid YAML: {e}")
        continue

    for field in SCRIPT_REQUIRED:
        if field not in cfg:
            errors.append(f"{path}: missing required field '{field}'")

    if cfg.get("id") != path.stem:
        errors.append(f"{path}: id '{cfg.get('id')}' must match filename '{path.stem}'")

if errors:
    print("Validation failed:")
    for e in errors:
        print(f"  ✗ {e}")
    sys.exit(1)

print(f"All YAMLs valid ({len(list(Path('tools').glob('*.yaml')))} tools, {len(list(Path('scripts').glob('*.yaml')))} scripts)")
