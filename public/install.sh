#!/bin/sh
# Install the latest PUV release from github.com/haasele/puv.
# Usage: curl -fsSL https://puv.haasele.dev/install.sh | sh
set -eu

REPO="haasele/puv"
DEST="${PUV_INSTALL_DIR:-${HOME}/.local/bin}"

say() { printf '%s\n' "$*"; }
die() { printf '%s\n' "$*" >&2; exit 1; }

if [ "$(uname -s)" != "Linux" ]; then
  die "Published PUV builds are Linux glibc binaries (x86_64 and aarch64). Other systems: build from https://github.com/${REPO}"
fi

case "$(uname -m)" in
  x86_64) target="x86_64-unknown-linux-gnu" ;;
  aarch64 | arm64) target="aarch64-unknown-linux-gnu" ;;
  *) die "Unsupported architecture: $(uname -m)" ;;
esac

asset="puv-${target}.tar.gz"
url="https://github.com/${REPO}/releases/latest/download/${asset}"
sums_url="https://github.com/${REPO}/releases/latest/download/sha256sums.txt"

command -v curl >/dev/null 2>&1 || die "curl is required"
command -v tar >/dev/null 2>&1 || die "tar is required"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

say "Fetching the latest release asset: ${asset}"
if ! curl -fL --retry 3 --retry-delay 1 -o "${tmp}/asset.tar.gz" "$url"; then
  die "No ${asset} on the latest GitHub release of ${REPO}. Build from source: git clone https://github.com/${REPO} && cargo install --path ${REPO##*/}/crates/puv --locked"
fi

if curl -fsSL -o "${tmp}/sha256sums.txt" "$sums_url"; then
  expected=$(awk -v name="$asset" '$2 == name { print $1; exit }' "${tmp}/sha256sums.txt")
  if [ -n "${expected}" ]; then
    if command -v sha256sum >/dev/null 2>&1; then
      actual=$(sha256sum "${tmp}/asset.tar.gz" | awk '{ print $1 }')
    elif command -v shasum >/dev/null 2>&1; then
      actual=$(shasum -a 256 "${tmp}/asset.tar.gz" | awk '{ print $1 }')
    else
      actual=""
    fi
    if [ -n "${actual}" ] && [ "${actual}" != "${expected}" ]; then
      die "Checksum mismatch for ${asset}"
    fi
    if [ -n "${actual}" ]; then
      say "Checksum matched sha256sums.txt"
    fi
  fi
fi

tar -xzf "${tmp}/asset.tar.gz" -C "$tmp"
bin=$(find "$tmp" -type f -name puv | head -n 1)
[ -n "${bin}" ] || die "Archive did not contain a file named puv"

mkdir -p "$DEST"
if command -v install >/dev/null 2>&1; then
  install -m 755 "$bin" "${DEST}/puv"
else
  cp "$bin" "${DEST}/puv"
  chmod 755 "${DEST}/puv"
fi

say "Installed ${DEST}/puv"
case ":$PATH:" in
  *":${DEST}:"*) ;;
  *) say "Add ${DEST} to PATH if this shell cannot see it." ;;
esac

"${DEST}/puv" --version
