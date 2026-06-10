@echo off
rem Start Flutter web server. Keep this window open (closing it stops the server).
cd /d C:\JejuProject\swing_tiger

rem Use full flutter path so it works even if flutter is not on cmd PATH
set "FLUTTER=C:\src\flutter\bin\flutter.bat"
if not exist "%FLUTTER%" set "FLUTTER=flutter"

echo [SwingTiger] Web server starting - http://localhost:5001
echo When the URL appears below, double-click open_windows.bat
call "%FLUTTER%" run -d web-server --web-port=5001
echo.
echo ===== Server stopped. Check the messages above. =====
pause
