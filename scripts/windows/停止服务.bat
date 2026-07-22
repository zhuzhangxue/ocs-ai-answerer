@echo off
chcp 65001 >nul
echo ============================================
echo   OCS AI Answerer - 停止服务
echo ============================================
echo.

REM 查找占用 5000 端口的进程并终止
netstat -ano | findstr ":5000.*LISTENING" >nul 2>&1
if errorlevel 1 (
    echo [INFO] 未检测到运行中的服务（端口 5000 未被占用）
) else (
    for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":5000.*LISTENING"') do (
        taskkill -F -PID %%p >nul 2>&1
        echo [OK] 答题服务 (PID: %%p) 已停止
    )
)

REM 停止后台守护程序
taskkill /F /FI "WINDOWTITLE eq 守护程序" /IM wscript.exe >nul 2>&1
if not errorlevel 1 (
    echo [OK] 后台守护程序已停止
)

echo.
echo 按任意键退出...
pause >nul
