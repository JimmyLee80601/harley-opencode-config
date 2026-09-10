@echo off
echo ============================================
echo HARLEY MASTER SSH + FIREWALL FIX
echo Run as Administrator!
echo ============================================
echo.

echo [1/5] Fixing SSH config...
:: Uncomment PasswordAuthentication
powershell -Command "(Get-Content 'C:\ProgramData\ssh\sshd_config') -replace '#PasswordAuthentication yes', 'PasswordAuthentication yes' -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' | Set-Content 'C:\ProgramData\ssh\sshd_config'"
echo   SSH config fixed

echo.
echo [2/5] Adding Tailscale firewall rules...
netsh advfirewall firewall add rule name="Harley Tailscale Allow All" dir=in action=allow protocol=any remoteip=100.0.0.0/8
netsh advfirewall firewall add rule name="Harley SSH All Ports" dir=in action=allow protocol=TCP remoteip=100.0.0.0/8 localport=22,443,8022
netsh advfirewall firewall add rule name="Harley Ollama Tailscale" dir=in action=allow protocol=TCP remoteip=100.0.0.0/8 localport=11434
netsh advfirewall firewall add rule name="Harley RDP Tailscale" dir=in action=allow protocol=TCP remoteip=100.0.0.0/8 localport=3389
netsh advfirewall firewall add rule name="Harley HTTP Tailscale" dir=in action=allow protocol=TCP remoteip=100.0.0.0/8 localport=80,8080,8443,8888
echo   Firewall rules added

echo.
echo [3/5] Setting up port 443 -> 22 proxy...
netsh interface portproxy add v4tov4 listenport=443 listenaddress=0.0.0.0 connectport=22 connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=8022 listenaddress=0.0.0.0 connectport=22 connectaddress=127.0.0.1
echo   Port proxy 443->22 and 8022->22 created

echo.
echo [4/5] Restarting SSH service...
net stop sshd 2>nul
net start sshd
echo   SSH restarted

echo.
echo [5/5] Setting network to Private (less restrictive)...
powershell -Command "Get-NetConnectionProfile -InterfaceAlias 'Tailscale' | Set-NetConnectionProfile -NetworkCategory Private"
powershell -Command "Get-NetConnectionProfile -InterfaceAlias 'Tailscale*' | Set-NetConnectionProfile -NetworkCategory Private"
echo   Tailscale network set to Private

echo.
echo ============================================
echo DONE! SSH should now be accessible via:
echo   ssh georg@100.104.127.89
echo   ssh georg@100.104.127.89 -p 443
echo   ssh georg@100.104.127.89 -p 8022
echo ============================================
echo.
echo Dell Username: georg
echo Dell Password: (your Windows login password)
echo.
echo Tailscale IPs:
echo   Dell: 100.104.127.89
echo   Chromebook: 100.82.48.34
echo   S23: 100.126.38.38
echo.
pause
