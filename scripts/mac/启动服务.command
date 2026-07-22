#!/bin/bash
# Mac 启动答题服务（后台运行）

cd "$(dirname "$0")/../.."
source venv/bin/activate 2>/dev/null
nohup python3 ocs_ai_answerer_advanced.py > /dev/null 2>&1 &
echo "服务已启动: http://127.0.0.1:5000"
