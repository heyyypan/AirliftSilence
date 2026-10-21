#!/bin/bash
# 双击运行.command —— 直接从源码运行 AirliftSilence（无需打包）
# 在 Mac 上双击此文件即可。如果提示"无法打开"，右键 → 打开。

cd "$(dirname "$0")"

echo "========================================="
echo "  AirliftSilence — 直接运行模式"
echo "========================================="
echo ""

# 检查 Python
if ! command -v python3 &>/dev/null; then
    echo "错误：未找到 python3。"
    echo "请先安装 Python 3.10+：https://www.python.org/downloads/macos/"
    echo ""
    read -p "按回车键退出..."
    exit 1
fi

echo "Python 版本：$(python3 --version 2>&1)"
echo ""

# 创建虚拟环境（如果不存在）
if [ ! -d ".venv-run" ]; then
    echo "首次运行，正在创建虚拟环境并安装依赖（约 1-2 分钟）..."
    python3 -m venv .venv-run
    source .venv-run/bin/activate
    pip install --upgrade pip >/dev/null
    pip install pymobiledevice3
    echo "依赖安装完成。"
else
    source .venv-run/bin/activate
fi

echo ""
echo "正在启动 GUI..."
echo "（如果弹出窗口，说明启动成功；关闭窗口即退出程序）"
echo ""

python3 airlift_gui.py

echo ""
echo "程序已退出。"
read -p "按回车键关闭窗口..."
