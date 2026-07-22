' OCS AI Answerer - 守护程序
' 后台运行，检测超星/学习通/智慧树是否在浏览器中打开，自动管理答题服务启停
' 双击此文件即可，一直在后台（几乎不占CPU）
' 停止守护：双击 停止服务.bat

Dim ws, fso, projectPath, pythonExe, checkScript, serviceVbs
Set ws = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
projectPath = fso.GetParentFolderName(scriptDir)
serviceVbs = scriptDir & "\启动服务.vbs"
checkScript = scriptDir & "\lib\check_study.py"

' 找 Python（优先用 venv 的）
pythonExe = projectPath & "\venv\Scripts\python.exe"
If Not fso.FileExists(pythonExe) Then pythonExe = "python.exe"

Dim closedCycles
closedCycles = 0

Do While True
    Dim studying, serviceOn
    studying = IsStudyPageOpen()
    serviceOn = IsServiceRunning()

    If studying Then
        If Not serviceOn Then
            ws.Run """" & serviceVbs & """", 1, False
        End If
        closedCycles = 0
    Else
        closedCycles = closedCycles + 1
        If closedCycles >= 3 And serviceOn Then
            ws.Run "cmd /c taskkill /F /IM pythonw.exe >nul 2>&1", 0, True
            closedCycles = 0
        End If
    End If

    WScript.Sleep 30000
Loop

Function IsStudyPageOpen()
    Dim ret
    On Error Resume Next
    ret = ws.Run("""" & pythonExe & """ """ & checkScript & """", 0, True)
    If ret = 0 Then IsStudyPageOpen = True Else IsStudyPageOpen = False
    If Err.Number <> 0 Then IsStudyPageOpen = False
    On Error GoTo 0
End Function

Function IsServiceRunning()
    Dim wmi, col
    On Error Resume Next
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set col = wmi.ExecQuery("SELECT ProcessId FROM Win32_Process WHERE Name='pythonw.exe' AND CommandLine LIKE '%ocs_ai_answerer_advanced%'")
    IsServiceRunning = (col.Count > 0)
    If Err.Number <> 0 Then IsServiceRunning = False
    On Error GoTo 0
End Function
