# firelinux registry

Public tool registry for [firelinux.com](https://firelinux.com) — one-command Linux binary installer.

## Adding a tool

Submit a PR adding a YAML file to `tools/` or `scripts/`.

### Binary tool schema (`tools/<id>.yaml`)

```yaml
id: ripgrep
name: ripgrep
alias: rg                         # optional short name for install command
type: binary
description: "Fast regex search tool"
tags: [search, text, development]
github: BurntSushi/ripgrep
homepage: https://github.com/BurntSushi/ripgrep
binary_name: rg                   # name of the extracted binary
arch_map:
  amd64:
    asset_pattern: "x86_64-unknown-linux-musl.tar.gz"
    binary_path: "rg"             # path inside archive, or filename if single binary
  arm64:
    asset_pattern: "aarch64-unknown-linux-gnu.tar.gz"
    binary_path: "rg"
  armv7:
    asset_pattern: "arm-unknown-linux-gnueabihf.tar.gz"
    binary_path: "rg"
```

`asset_pattern` is a substring matched against GitHub release asset filenames.

Set `is_single_binary: true` if the asset is the binary itself (not an archive).

### Script schema (`scripts/<id>.yaml`)

```yaml
id: sys_info
name: sys_info
type: script
interpreter: bash
description: "System information report"
tags: [system, info]
author: yourname
source_url: "https://github.com/yourname/scripts/blob/main/sys_info.sh"
raw_url: "https://raw.githubusercontent.com/yourname/scripts/main/sys_info.sh"
```

## Install a tool

```bash
curl -fsSL https://firelinux.com/get/ripgrep | bash
curl -fsSL https://firelinux.com/get/rg | bash          # alias
curl -fsSL https://firelinux.com/get/ripgrep@14.1.1 | bash  # pin version
```
