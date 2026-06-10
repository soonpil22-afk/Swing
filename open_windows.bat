@echo off
rem Open two phone-sized Chrome windows (left = admin, right = driver). Run run_web.bat first.
set CHROME="C:\Program Files\Google\Chrome\Application\chrome.exe"
if not exist %CHROME% set CHROME="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

start "" %CHROME% --app=http://localhost:5001 --window-size=400,1010 --window-position=0,0 --user-data-dir=%TEMP%\st_admin
start "" %CHROME% --app=http://localhost:5001 --window-size=400,1010 --window-position=420,0 --user-data-dir=%TEMP%\st_driver
