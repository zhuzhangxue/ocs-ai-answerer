@echo off
chcp 65001 >nul
echo ============================================
echo   设置 OCS AI 服务开机自启
echo ============================================
echo.
echo 将创建开机启动项：开机后自动在后台启动答题服务
echo 无需手动双击 bat，服务会自动运行。
echo.

REM 获取脚本所在目录的上一级（项目根目录）
set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "VBS_PATH=%PROJECT_DIR%\scripts\启动服务.vbs"

REM 检查 VBS 是否存在
if not exist "%VBS_PATH%" (
    echo [FAIL] 找不到 %VBS_PATH%
    pause
    exit /b 1
)

REM 创建快捷方式到启动文件夹
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT=%STARTUP%\OCS-AI答题服务.lnk"

REM 用 PowerShell 创建快捷方式
powershell -Command ^
    $ws = New-Object -ComObject WScript.Shell; ^
    $sc = $ws.CreateShortcut('%SHORTCUT%'); ^
    $sc.TargetPath = '%VBS_PATH%'; ^
    $sc.WorkingDirectory = '%PROJECT_DIR%'; ^
    $sc.Description = 'OCS AI 答题服务（后台运行）'; ^
    $sc.Save()

if exist "%SHORTCUT%" (
    echo [OK] 已添加开机自启项
    echo.
    echo 下次开机后，答题服务会自动在后台启动。
    echo 如果服务已正在运行，VBS 会检测到并跳过。
    echo.
    echo 停止自启：删除以下文件即可
    echo   %SHORTCUT%
) else (
    echo [FAIL] 创建开机自启失败
)

echo.
pause
