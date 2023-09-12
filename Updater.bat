@echo off

cd /d %~dp0

set HERE=%~dp0
set HERE_DS=%HERE:\=\\%

set BUSYBOX="%HERE%App\Utils\busybox.exe"
set CURL="%HERE%App\Utils\curl.exe"
set SZIP="%HERE%App\Utils\7za.exe"

:::::: NETWORK CHECK

%CURL% -I -s www.google.com | %BUSYBOX% grep -q "403"

if "%ERRORLEVEL%" == "1" (
  echo Check Your Network Connection
  pause
  exit
)

::::::::::::::::::::

:::::: VERSION CHECK

if not exist "%WINDIR%\system32\wbem\wmic.exe" goto LATEST

wmic datafile where name='%HERE_DS%App\\Session\\Session.exe' get version | %BUSYBOX% tail -n2 | %BUSYBOX% cut -c 1-6 > current.txt

for /f %%V in ('more current.txt') do (set CURRENT=%%V)
echo Current: %CURRENT%

:LATEST

set LATEST_URL="https://github.com/oxen-io/session-desktop/releases/latest"

%CURL% -I -k -s %LATEST_URL% | %BUSYBOX% grep -o tag/v[0-9.]\+[0-9] | %BUSYBOX% cut -d "v" -f2 > latest.txt

for /f %%V in ('more latest.txt') do (set LATEST=%%V)
echo Latest: %LATEST%

if exist "current.txt" del "current.txt" > NUL
if exist "latest.txt" del "latest.txt" > NUL

if "%CURRENT%" == "%LATEST%" (
  echo You Have The Latest Version
  pause
  exit
) else goto PROCESS

::::::::::::::::::::

:PROCESS

:::::: RUNNING PROCESS CHECK

if not exist "%WINDIR%\system32\tasklist.exe" goto GET

for /f %%P in ('tasklist /NH /FI "IMAGENAME eq Session.exe"') do if %%P == Session.exe (
  echo Close Session To Update
  pause
  exit
)

::::::::::::::::::::

:GET

:::::: GET LATEST VERSION

if exist "TMP" rmdir "TMP" /s /q
mkdir "TMP"

set SESSION="https://github.com/oxen-io/session-desktop/releases/download/v%LATEST%/session-desktop-win-x64-%LATEST%.exe"

%CURL% -k -L %SESSION% -o TMP\Session_%LATEST%.exe

::::::::::::::::::::

:::::: UNPACKING

if exist "App\Session" rmdir "App\Session" /s /q

%SZIP% x -aoa TMP\Session_%LATEST%.exe -o"App\Session" > NUL

rmdir "TMP" /s /q

::::::::::::::::::::

:::::: APP INFO

%BUSYBOX% sed -i "/Version/d" "%HERE%App\AppInfo\AppInfo.ini"
echo. >> "App\AppInfo\AppInfo.ini"
echo [Version] >> "App\AppInfo\AppInfo.ini"
echo DisplayVersion=%LATEST% >> "App\AppInfo\AppInfo.ini"

::::::::::::::::::::

echo Done

pause
