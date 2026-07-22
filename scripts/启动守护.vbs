' 启动守护程序（后台）
Dim ws
Set ws = CreateObject("WScript.Shell")
ws.Run "wscript.exe """ & Replace(WScript.ScriptFullName, "启动守护.vbs", "守护程序.vbs") & """", 0, False
