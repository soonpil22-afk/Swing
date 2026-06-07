@echo off
rem 폰 크기 크롬 창 2개 열기 (왼쪽=관리자 / 오른쪽=기사). run_web.bat 먼저 실행 후 사용
set CHROME="C:\Program Files\Google\Chrome\Application\chrome.exe"
if not exist %CHROME% set CHROME="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

start "" %CHROME% --app=http://localhost:5001 --window-size=400,1010 --window-position=0,0 --user-data-dir=%TEMP%\st_admin
start "" %CHROME% --app=http://localhost:5001 --window-size=400,1010 --window-position=420,0 --user-data-dir=%TEMP%\st_driver
