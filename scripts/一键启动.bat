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
    echo   Installing dependencies - takes about 30 seconds ...
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
set HAS_GLM_KEY=0
set HAS_QWEN_KEY=0
if exist ".env" (
    findstr /B /C:"DEEPSEEK_API_KEY=sk-" .env >nul 2>&1
    if not errorlevel 1 set HAS_KEY=1
    findstr /B /C:"DOUBAO_API_KEY=ark-" .env >nul 2>&1
    if not errorlevel 1 set HAS_KEY=1
    findstr /B /R /C:"GLM_API_KEY=." .env >nul 2>&1
    if not errorlevel 1 set HAS_GLM_KEY=1
    findstr /B /R /C:"DASHSCOPE_API_KEY=." .env >nul 2>&1
    if not errorlevel 1 set HAS_QWEN_KEY=1
)

if "%HAS_KEY%"=="1" (
    echo   [OK] .env already has API keys
) else (
    if exist "keys.txt" (
        findstr /B /C:"DEEPSEEK_API_KEY=sk-" keys.txt >nul 2>&1
        if not errorlevel 1 (
            if not exist ".env" copy env.template .env >nul
            echo   Reading keys.txt, merging into .env ...
            python -c "import os; keys={}; [keys.__setitem__(*l.strip().split('=',1)) for l in open('keys.txt','r',encoding='utf-8') if '=' in l and not l.strip().startswith('#')]; env=open('.env','r',encoding='utf-8').read() if os.path.exists('.env') else ''; lines=env.splitlines(); idx={l.split('=',1)[0]:i for i,l in enumerate(lines) if '=' in l}; [lines.__setitem__(idx[k], k+'='+v) if k in idx else lines.append(k+'='+v) for k,v in keys.items()]; open('.env','w',encoding='utf-8').write(chr(10).join(lines)+chr(10))"
            echo   [OK] API keys merged into .env
            python -c "exit(0 if len(open('keys.txt','r',encoding='utf-8').read().split('GLM_API_KEY=',1)[-1].splitlines()[0].strip())>0 else 1)" 2>nul
            if not errorlevel 1 set HAS_GLM_KEY=1
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
        echo   GLM key:     https://bigmodel.cn/usercenter/proj-mgmt/apikeys
        pause
        exit /b 1
    )
)

REM If GLM key not in .env but present in keys.txt, merge it
if "%HAS_GLM_KEY%"=="0" (
    if exist "keys.txt" (
        python -c "exit(0 if len(open('keys.txt','r',encoding='utf-8').read().split('GLM_API_KEY=',1)[-1].splitlines()[0].strip())>0 else 1)" 2>nul
        if not errorlevel 1 (
            echo   [INFO] Merging GLM_API_KEY from keys.txt into .env
            python -c "import os; keys={}; [keys.__setitem__(*l.strip().split('=',1)) for l in open('keys.txt','r',encoding='utf-8') if '=' in l and not l.strip().startswith('#')]; env=open('.env','r',encoding='utf-8').read() if os.path.exists('.env') else ''; lines=env.splitlines(); idx={l.split('=',1)[0]:i for i,l in enumerate(lines) if '=' in l}; [lines.__setitem__(idx[k], k+'='+v) if k in idx else lines.append(k+'='+v) for k,v in keys.items() if k == 'GLM_API_KEY']; open('.env','w',encoding='utf-8').write(chr(10).join(lines)+chr(10))"
            set HAS_GLM_KEY=1
            echo   [OK] GLM_API_KEY configured from keys.txt
        )
    )
)

REM Ask user to add GLM key if still missing
if "%HAS_GLM_KEY%"=="0" (
    echo   [HINT] GLM-4.6V-Flash - free vision model - not configured
    echo   Get a free API key at: https://bigmodel.cn/usercenter/proj-mgmt/apikeys
    echo.
    choice /c YN /n /m "   Add GLM key now? (Y/N): "
    if not errorlevel 2 (
        if exist "keys.txt" (
            notepad keys.txt
            echo   Press any key after saving keys.txt ...
            pause >nul
        )
    )
    echo.
)

REM Ask user to add Qwen key if still missing
if "%HAS_QWEN_KEY%"=="0" (
    echo   [HINT] Qwen VL Flash / 3.7-Plus - optional paid vision models
    echo   Get DashScope API key at: https://help.aliyun.com/zh/model-studio/getting-started/get-api-key
    echo   Also need QWEN_BASE_URL from your Bailian workspace
    echo.
    choice /c YN /n /m "   Add Qwen key now? (Y/N): "
    if not errorlevel 2 (
        if exist "keys.txt" (
            notepad keys.txt
            echo   Press any key after saving keys.txt ...
            pause >nul
        )
    )
    echo.
)

REM If Qwen key not in .env but present in keys.txt, merge it
if "%HAS_QWEN_KEY%"=="0" (
    if exist "keys.txt" (
        python -c "exit(0 if len(open('keys.txt','r',encoding='utf-8').read().split('DASHSCOPE_API_KEY=',1)[-1].splitlines()[0].strip())>0 else 1)" 2>nul
        if not errorlevel 1 (
            echo   [INFO] Merging DASHSCOPE_API_KEY from keys.txt into .env
            python -c "import os; keys={}; [keys.__setitem__(*l.strip().split('=',1)) for l in open('keys.txt','r',encoding='utf-8') if '=' in l and not l.strip().startswith('#')]; env=open('.env','r',encoding='utf-8').read() if os.path.exists('.env') else ''; lines=env.splitlines(); idx={l.split('=',1)[0]:i for i,l in enumerate(lines) if '=' in l}; [lines.__setitem__(idx[k], k+'='+v) if k in idx else lines.append(k+'='+v) for k,v in keys.items() if k == 'DASHSCOPE_API_KEY']; open('.env','w',encoding='utf-8').write(chr(10).join(lines)+chr(10))"
            set HAS_QWEN_KEY=1
            echo   [OK] DASHSCOPE_API_KEY configured from keys.txt
        )
    )
)
echo.

REM ====== Step 5: Model self-check ======
echo [5/6] Checking model configurations ...
call venv\Scripts\activate.bat >nul
python scripts\lib\check_models.py
if errorlevel 1 (
    echo   [WARN] 模型自检发现问题，但继续启动服务...
)
echo.

REM ====== Step 6: Start service ======
echo [6/6] Starting service ...
netstat -ano | findstr ":5000.*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo   [WARN] Port 5000 is occupied, cleaning up ...
    for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":5000.*LISTENING"') do (
        taskkill -F -PID %%p >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
)

echo.
echo ============================================================
echo   Service is running!
echo   Service URL:  http://127.0.0.1:5000
echo ============================================================
echo.
echo   Other scripts in this folder:
echo     启动服务.vbs     - Manual start (background, no window)
echo     停止服务.bat     - Stop service + guardian
echo     启动守护.vbs     - Auto mode: starts/stops with browser
echo.
echo   Close this window to stop the service.
echo.

call venv\Scripts\activate.bat >nul
"venv\Scripts\python.exe" ocs_ai_answerer_advanced.py

pause
exit /b 0