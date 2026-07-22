Set ws = WScript.CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' 获取项目根目录（vbs所在目录的上级的上级）
scriptPath = fso.GetParentFolderName(WScript.ScriptFullName)
projectPath = fso.GetParentFolderName(fso.GetParentFolderName(scriptPath))

' 先检查服务是否已在运行
checkCmd = "netstat -ano | findstr ":5000.*LISTENING" > nul"
checkResult = ws.Run("cmd /c " & checkCmd, 0, True)

If checkResult = 0 Then
    ' 端口已被占用，可能是服务已在运行
    WScript.Echo "服务已在运行中（端口 5000 已被占用）"
    WScript.Quit 0
End If

' 创建日志目录
logDir = projectPath & "\logs"
If Not fso.FolderExists(logDir) Then
    fso.CreateFolder(logDir)
End If

' 用 pythonw 静默启动（无黑窗口）
pythonw = projectPath & "\venv\Scripts\pythonw.exe"
mainPy = projectPath & "\ocs_ai_answerer_advanced.py"
logFile = logDir & "\service.log"

' 如果 venv 的 pythonw 不存在，用系统 python
If Not fso.FileExists(pythonw) Then
    pythonw = "pythonw"
End If

cmd = pythonw & " " & mainPy & " > """ & logFile & """ 2>&1"
ws.Run cmd, 0, False

' 等待几秒确认启动
WScript.Sleep 3000
checkResult = ws.Run("cmd /c " & checkCmd, 0, True)
If checkResult = 0 Then
    WScript.Echo "✅ 服务已成功启动（后台运行）"
Else
    WScript.Echo "❌ 服务启动失败，请检查日志：" & logFile
End If
