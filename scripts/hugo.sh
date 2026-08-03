#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIN_HUGO_VERSION="0.164.0"

version_ge() {
  awk -v current="$1" -v required="$2" 'BEGIN {
    split(current, c, ".");
    split(required, r, ".");
    for (i = 1; i <= 3; i++) {
      cv = c[i] + 0;
      rv = r[i] + 0;
      if (cv > rv) exit 0;
      if (cv < rv) exit 1;
    }
    exit 0;
  }'
}

requested_hugo_version="${HUGO_VERSION:-$MIN_HUGO_VERSION}"
if version_ge "$requested_hugo_version" "$MIN_HUGO_VERSION"; then
  REQUIRED_HUGO_VERSION="$requested_hugo_version"
else
  REQUIRED_HUGO_VERSION="$MIN_HUGO_VERSION"
fi

HUGO_INSTALL_DIR="${PROJECT_ROOT}/.hugo-bin/${REQUIRED_HUGO_VERSION}"
HUGO_BIN="${HUGO_INSTALL_DIR}/hugo"

hugo_version() {
  "$1" version 2>/dev/null | sed -E 's/^hugo v([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
}

hugo_is_extended() {
  "$1" version 2>/dev/null | grep -qi 'extended'
}

hugo_is_usable() {
  local candidate="$1"
  local version

  if ! command -v "$candidate" >/dev/null 2>&1 && [ ! -x "$candidate" ]; then
    return 1
  fi

  version="$(hugo_version "$candidate")"
  [ -n "$version" ] || return 1
  version_ge "$version" "$REQUIRED_HUGO_VERSION" || return 1
  hugo_is_extended "$candidate" || return 1
}

if hugo_is_usable "hugo"; then
  exec hugo "$@"
fi

if [ -x "$HUGO_BIN" ] && hugo_is_usable "$HUGO_BIN"; then
  exec "$HUGO_BIN" "$@"
fi

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64|Linux-amd64)
    HUGO_ARCHIVE="hugo_extended_${REQUIRED_HUGO_VERSION}_linux-amd64.tar.gz"
    ;;
  Linux-aarch64|Linux-arm64)
    HUGO_ARCHIVE="hugo_extended_${REQUIRED_HUGO_VERSION}_linux-arm64.tar.gz"
    ;;
  *)
    echo "Hugo Extended ${REQUIRED_HUGO_VERSION}+ is required." >&2
    echo "Install Hugo Extended locally, or run the build in Linux so this script can download it." >&2
    exit 1
    ;;
esac

HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${REQUIRED_HUGO_VERSION}/${HUGO_ARCHIVE}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$HUGO_INSTALL_DIR"
echo "Installing Hugo Extended ${REQUIRED_HUGO_VERSION} from ${HUGO_URL}"
curl -fsSL --retry 3 --retry-delay 2 -o "${TMP_DIR}/${HUGO_ARCHIVE}" "$HUGO_URL"
tar -xzf "${TMP_DIR}/${HUGO_ARCHIVE}" -C "$HUGO_INSTALL_DIR" hugo
chmod +x "$HUGO_BIN"

exec "$HUGO_BIN" "$@"
