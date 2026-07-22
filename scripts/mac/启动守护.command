#!/bin/bash
# Mac 守护程序 - 检测超星页面自动启停答题服务
# 双击此文件运行，后台常驻，几乎不占 CPU

cd "$(dirname "$0")/../.."
PROJECT_DIR=$(pwd)

SERVICE_PID=""
CHECK_INTERVAL=30
CLOSED_CYCLES=0

# 检测浏览器是否有超星/学习通标签页（通过窗口标题）
check_study() {
    osascript -e 'tell application "System Events"
        set found to false
        set procNames to {"Google Chrome", "Microsoft Edge", "Safari", "Firefox"}
        repeat with procName in procNames
            try
                set winTitles to title of every window of process procName
                repeat with t in winTitles
                    if t contains "超星" or t contains "chaoxing" or t contains "学习通" or t contains "智慧树" or t contains "zhihuishu" or t contains "mooc" then
                        set found to true
                    end if
                end repeat
            end try
        end repeat
        return found
    end tell' 2>/dev/null
}

# 检测服务是否在运行
check_service() {
    pgrep -f ocs_ai_answerer_advanced.py > /dev/null 2>&1
}

# 启动服务
start_service() {
    cd "$PROJECT_DIR"
    source venv/bin/activate 2>/dev/null
    nohup python3 ocs_ai_answerer_advanced.py > /dev/null 2>&1 &
    echo "$(date): 服务已启动"
}

# 停止服务
stop_service() {
    PID=$(pgrep -f ocs_ai_answerer_advanced.py 2>/dev/null)
    if [ -n "$PID" ]; then
        kill $PID 2>/dev/null
        echo "$(date): 服务已停止"
    fi
}

echo "守护程序已启动，每 $CHECK_INTERVAL 秒检测一次..."
echo "关闭此窗口即停止守护。"

while true; do
    STUDYING=$(check_study)
    SERVICE_RUNNING=$(check_service; echo $?)

    if [ "$STUDYING" = "true" ]; then
        if [ $SERVICE_RUNNING -ne 0 ]; then
            start_service
        fi
        CLOSED_CYCLES=0
    else
        CLOSED_CYCLES=$((CLOSED_CYCLES + 1))
        if [ $CLOSED_CYCLES -ge 3 ] && [ $SERVICE_RUNNING -eq 0 ]; then
            stop_service
            CLOSED_CYCLES=0
        fi
    fi

    sleep $CHECK_INTERVAL
done
