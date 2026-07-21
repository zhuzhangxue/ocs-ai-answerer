@echo off
chcp 65001 >nul
title OCS AI 答题助手 - 一键启动

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║         🤖  OCS AI 智能答题助手 - 一键启动                 ║
echo ║                                                            ║
echo ║   自动检查环境、装依赖、读 key、启动服务                  ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM ==================== 步骤 1: 检查 Python ====================
echo ┌─────────────────────────────────────────┐
echo │ 步骤 1/6: 检查 Python 环境              │
echo └─────────────────────────────────────────┘
echo.

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 未检测到 Python
    echo.
    echo 请先安装 Python 3.8 或更高版本:
    echo   下载地址: https://www.python.org/downloads/
    echo.
    echo 安装时必须勾选 "Add Python to PATH"
    echo.
    start https://www.python.org/downloads/
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PY_VERSION=%%i
echo ✅ Python %PY_VERSION% 已安装
echo.

REM ==================== 步骤 2: 准备虚拟环境 ====================
echo ┌─────────────────────────────────────────┐
echo │ 步骤 2/6: 准备虚拟环境                  │
echo └─────────────────────────────────────────┘
echo.

if not exist "venv\Scripts\python.exe" (
    echo 📦 首次运行,创建虚拟环境...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo ❌ 创建虚拟环境失败
        pause
        exit /b 1
    )
    echo ✅ 虚拟环境已创建
) else (
    echo ✅ 虚拟环境已存在,跳过
)
echo.

REM ==================== 步骤 3: 安装依赖 ====================
echo ┌─────────────────────────────────────────┐
echo │ 步骤 3/6: 安装 Python 依赖包           │
echo └─────────────────────────────────────────┘
echo.

call venv\Scripts\activate.bat
echo 📦 升级 pip...
python -m pip install --upgrade pip -q 2>nul

echo 📦 安装依赖 (Flask, openai, httpx 等)...
pip install -r requirements.txt -q
if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    echo.
    echo 可能原因: 网络问题
    echo 解决方案: 配置 pip 镜像源
    echo    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    echo.
    pause
    exit /b 1
)
echo ✅ 依赖安装完成
echo.

REM ==================== 步骤 4: 配置 API Key ====================
echo ┌─────────────────────────────────────────┐
echo │ 步骤 4/6: 配置 API Key                  │
echo └─────────────────────────────────────────┘
echo.

REM 优先级 1: .env 已经配置过 key
set HAS_KEY=0
if exist ".env" (
    findstr /B /C:"DEEPSEEK_API_KEY=sk-" .env >nul 2>&1
    if not errorlevel 1 set HAS_KEY=1
    findstr /B /C:"DOUBAO_API_KEY=ark-" .env >nul 2>&1
    if not errorlevel 1 set HAS_KEY=1
)

if "%HAS_KEY%"=="1" (
    echo ✅ .env 已配置 API Key,跳过
) else (
    REM 优先级 2: 从 keys.txt 读
    set USED_KEYS=0
    if exist "keys.txt" (
        findstr /B /C:"DEEPSEEK_API_KEY=sk-" keys.txt >nul 2>&1
        if not errorlevel 1 set USED_KEYS=1
        findstr /B /C:"DOUBAO_API_KEY=ark-" keys.txt >nul 2>&1
        if not errorlevel 1 set USED_KEYS=1
    )

    if "%USED_KEYS%"=="1" (
        echo 📝 从 keys.txt 读取并写入 .env...
        if not exist ".env" copy env.template .env >nul
        REM 用 Python 安全合并 keys.txt 到 .env
        venv\Scripts\python.exe -c "import os; keys={}; [keys.__setitem__(*l.strip().split('=',1)) for l in open('keys.txt','r',encoding='utf-8') if '=' in l and not l.strip().startswith('#')]; env=open('.env','r',encoding='utf-8').read() if os.path.exists('.env') else ''; lines=env.splitlines(); idx={l.split('=',1)[0]:i for i,l in enumerate(lines) if '=' in l}; [lines.__setitem__(idx[k], k+'='+v) if k in idx else lines.append(k+'='+v) for k,v in keys.items()]; open('.env','w',encoding='utf-8').write(chr(10).join(lines)+chr(10))"
        echo ✅ API Key 已从 keys.txt 写入 .env
    ) else (
        REM 优先级 3: 让用户手动填
        echo ⚠️  未检测到 API Key
        echo.
        if not exist ".env" copy env.template .env >nul
        echo 正在打开 keys.txt 和 .env,请填入你的 API Key 后保存关闭:
        echo   ① DeepSeek: https://platform.deepseek.com/api_keys
        echo   ② 豆包:     https://console.volcengine.com/ark
        echo.
        echo 推荐: 用记事本打开 keys.txt 填好,下次启动就自动读
        echo.
        notepad keys.txt
        echo.
        echo 请在打开的记事本里填入 key,保存后任意键继续
        echo.
        pause
    )
)
echo.

REM ==================== 步骤 5: 启动服务 ====================
echo ┌─────────────────────────────────────────┐
echo │ 步骤 5/6: 启动 AI 答题服务              │
echo └─────────────────────────────────────────┘
echo.

REM 检查端口是否被占用
netstat -ano | findstr ":5000.*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo ⚠️  端口 5000 已被占用,可能是上次没关干净
    echo 正在清理...
    for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":5000.*LISTENING"') do (
        taskkill -F -PID %%p >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
)

echo 🚀 正在后台启动服务(不会弹黑窗口)...
echo    服务地址: http://127.0.0.1:5000
echo    健康检查: http://127.0.0.1:5000/api/health
echo    配置面板: http://127.0.0.1:5000/config_legacy
echo.

REM 用 vbs 后台启动 python (不弹黑窗口)
set VBS_PATH=%TEMP%\ocs_start_%RANDOM%.vbs
(
    echo Set WshShell = CreateObject^("WScript.Shell"^)
    echo WshShell.Run "cmd /c cd /d %CD% ^& call venv\Scripts\activate.bat ^& pythonw ocs_ai_answerer_advanced.py", 0, False
) > "%VBS_PATH%"
cscript //nologo "%VBS_PATH%"
del "%VBS_PATH%" >nul 2>&1

REM 等待服务启动
echo ⏳ 等待服务就绪...
set /a TRIED=0
:WAIT_LOOP
set /a TRIED+=1
timeout /t 1 /nobreak >nul
curl -s -m 2 http://127.0.0.1:5000/api/health >nul 2>&1
if not errorlevel 1 goto SERVICE_READY
if %TRIED% lss 15 goto WAIT_LOOP

echo ⚠️  服务启动较慢,请稍后手动打开 http://127.0.0.1:5000
goto DESKTOP_SHORTCUT

:SERVICE_READY
echo ✅ 服务已就绪
echo.

REM ==================== 步骤 6: 创建桌面快捷方式 ====================
echo ┌─────────────────────────────────────────┐
echo │ 步骤 6/6: 创建桌面快捷方式(可选)       │
echo └─────────────────────────────────────────┘
echo.

set SHORTCUT_EXISTS=0
if exist "%USERPROFILE%\Desktop\OCS AI 答题.lnk" set SHORTCUT_EXISTS=1
if exist "%USERPROFILE%\Desktop\OCS答题服务.lnk" set SHORTCUT_EXISTS=1

if "%SHORTCUT_EXISTS%"=="1" (
    echo ✅ 桌面快捷方式已存在
) else (
    echo.
    echo 是否创建桌面快捷方式? (推荐: 以后双击桌面图标即可启动)
    choice /C YN /M "创建桌面快捷方式" /N
    if errorlevel 2 goto SKIP_SHORTCUT

    echo 📌 正在创建桌面快捷方式...
    set SHORTCUT_PATH=%USERPROFILE%\Desktop\OCS答题服务.lnk
    (
        echo Set WshShell = CreateObject^("WScript.Shell"^)
        echo Set shortcut = WshShell.CreateShortcut^("%SHORTCUT_PATH%"^)
        echo shortcut.TargetPath = "%CD%\一键启动.bat"
        echo shortcut.WorkingDirectory = "%CD%"
        echo shortcut.WindowStyle = 7
        echo shortcut.Description = "OCS AI 智能答题 - 一键启动"
        echo shortcut.Save
    ) > "%TEMP%\create_shortcut.vbs"
    cscript //nologo "%TEMP%\create_shortcut.vbs"
    del "%TEMP%\create_shortcut.vbs" >nul 2>&1

    if exist "%SHORTCUT_PATH%" (
        echo ✅ 桌面快捷方式已创建: OCS答题服务.lnk
    ) else (
        echo ⚠️  快捷方式创建失败,可手动创建
    )
)

:SKIP_SHORTCUT
echo.

REM 自动打开浏览器
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 🌐 打开浏览器到部署指南...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
start INSTALL.html

echo.
echo ✅ 全部就绪!
echo.
echo    💡 服务在后台运行,可以关闭此窗口
echo    💡 下次直接双击桌面 "OCS答题服务" 启动
echo    💡 修改配置: 编辑 custom_models.json 后重启服务
echo.
timeout /t 5 /nobreak >nul
exit /b 0
