@echo off
REM Run from pankosmia\[this-repo's-name]\windows\scripts directory in powershell or command by:  .\build_server.bat
REM Git hub actions use this with optional arguments of: .\build_server.bat -c
REM because it is a brand new clean environment without need for any prior build to be removed.

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

IF NOT "%~1"=="-c" (
  call .\clean.bat
)
if not exist ..\..\local_server\target\release\local_server.exe (
    echo "Building local server..."
    cd ..\..\local_server
    cargo build --release
    cd ..\windows\scripts
)
if not exist ..\build (
  echo "Assembling build environment..."
  node build.js
)
