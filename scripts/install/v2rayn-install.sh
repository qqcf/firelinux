#!/bin/bash
# v2rayN installer — downloads full release zip to /opt/v2rayN/
# https://github.com/2dust/v2rayN

set -euo pipefail

_info()  { printf '\033[0;32m[v2rayN]\033[0m %s\n' "$*"; }
_error() { printf '\033[0;31m[v2rayN]\033[0m %s\n' "$*" >&2; exit 1; }

INSTALL_DIR="/opt/v2rayN"
GITHUB_API="https://api.github.com/repos/2dust/v2rayN/releases/latest"

detect_arch() {
    local machine
    machine=$(uname -m)
    case "$machine" in
        x86_64)  echo "linux-64" ;;
        aarch64) echo "linux-arm64" ;;
        *) _error "Unsupported architecture: $machine" ;;
    esac
}

main() {
    command -v curl &>/dev/null || _error "curl is required"
    command -v unzip &>/dev/null || _error "unzip is required"

    local arch asset_name download_url version
    arch=$(detect_arch)

    _info "Fetching latest release info..."
    local release_json
    release_json=$(curl -fsSL "$GITHUB_API") || _error "Failed to fetch release info"

    version=$(echo "$release_json" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
    asset_name="v2rayN-${arch}.zip"
    download_url=$(echo "$release_json" | grep -o "\"browser_download_url\": *\"[^\"]*${asset_name}\"" | head -1 | cut -d'"' -f4)

    [ -n "$download_url" ] || _error "Could not find download URL for $asset_name"

    _info "Installing v2rayN $version ($arch)..."

    local tmp_zip
    tmp_zip=$(mktemp /tmp/v2rayn.XXXXXX.zip)
    trap 'rm -f "$tmp_zip"' EXIT

    _info "Downloading $asset_name..."
    curl -fsSL -o "$tmp_zip" "$download_url" || _error "Download failed: $download_url"

    _info "Extracting to $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    local inner_dir="v2rayN-${arch}"
    unzip -q "$tmp_zip" -d /tmp/v2rayn_extract/
    if [ -d "/tmp/v2rayn_extract/$inner_dir" ]; then
        mv /tmp/v2rayn_extract/"$inner_dir"/* "$INSTALL_DIR/"
    else
        mv /tmp/v2rayn_extract/* "$INSTALL_DIR/"
    fi
    rm -rf /tmp/v2rayn_extract/

    chmod +x "$INSTALL_DIR/v2rayN"

    ln -sf "$INSTALL_DIR/v2rayN" /usr/local/bin/v2rayN

    _info "v2rayN $version installed to $INSTALL_DIR"
    _info "Run: v2rayN"
}

main "$@"
