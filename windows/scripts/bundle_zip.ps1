# This script uses the APP_VERSION environment variable as defined in app_config.env

# run from pankosmia\desktop-app-[APP NAME]\windows\scripts directory in powershell by:  .\bundle_zip.ps1

echo "`n"
$answer = Read-Host "     Is the server off?[Y/N]"
if ($answer -eq 'Y') {
    echo "`n"
    echo "Continuing..."
    echo "`n"

  get-content ..\..\app_config.env | foreach {
    $name, $value = $_.split('=')
    if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
      # skip empty or comment line in ENV file
      return
    }
    Set-Variable -Name $name -Value $value
  }

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

  echo "`n"
  echo "Version is $APP_VERSION"
  echo "`n"

  cd ..\..\
  If (Test-Path releases\windows\*.zip) {
    echo "A previous windows .zip release exists. Removing..."
    Remove-Item releases\windows\*.zip
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
  cd ..\build
  echo "`n"
  echo "   *****************************************************************************************"
  echo "   *                                                                                       *"
  echo "   *                                          =====                                        *"
  echo "   * Bundling. Wait for the powershell prompt AFTER the compression progress bar finishes. *"
  echo "   *                                          =====                                        *"
  echo "   *                                                                                       *"
  echo "   *****************************************************************************************"
  echo "`n"

  # Use lower case app name in filename and replace spaces with dashes (-) and remove single apostrophes (')
  $APP_NAME = $APP_NAME.ToLower().Replace(" ","-").Replace("'","")
  Compress-Archive * ..\..\releases\windows\$APP_NAME-windows-$APP_VERSION.zip
  cd ..\scripts

} elseif ($answer -eq 'N') {
    echo "`n"
    echo "     Exiting..."
    echo "`n"
    echo "     If the server is on, turn it off by exiting the terminal window in which it is running, then re-run this script.";
    echo "`n"
} else {
    echo "`n"
    echo "     Invalid input. Please enter Y or N."
    .\bundle_zip.ps1
}