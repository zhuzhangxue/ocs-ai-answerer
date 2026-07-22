#!/bin/bash
# OCS AI Answerer - Mac 一键启动
# 首次运行: 自动装依赖 + 填 Key + 启动服务
# 后续运行: 直接启动

cd "$(dirname "$0")/.."
PROJECT_DIR=$(pwd)

echo "============================================"
echo "  OCS AI 智能答题助手 - Mac 启动"
echo "============================================"
echo ""

# Step 1: 检查 Python
echo "[1/5] 检查 Python..."
PY_CMD=""
if command -v python3 &> /dev/null; then
    PY_CMD="python3"
elif command -v python &> /dev/null && python --version 2>&1 | grep -q "3."; then
    PY_CMD="python"
else
    echo "  [FAIL] 未检测到 Python 3"
    echo "  请先安装: https://www.python.org/downloads/"
    echo "  或终端运行: brew install python@3.11"
    read -p "按回车退出..."
    exit 1
fi
echo "  [OK] Python $($PY_CMD --version 2>&1)"

# Step 2: 创建 venv
echo "[2/5] 准备虚拟环境..."
if [ ! -d "venv" ]; then
    echo "  首次运行，创建 venv..."
    $PY_CMD -m venv venv
fi
source venv/bin/activate
echo "  [OK] venv 就绪"

# Step 3: 装依赖
echo "[3/5] 安装依赖..."
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "  [OK] 依赖已安装"

# Step 4: 配置 Key
echo "[4/5] 配置 API Key..."
if grep -q "sk-你的" keys.txt 2>/dev/null || grep -q "ark-你的" keys.txt 2>/dev/null; then
    echo "  keys.txt 还是占位符，请先编辑 keys.txt 填入你的真实 Key"
    open keys.txt
    read -p "  填好后按回车继续..."
fi

# 从 keys.txt 写入 .env（仅首次）
if [ ! -f ".env" ] || grep -q "^DEEPSEEK_API_KEY=$" .env 2>/dev/null; then
    $PY_CMD -c "
import os
keys={}
for l in open('keys.txt','r',encoding='utf-8'):
    if '=' in l and not l.strip().startswith('#'):
        k, v = l.strip().split('=', 1)
        keys[k] = v
env = open('env.template','r',encoding='utf-8').read()
for k, v in keys.items():
    env = env.replace(f'{k}=', f'{k}={v}')
open('.env','w',encoding='utf-8').write(env)
print('  [OK] Key 已写入 .env')
" 2>/dev/null || echo "  [INFO] .env 已存在，跳过"
else
    echo "  [OK] .env 已有 Key"
fi

# 模型自检
echo ""
python3 scripts/lib/check_models.py

# Step 5: 启动服务
echo ""
echo "[5/5] 启动服务..."
echo ""
echo "============================================"
echo "  服务地址: http://127.0.0.1:5000"
echo "  按 Ctrl+C 停止服务"
echo "============================================"
echo ""

python3 ocs_ai_answerer_advanced.py

read -p "按回车退出..."
