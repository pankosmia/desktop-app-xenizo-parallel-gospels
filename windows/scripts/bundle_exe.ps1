# This script (the .\makeInstall.bat part) uses the APP_VERSION environment variable as defined in app_config.env

# NOTE: This exe launcher leaves no way to turn off the server other than rebooting the computer or using Task Manager

# run from pankosmia\[this-repo's-name]\windows\scripts directory in powershell by:  .\bundle_zip.ps1

echo "`n"
$answer = Read-Host "     Is the server off?[Y/N]"
if ($answer -eq 'Y') {
    echo "`n"
    echo "Continuing..."
    echo "`n"

  If (-Not (Test-Path ..\..\local_server\target\release\local_server.exe)) {
    echo "`n"
    echo "   ***************************************************************"
    echo "   * IMPORTANT: Build the local server, then re-run this script! *"
    echo "   ***************************************************************"
    echo "`n"
    pause
    exit
  }

  echo "`n"
  echo "Running app_setup to ensure version number consistency between buildSpec.json and this build bundle:"
  .\app_setup.bat

  cd ..\..\
  If (Test-Path releases\windows\*.exe) {
    echo "A previous windows .exe release exists. Removing..."
    Remove-Item releases\windows\*.exe
  }
  echo "checkout main"
  git checkout main | Out-Null
  echo "pull"
  git pull
  echo "npm install"
  npm install
  cd windows\scripts
  if (Test-Path ..\build) {
    echo "Removing last build environment"
    rm ..\build -r -force
  }
  echo "Assembling build environment"
  node build.js
  cd ..\install
  echo "Making .exe installer..."
  .\makeInstall.bat
  cd ..\scripts

} elseif ($answer -eq 'N') {
    echo "`n"
    echo "     Turn the server off by exiting the terminal window in which it is running, then re-run this script while the server is off."
    echo "`n"
} else {
    echo "`n"
    echo "     Invalid input. Please enter Y or N."
    .\bundle_exe.ps1
}