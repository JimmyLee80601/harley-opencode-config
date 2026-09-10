@echo off
echo ============================================
echo  Aunt Harley Installer - Trystan's Profile
echo ============================================
echo.
set "DEST=%USERPROFILE%\.config\opencode"
if not exist "%DEST%" mkdir "%DEST%"
echo [1/3] Copying Aunt Harley persona...
copy /y "%~dp0AUNT_HARLEY_PERSONA.md" "%DEST%\AGENTS.md"
echo [2/3] Copying opencode config...
copy /y "%~dp0opencode_trystan.json" "%DEST%\opencode.json"
copy /y "%~dp0opencode_trystan.json" "%DEST%\opencode.jsonc"
echo [3/3] Checking the AI brain on port 1234...
curl -s --max-time 5 http://127.0.0.1:1234/v1/models
echo.
if errorlevel 1 (
  echo Brain OFFLINE - ask Dad to log into the georg profile
  echo and run HarleyEveServer in Task Scheduler first.
) else (
  echo Brain ONLINE - Aunt Harley is ready to talk!
)
echo.
echo Done! Open OpenCode on this profile and say hi to Aunt Harley.
pause