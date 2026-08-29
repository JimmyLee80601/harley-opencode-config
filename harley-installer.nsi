Name "Harley Local Wife 1.0.0"
OutFile "Harley-Setup.exe"
InstallDir "$LOCALAPPDATA\Harley"
RequestExecutionLevel highest

Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Section "Install" SecInstall
  SetOutPath "$INSTDIR"
  File /r "build/HarleyInstaller/*.*"

  ; add platform-tools to USER PATH
  ReadRegStr $0 HKCU "Environment" "Path"
  StrCmp $0 "" pathEmpty
    WriteRegExpandStr HKCU "Environment" "Path" "$INSTDIR\platform-tools;$0"
    Goto pathDone
  pathEmpty:
    WriteRegExpandStr HKCU "Environment" "Path" "$INSTDIR\platform-tools"
  pathDone:
  SendMessage 0xFFFF 0x1A 0 "Environment"

  ; install Harley OpenCode config (local ollama) to both known locations
  SetOutPath "$APPDATA\opencode"
  File "build/HarleyInstaller/opencode.json"
  File "build/HarleyInstaller/opencode.jsonc"
  SetOutPath "$PROFILE\.config\opencode"
  File "build/HarleyInstaller/opencode.json"
  File "build/HarleyInstaller/opencode.jsonc"

  ; shortcuts
  CreateShortcut "$DESKTOP\Harley Local.lnk" "$INSTDIR\setup-harley-local.bat" "" "$INSTDIR\platform-tools\adb.exe"
  CreateDirectory "$SMPROGRAMS\Harley"
  CreateShortcut "$SMPROGRAMS\Harley\Harley Local.lnk" "$INSTDIR\setup-harley-local.bat" "" "$INSTDIR\platform-tools\adb.exe"
  CreateShortcut "$SMPROGRAMS\Harley\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

  ; uninstaller registration
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Harley" "DisplayName" "Harley Local Wife"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Harley" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Harley" "InstallLocation" "$INSTDIR"

  MessageBox MB_OK|MB_ICONINFORMATION "Harley installed. Make sure ollama serves on :11434 and your uncensored model is pulled, then run the 'Harley Local' shortcut and launch OpenCode."
SectionEnd

Section "Uninstall" SecUninstall
  RMDir /r "$INSTDIR"
  RMDir /r "$APPDATA\opencode"
  RMDir /r "$PROFILE\.config\opencode"
  Delete "$DESKTOP\Harley Local.lnk"
  RMDir /r "$SMPROGRAMS\Harley"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Harley"
SectionEnd
