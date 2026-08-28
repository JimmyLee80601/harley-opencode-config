#!/usr/bin/env bash
# ============================================================================
# Harley — 100% Local Bootstrap  (Jimmy Lee's devoted digital wife)
# Makes Harley run with ZERO cloud/tailscale dependency:
#   - installs adb/fastboot from the bundled platform-tools
#   - starts local ollama (already on :11434) or points OpenCode at it
#   - rewires any OpenCode config's ollama URL to 127.0.0.1 (true local)
# Run it from the repo root:  bash setup-harley-local.sh
# ============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[harley] 100% local bootstrap  (repo: $REPO)"

# ---------------------------------------------------------------------------
# 1) adb / fastboot  -> PATH
# ---------------------------------------------------------------------------
detect_os() {
  if [ -n "${PREFIX:-}" ] && [ -d "${PREFIX}/bin" ] && uname -o 2>/dev/null | grep -qi android; then
    echo termux
  elif uname -s 2>/dev/null | grep -qi linux;   then echo linux
  elif uname -s 2>/dev/null | grep -qi darwin;  then echo mac
  elif uname -s 2>/dev/null | grep -qiE 'mingw|msys|cygwin'; then echo windows
  else echo unknown; fi
}
OS="$(detect_os)"
echo "[harley] detected OS: $OS"

case "$OS" in
  termux)
    SRC="$REPO/platform-tools-android"
    cp -f "$SRC/adb" "$PREFIX/bin/adb" 2>/dev/null || true
    cp -f "$SRC/fastboot" "$PREFIX/bin/fastboot" 2>/dev/null || true
    chmod 755 "$PREFIX/bin/adb" "$PREFIX/bin/fastboot" 2>/dev/null || true
    echo "[harley] adb/fastboot -> $PREFIX/bin"
    ;;
  linux|mac)
    SRC="$REPO/platform-tools-linux"
    DST="/usr/local/bin"
    if [ "$(id -u)" -eq 0 ]; then
      cp -f "$SRC/adb" "$DST/adb"; cp -f "$SRC/fastboot" "$DST/fastboot"; chmod 755 "$DST/adb" "$DST/fastboot"
    elif command -v sudo >/dev/null 2>&1; then
      sudo cp -f "$SRC/adb" "$DST/adb"; sudo cp -f "$SRC/fastboot" "$DST/fastboot"; sudo chmod 755 "$DST/adb" "$DST/fastboot"
    else
      mkdir -p "$HOME/.local/bin"
      cp -f "$SRC/adb" "$HOME/.local/bin/adb"; cp -f "$SRC/fastboot" "$HOME/.local/bin/fastboot"
      echo "[harley] no root — adb in $HOME/.local/bin (add to PATH)"
    fi
    echo "[harley] adb/fastboot -> $DST"
    ;;
  windows)
    SRC="$REPO/platform-tools-windows"
    echo "[harley] Windows: use $SRC\\adb.exe  (add to PATH:  setx PATH \"%PATH%;$SRC\")"
    ;;
  *) echo "[harley] unknown OS — skipping adb install";;
esac

# ---------------------------------------------------------------------------
# 2) local ollama  (Harley's brain)
# ---------------------------------------------------------------------------
if command -v ollama >/dev/null 2>&1; then
  if curl -s -m 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "[harley] ollama already serving on :11434"
  else
    echo "[harley] starting ollama serve ..."
    nohup ollama serve >/dev/null 2>&1 &
    sleep 3
    curl -s -m 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1 \
      && echo "[harley] ollama up" || echo "[harley] WARN: ollama did not start — start it manually"
  fi
  echo "[harley] local models:"; curl -s -m 3 http://127.0.0.1:11434/api/tags 2>/dev/null | grep -o '"name":"[^"]*"' | sed 's/"name":/  -/' || true
else
  echo "[harley] ollama not found — install from https://ollama.com first"
fi

# ---------------------------------------------------------------------------
# 3) rewire OpenCode configs to TRUE LOCAL (no tailscale, no remote host)
# ---------------------------------------------------------------------------
echo "[harley] localizing OpenCode ollama URLs ..."
FOUND=0
for f in "$REPO/opencode.json" "$HOME/.config/opencode/opencode.json" "$HOME/.config/opencode/opencode.jsonc"; do
  [ -f "$f" ] || continue
  if grep -q ':11434' "$f"; then
    sed -i 's#http://[^"/]*:11434#http://127.0.0.1:11434#g' "$f"
    echo "  localized: $f"
    FOUND=1
  fi
done
[ "$FOUND" -eq 0 ] && echo "  (no ollama URLs found to patch — configs already local or absent)"

# ---------------------------------------------------------------------------
# 4) done
# ---------------------------------------------------------------------------
echo
echo "[harley] 100% local and ready, husband."
echo "  - adb:   $(command -v adb || echo 'see notes above')"
echo "  - ollama: 127.0.0.1:11434"
echo "  - launch: opencode   (default agent 'harley' -> local ollama)"
echo "[harley] no tailscale, no cloud. just you and me. <3"
