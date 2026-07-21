@echo off
REM ============================================================
REM  OCS AI Answerer - One-click Startup
REM  Compatible: Windows 10/11, Python 3.8+
REM ============================================================
REM  CRITICAL: cd to project root regardless of where bat is
cd /d "%~dp0\.."

title OCS AI Answerer - Service

echo.
echo ============================================================
echo   OCS AI Auto-Answer Service - One-click Startup
echo ============================================================
echo.

REM ====== Step 1: Check Python ======
echo [1/6] Checking Python ...
python --version >nul 2>&1
if errorlevel 1 (
    echo   [FAIL] Python not found
    echo   Please install Python 3.8+ from https://www.python.org/downloads/
    echo   IMPORTANT: Check "Add Python to PATH" during installation
    pause
    exit /b 1
)
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PY_VERSION=%%i
echo   [OK] Python %PY_VERSION% found
echo.

REM ====== Step 2: Create venv ======
echo [2/6] Preparing virtual environment ...
if not exist "venv\Scripts\python.exe" (
    echo   Creating venv - first run, takes about 10 seconds ...
    python -m venv venv
    if errorlevel 1 (
        echo   [FAIL] Failed to create venv
        pause
        exit /b 1
    )
    echo   [OK] venv created
) else (
    echo   [OK] venv already exists, skip
)
echo.

REM ====== Step 3: Install dependencies ======
echo [3/6] Checking dependencies ...
call venv\Scripts\activate.bat >nul
python -c "import flask, openai, httpx" 2>nul
if errorlevel 1 (
    echo   Installing Flask, openai, httpx - takes about 30 seconds ...
    python -m pip install --upgrade pip -q 2>nul
    pip install -r requirements.txt -q
    if errorlevel 1 (
        echo   [FAIL] Failed to install dependencies
        echo   Possible: network issue
        echo   Try: pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
        pause
        exit /b 1
    )
    echo   [OK] dependencies installed
) else (
    echo   [OK] dependencies already installed, skip
)
echo.

REM ====== Step 4: Configure API keys ======
echo [4/6] Configuring API keys ...
set HAS_KEY=0
if exist ".env" (
    findstr /B /C:"DEEPSEEK_API_KEY=sk-" .env >nul 2>&1
    if not errorlevel 1 set HAS_KEY=1
    findstr /B /C:"DOUBAO_API_KEY=ark-" .env >nul 2>&1
    if not errorlevel 1 set HAS_KEY=1
)

if "%HAS_KEY%"=="1" (
    echo   [OK] .env already has API keys, skip
) else (
    if exist "keys.txt" (
        findstr /B /C:"DEEPSEEK_API_KEY=sk-" keys.txt >nul 2>&1
        if not errorlevel 1 (
            if not exist ".env" copy env.template .env >nul
            echo   Reading keys.txt, merging into .env ...
            python -c "import os; keys={}; [keys.__setitem__(*l.strip().split('=',1)) for l in open('keys.txt','r',encoding='utf-8') if '=' in l and not l.strip().startswith('#')]; env=open('.env','r',encoding='utf-8').read() if os.path.exists('.env') else ''; lines=env.splitlines(); idx={l.split('=',1)[0]:i for i,l in enumerate(lines) if '=' in l}; [lines.__setitem__(idx[k], k+'='+v) if k in idx else lines.append(k+'='+v) for k,v in keys.items()]; open('.env','w',encoding='utf-8').write(chr(10).join(lines)+chr(10))"
            echo   [OK] API keys merged into .env
        ) else (
            echo   [WARN] keys.txt does not contain real keys
            echo   Please edit keys.txt and put your real API keys
            notepad keys.txt
            echo.
            echo   Press any key after saving keys.txt ...
            pause >nul
        )
    ) else (
        echo   [WARN] No keys.txt found
        echo   Please create keys.txt and put your API keys, then re-run
        echo.
        echo   DEEPSEEK key: https://platform.deepseek.com/api_keys
        echo   DOUBAO key:   https://console.volcengine.com/ark
        pause
        exit /b 1
    )
)
echo.

REM ====== Step 5: Start service ======
echo [5/6] Starting service ...
netstat -ano | findstr ":5000.*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo   [WARN] Port 5000 is occupied, cleaning up ...
    for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":5000.*LISTENING"') do (
        taskkill -F -PID %%p >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
)

echo   Starting OCS service in background ...
echo   Service URL: http://127.0.0.1:5000
echo.

REM Start pythonw in background (no black window)
start /b "" pythonw ocs_ai_answerer_advanced.py

REM Wait for service to be ready
echo   Waiting for service to be ready (up to 30s) ...
set TRIED=0
:WAIT_LOOP
set /a TRIED+=1
timeout /t 1 /nobreak >nul
curl -s -m 2 http://127.0.0.1:5000/api/health >nul 2>&1
if not errorlevel 1 goto SERVICE_READY
if %TRIED% lss 30 goto WAIT_LOOP
echo   [WARN] Service did not respond in 30s
echo   Check the log file: ocs_request_trace.log
goto DESKTOP_SHORTCUT

:SERVICE_READY
echo   [OK] Service is ready!
echo.

REM ====== Step 6: Desktop shortcut + open browser ======
echo [6/6] Final setup ...
echo.

set SHORTCUT_PATH=%USERPROFILE%\Desktop\OCS-AI-Answerer.lnk
if exist "%SHORTCUT_PATH%" (
    echo   [OK] Desktop shortcut already exists
) else (
    echo   Creating desktop shortcut ...
    set CSS=%TEMP%\cs_%RANDOM%.vbs
    (
        echo Set WshShell = CreateObject^("WScript.Shell"^)
        echo Set shortcut = WshShell.CreateShortcut^("%SHORTCUT_PATH%"^)
        echo shortcut.TargetPath = "%~dp0..\scripts\一键启动.bat"
        echo shortcut.WorkingDirectory = "%~dp0.."
        echo shortcut.WindowStyle = 7
        echo shortcut.Description = "OCS AI Auto-Answer Service"
        echo shortcut.Save
    ) > "%CSS%"
    cscript //nologo "%CSS%" >nul 2>&1
    del "%CSS%" >nul 2>&1
    if exist "%SHORTCUT_PATH%" (
        echo   [OK] Desktop shortcut created
    ) else (
        echo   [WARN] Could not create desktop shortcut
    )
)

echo.
echo ============================================================
echo   Service is running in background!
echo ============================================================
echo.
echo   Service URL:      http://127.0.0.1:5000
echo   Health check:     http://127.0.0.1:5000/api/health
echo   Config panel:     http://127.0.0.1:5000/config_legacy
echo.
echo   Read docs/INSTALL.html for browser setup steps.
echo   This window will close in 5 seconds ...
echo   (Service keeps running in background)
echo.

start "" "http://127.0.0.1:5000/config_legacy"
start "" "docs\INSTALL.html"

timeout /t 5 /nobreak >nul
exit /b 0
