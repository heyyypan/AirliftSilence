#!/usr/bin/env bash
# run_from_source_mac.sh — Run AirliftSilence directly from source on macOS.
#
# Usage:
#   chmod +x run_from_source_mac.sh
#   ./run_from_source_mac.sh
#
# This is the fastest way to test without building a .app.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ "$(uname)" != "Darwin" ]]; then
    echo "ERROR: This script is for macOS only." >&2
    exit 1
fi

VENV_DIR=".venv-run"
if [[ ! -d "$VENV_DIR" ]]; then
    echo "==> Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip >/dev/null
    pip install pymobiledevice3
else
    source "$VENV_DIR/bin/activate"
fi

echo "==> Launching AirliftSilence GUI..."
python3 airlift_gui.py
