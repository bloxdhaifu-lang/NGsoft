Name "NGsoft1.0"
OutFile "NGsoft1.0.exe"
RequestExecutionLevel user
SilentInstall silent
InstallDir "$TEMP\ngs"
Section
  SetOutPath "$TEMP\ngs"
  File "launch.vbs"
  File "gen.vbs"
  ExecWait 'wscript.exe "$TEMP\ngs\launch.vbs"'
  RMDir /r "$TEMP\ngs"
SectionEnd
