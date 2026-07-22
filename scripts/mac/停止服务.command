#!/bin/bash
# Mac 停止答题服务

PID=$(ps aux | grep ocs_ai_answerer_advanced.py | grep -v grep | awk '{print $2}')
if [ -z "$PID" ]; then
    echo "服务未运行"
else
    kill $PID 2>/dev/null
    echo "服务已停止"
fi
