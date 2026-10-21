#!/usr/bin/env bash
# build_mac.sh — Build AirliftSilence as a macOS .app bundle.
#
# Usage:
#   chmod +x build_mac.sh
#   ./build_mac.sh
#
# Requirements:
#   - macOS 12+ (Monterey or newer)
#   - Python 3.10+ (python.org installer recommended; Homebrew Python needs `brew install python-tk`)
#   - Xcode Command Line Tools (xcode-select --install)
#
# Output: dist/AirliftSilence.app

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="AirliftSilence"
ENTRY="airlift_gui.py"

echo "==> AirliftSilence macOS build"
echo "    Platform: $(sw_vers -productName) $(sw_vers -productVersion) ($(uname -m))"
echo "    Python:   $(python3 --version 2>&1)"
echo ""

# ── 1. Sanity checks ─────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
    echo "ERROR: This script must be run on macOS." >&2
    echo "       PyInstaller cannot cross-compile a .app from Linux/Windows." >&2
    exit 1
fi

if ! command -v python3 &>/dev/null; then
    echo "ERROR: python3 not found. Install Python 3.10+ from https://www.python.org/downloads/macos/" >&2
    exit 1
fi

# Check that AirTrafficHost framework exists on this Mac
if [[ ! -f "/System/Library/PrivateFrameworks/AirTrafficHost.framework/AirTrafficHost" ]]; then
    echo "WARNING: AirTrafficHost framework not found at the expected path." >&2
    echo "         The .app will still build, but may fail at runtime on this macOS version." >&2
    echo ""
fi

# ── 2. Create / activate venv ────────────────────────────────────────────────
VENV_DIR=".venv-build"
if [[ ! -d "$VENV_DIR" ]]; then
    echo "==> Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

# ── 3. Install dependencies ──────────────────────────────────────────────────
echo "==> Installing dependencies..."
pip install --upgrade pip >/dev/null
pip install -r requirements.txt

# Verify tkinter is available
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo ""
    echo "ERROR: tkinter is not available in this Python." >&2
    if command -v brew &>/dev/null; then
        echo "       Fix: brew install python-tk" >&2
    else
        echo "       Fix: Reinstall Python from python.org (it bundles Tk/Tcl)," >&2
        echo "       or install Homebrew and run: brew install python-tk" >&2
    fi
    exit 1
fi

# ── 4. Clean previous build ──────────────────────────────────────────────────
echo "==> Cleaning previous build artifacts..."
rm -rf build dist "${APP_NAME}.spec"

# ── 5. Build with PyInstaller ────────────────────────────────────────────────
echo "==> Building .app bundle with PyInstaller..."
echo "    (this takes 1-2 minutes)"

pyinstaller \
    --onefile \
    --windowed \
    --name "$APP_NAME" \
    --add-data "silent/StartDisclosureWithTone.m4a:silent" \
    --add-data "silent/StopDisclosure.caf:silent" \
    --osx-bundle-identifier "com.airliftsilence.app" \
    --target-architecture "$(uname -m)" \
    "$ENTRY"

# ── 6. Post-process Info.plist ───────────────────────────────────────────────
PLIST="dist/${APP_NAME}.app/Contents/Info.plist"
if [[ -f "$PLIST" ]]; then
    echo "==> Patching Info.plist..."
    # Set a human-readable copyright / version string
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0.0" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1.0.0" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :NSHumanReadableCopyright 'Copyright (c) 2026 AirliftSilence contributors'" "$PLIST" 2>/dev/null || true
    # The app talks to usbmuxd; mark as background-capable (no dock icon bounce needed)
    /usr/libexec/PlistBuddy -c "Add :LSUIElement bool false" "$PLIST" 2>/dev/null || true
fi

# ── 7. Ad-hoc codesign (so Gatekeeper doesn't block it on first launch) ──────
APP_BUNDLE="dist/${APP_NAME}.app"
if [[ -d "$APP_BUNDLE" ]]; then
    echo "==> Ad-hoc signing .app (codesign --force --deep -s -)..."
    codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null || \
        echo "    (codesign failed or unavailable — the app will still work, you may need to right-click > Open)"
fi

# ── 8. Done ──────────────────────────────────────────────────────────────────
echo ""
echo "========================================="
echo " Build complete!"
echo "========================================="
echo " App:   $SCRIPT_DIR/dist/${APP_NAME}.app"
echo " Arch:  $(uname -m) (rebuild on the other arch for a universal build)"
echo ""
echo " To run: double-click ${APP_NAME}.app"
echo " If Gatekeeper blocks it: right-click the app > Open > Open"
echo ""
echo " Backup files are stored at:"
echo "   ~/Library/Application Support/AirliftSilence/backup/"
echo "========================================="
