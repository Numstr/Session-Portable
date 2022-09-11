@echo off
SetLocal EnableExtensions EnableDelayedExpansion

cd /d %~dp0

set HERE=%~dp0

set BUSYBOX="%HERE%App\Utils\busybox.exe"
set CURL="%HERE%App\Utils\curl.exe"
set SZIP="%HERE%App\Utils\7za.exe"

:::::: NETWORK CHECK

%CURL% -is www.google.com | %BUSYBOX% grep -q "200 OK"

if "%ERRORLEVEL%" == "1" (
  echo Check Your Network Connection
  pause
  exit
)

::::::::::::::::::::

:::::: VERSION CHECK

set LATEST="https://github.com/oxen-io/session-desktop/releases/latest"

%CURL% -s -k -I %LATEST% | %BUSYBOX% grep -o tag/v[0-9.]\+[0-9] | %BUSYBOX% cut -d "v" -f2 > version.txt

for /f %%V in ('more version.txt') do (set VERSION=%%V)
echo Latest: %VERSION%

if exist "version.txt" del "version.txt" > NUL

::::::::::::::::::::

:::::: RUNNING PROCESS CHECK

for /f %%P in ('tasklist /NH /FI "IMAGENAME eq Session.exe"') do if %%P == Session.exe (
  echo Close Session To Update
  pause
  exit
)

::::::::::::::::::::

:::::: GET LATEST VERSION

if exist "TMP" rmdir "TMP" /s /q
mkdir "TMP"

set SESSION="https://github.com/oxen-io/session-desktop/releases/download/v%VERSION%/session-desktop-win-%VERSION%.exe"

%CURL% -# -k -L %SESSION% -o TMP\Session_%VERSION%.exe

::::::::::::::::::::

:::::: UNPACKING

if exist "App\Session" rmdir "App\Session" /s /q

%SZIP% x -aoa TMP\Session_%VERSION%.exe -o"App\Session"

::::::::::::::::::::

rmdir "TMP" /s /q

pause
