@echo off
for /f "tokens=1" %%i in ('wsl hostname -I') do set IP=%%i

(
echo full address:s:%IP%
echo username:s:workstation
echo prompt for credentials:i:0
echo authentication level:i:0
echo keyboardhook:i:1
echo keyboard hook:i:1
echo keyboard:redirect:i:1
echo redirectclipboard:i:1
echo session bpp:i:32
echo allow font smoothing:i:1
echo allow desktop composition:i:1
) > "%TEMP%\kde_desktop.rdp"

mstsc "%TEMP%\kde_desktop.rdp"

del "%TEMP%\kde_desktop.rdp" 2>nul