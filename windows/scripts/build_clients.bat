@echo off
for /F "tokens=1,2 delims==" %%A in (..\..\app_config.env) do set %%A=%%B

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
      echo.
      echo "****************************************************"
      echo "!ASSET%%a! does not exist; Run .\clone.bat"
      echo "****************************************************"
      echo.
    ) else (
      cd !ASSET%%a!
      call git checkout main
      call git pull
      echo "################################ END Asset %%a: !ASSET%%a! ################################"
      echo.
      cd ..
    )
  )
)
for /l %%a in (1,1,%count%) do (
  if "!CLIENT%%a!" NEQ "" (
    REM Remove any spaces, e.g. trailing ones
    set CLIENT%%a=!CLIENT%%a: =!
    echo "############################### BEGIN Client %%a: !CLIENT%%a! ###############################"
    if not exist !CLIENT%%a! (
      echo.
      echo "***************************************************************************************"
      echo "!CLIENT%%a! does not exist; Run .\clone.bat then rerun .\build_clients_main.bat"
      echo "***************************************************************************************"
      echo.
    ) else (
      cd !CLIENT%%a!
      call git checkout main
      call git pull
      call npm install
      call npm run build
      echo "################################ END Client %%a: !CLIENT%%a! ################################"
      echo.
      cd ..  
    )
  )
)

REM Remove apostrophes (') from APP_NAME for file path
set APP_NAME=%APP_NAME:'=%
REM Change spaces to dashes (-) from APP_NAME for file path
set APP_NAME=%APP_NAME: =-%
REM Ignoring uppercase in APP_NAME as they are treated the same as lowercase in windows file paths
cd desktop-app-%APP_NAME%\windows\scripts

endlocal