@echo off
echo === Dell Fix Harley Setup ===
echo.
echo Step 1: Creating dell-fix model...
ollama create dell-fix -f Modelfile.dell-fix
echo.
echo Step 2: Testing model...
echo Dell 5810 login loop. Windows on D drive. Give me exact WinRE commands. | ollama run dell-fix
echo.
echo Done! Run 'ollama run dell-fix' anytime to use.
pause
