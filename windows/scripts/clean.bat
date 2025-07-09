@echo off

echo.
:choice
set /P c=Is the server off?[Y/N]?
if /I "%c%" EQU "Y" goto :server_off
if /I "%c%" EQU "N" goto :server_on
goto :choice


:server_on

echo.
echo      Exiting...
echo.
echo      If the server is on, turn it off by exiting the terminal window in which it is running, then re-run this script.
echo.
exit

:server_off

echo Cleaning...

if exist ..\build (
  echo Removing last build environment
  rmdir ..\build /s /q
)

if exist ..\..\local_server\target\release\local_server.exe (
    echo Cleaning local server
    cd ..\..\local_server
    cargo clean
    cd ..\windows\scripts
)

echo.
echo The local server and build environment have been cleaned.
echo.
