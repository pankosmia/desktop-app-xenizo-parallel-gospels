@echo off

if not exist ..\..\buildSpec.json set runSetup=1
if not exist ..\..\globalBuildResources\i18nPatch.json set runSetup=1
if not exist ..\buildResources\setup\app_setup.json set runSetup=1
if defined %runSetup (
  cmd /c .\app_setup.bat
  echo.
  echo   +-----------------------------------------------------------------------------+
  echo   ^| Config files were rebuilt by `./app_setup.bsh` as one or more were missing. ^|
  echo   +-----------------------------------------------------------------------------+
  echo.
)

REM set port environment variables
set ROCKET_PORT=19119
set RUST_BACKTRACE=1
if exist ..\build (
  echo "Removing last build environment"
  rmdir ..\build /s /q
)
if not exist ..\build (
  echo "Assembling build environment"
  node build.js
)
echo "Running..."
cd ..\build
SET APP_RESOURCES_DIR=.\lib\
start "" ".\bin\server.exe"