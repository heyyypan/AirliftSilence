#!/bin/bash
# 双击构建.app.command —— 一键打包成 macOS .app 应用
# 在 Mac 上双击此文件即可。如果提示"无法打开"，右键 → 打开。

cd "$(dirname "$0")"

echo "========================================="
echo "  AirliftSilence — 构建 .app 应用"
echo "========================================="
echo ""

# 检查是否在 macOS 上
if [ "$(uname)" != "Darwin" ]; then
    echo "错误：此脚本必须在 macOS 上运行。"
    read -p "按回车键退出..."
    exit 1
fi

# 检查 Python
if ! command -v python3 &>/dev/null; then
    echo "错误：未找到 python3。"
    echo "请先安装 Python 3.10+：https://www.python.org/downloads/macos/"
    read -p "按回车键退出..."
    exit 1
fi

echo "系统：$(sw_vers -productName) $(sw_vers -productVersion) ($(uname -m))"
echo "Python：$(python3 --version 2>&1)"
echo ""

# 检查 AirTrafficHost 框架
if [ ! -f "/System/Library/PrivateFrameworks/AirTrafficHost.framework/AirTrafficHost" ]; then
    echo "警告：未检测到 AirTrafficHost 系统框架。"
    echo "      .app 仍会构建，但运行时可能报错。"
    echo ""
fi

# 创建虚拟环境
if [ ! -d ".venv-build" ]; then
    echo "正在创建虚拟环境..."
    python3 -m venv .venv-build
fi
source .venv-build/bin/activate

echo "正在安装依赖（约 1-2 分钟）..."
pip install --upgrade pip >/dev/null
pip install -r requirements.txt

# 验证 tkinter
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo ""
    echo "错误：当前 Python 没有 tkinter。"
    if command -v brew &>/dev/null; then
        echo "解决方法：brew install python-tk"
    else
        echo "解决方法：从 python.org 重新安装 Python（自带 tkinter）"
    fi
    read -p "按回车键退出..."
    exit 1
fi

# 清理旧构建
rm -rf build dist AirliftSilence.spec

echo ""
echo "正在用 PyInstaller 打包 .app（约 2-3 分钟）..."
echo ""

pyinstaller \
    --onefile \
    --windowed \
    --name AirliftSilence \
    --add-data "silent/StartDisclosureWithTone.m4a:silent" \
    --add-data "silent/StopDisclosure.caf:silent" \
    --osx-bundle-identifier "com.airliftsilence.app" \
    --target-architecture "$(uname -m)" \
    airlift_gui.py

# 修补 Info.plist
PLIST="dist/AirliftSilence.app/Contents/Info.plist"
if [ -f "$PLIST" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0.0" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1.0.0" "$PLIST" 2>/dev/null || true
fi

# Ad-hoc 签名
codesign --force --deep --sign - dist/AirliftSilence.app 2>/dev/null || true

echo ""
echo "========================================="
echo "  构建完成！"
echo "========================================="
echo ""
echo "应用位置："
echo "  $(pwd)/dist/AirliftSilence.app"
echo ""
echo "使用方法："
echo "  1. 在 Finder 中打开 dist 文件夹"
echo "  2. 双击 AirliftSilence.app"
echo "  3. 如果提示'无法验证开发者'，右键应用 → 打开 → 打开"
echo ""
echo "备份目录：~/Library/Application Support/AirliftSilence/backup/"
echo ""
read -p "按回车键关闭窗口..."
