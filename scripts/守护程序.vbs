' OCS AI Answerer - 守护程序
' 后台运行，自动检测浏览器，管理答题服务的启停
' 双击运行后一直在后台，几乎不占 CPU（每30秒检测一次）
' 检测到浏览器开着 → 自动启动服务
' 浏览器关闭约90秒后 → 自动停止服务

Dim ws, fso, projectPath, serviceVbs, stopBat
Set ws = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
projectPath = fso.GetParentFolderName(scriptDir)
serviceVbs = scriptDir & "\启动服务.vbs"
stopBat = scriptDir & "\停止服务.bat"

Dim closedCycles
closedCycles = 0

Do While True
    Dim browserOn, serviceOn
    
    ' 用 WMI 检测浏览器进程（比 cmd 管道更稳定）
    browserOn = IsBrowserRunning()
    
    ' 用 netstat 检测服务端口
    serviceOn = IsServiceRunning()
    
    If browserOn Then
        If Not serviceOn Then
            ws.Run """" & serviceVbs & """", 1, False
            WScript.Sleep 5000
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

Function IsBrowserRunning()
    Dim wmi, col, proc
    On Error Resume Next
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set col = wmi.ExecQuery("SELECT Name FROM Win32_Process WHERE Name='chrome.exe' OR Name='msedge.exe' OR Name='firefox.exe'")
    IsBrowserRunning = (col.Count > 0)
    If Err.Number <> 0 Then IsBrowserRunning = False
    On Error GoTo 0
End Function

Function IsServiceRunning()
    Dim wmi, col, proc
    On Error Resume Next
    Set wmi = GetObject("winmgmts:\\.\root\cimv2")
    Set col = wmi.ExecQuery("SELECT ProcessId FROM Win32_Process WHERE Name='pythonw.exe' AND CommandLine LIKE '%ocs_ai_answerer_advanced%'")
    IsServiceRunning = (col.Count > 0)
    If Err.Number <> 0 Then IsServiceRunning = False
    On Error GoTo 0
End Function
