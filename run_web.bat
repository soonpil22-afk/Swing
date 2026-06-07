@echo off
rem 웹 서버 실행 (이 창은 켜둔 채로 두세요. 끄면 서버도 꺼집니다)
cd /d C:\JejuProject\swing_tiger
echo [SwingTiger] 웹 서버 시작 - http://localhost:5001
echo 빌드가 끝나면(아래에 lib... 또는 URL이 보이면) open_windows.bat 을 더블클릭하세요.
call flutter run -d web-server --web-port=5001
echo.
echo ===== 서버가 종료되었습니다. 위 메시지를 확인하세요. =====
pause
