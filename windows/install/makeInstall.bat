@echo off
REM run from pankosmia\[this-repo's-name]\windows\install\makeInstall.bat
REM This script requires the APP_VERSION and APP_NAME environment variables to be defined in app_config.env

REM This pulls app_config.env into environment variables; They are also accessible by makeInstall.iss when it is called.
for /F "tokens=1,2 delims==" %%A in (..\..\app_config.env) do set %%A=%%B

REM Remove single quotes from around APP_NAME
SET APP_NAME=%APP_NAME:'=%

ECHO App Name is: %APP_NAME%
ECHO Version is: %APP_VERSION%

REM Set the path to ISCC.exe, modify it if necessary
SET INNO_COMPILER_PATH="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

REM Path to the makeInstall.iss script file
SET SCRIPT_PATH="%~dp0makeInstall.iss"
SET OUTPUT_PATH="%~dp0..\..\releases\windows"

REM Run Inno Setup Compiler with the makeInstall.iss script
%INNO_COMPILER_PATH% -O"%OUTPUT_PATH%" %SCRIPT_PATH%

REM Check for errors
IF ERRORLEVEL 1 (
   echo Build failed with errors.
   exit /b 1
) ELSE (
   echo Build succeeded.
)
