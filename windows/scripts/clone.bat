@echo off
for /F "tokens=1,2 delims==" %%a in (..\..\app_config.env) do set %%a=%%b

setlocal ENABLEDELAYEDEXPANSION

set count=0
for /f "tokens=*" %%a in (..\..\app_config.env) do (
  set /a count+= 1
)

cd ..\..\..\
for /l %%a in (1,1,%count%) do (
  if "!ASSET%%a!" NEQ "" (
    REM Remove any spaces, e.g. trailing ones
    set ASSET%%a=!ASSET%%a: =!
    echo "############################### BEGIN Asset %%a: !ASSET%%a! ###############################"
    if not exist !ASSET%%a! (
      git clone https://github.com/pankosmia/!ASSET%%a!.git
    ) else (
      echo "Directory already exists; Not cloned."
    )
    echo "################################ END Asset %%a: !ASSET%%a! ################################"
    echo.
  )
)
for /l %%a in (1,1,%count%) do (
  if "!CLIENT%%a!" NEQ "" (
    REM Remove any spaces, e.g. trailing ones
    set CLIENT%%a=!CLIENT%%a: =!
    echo "############################### BEGIN Client %%a: !CLIENT%%a! ###############################"
    if not exist !CLIENT%%a! (
      git clone https://github.com/pankosmia/!CLIENT%%a!.git
    ) else (
      echo "Directory already exists; Not cloned."
    )
    echo "################################ END Client %%a: !CLIENT%%a! ################################"
    echo.
  )
)

REM Remove apostrophes (') from APP_NAME for file path
set APP_NAME=%APP_NAME:'=%
REM Change spaces to dashes (-) from APP_NAME for file path
set APP_NAME=%APP_NAME: =-%
REM Ignoring uppercase in APP_NAME as they are treated the same as lowercase in windows file paths
cd desktop-app-%APP_NAME%\windows\scripts

endlocal