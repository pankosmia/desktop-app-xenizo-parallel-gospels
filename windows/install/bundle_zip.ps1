# This script uses the APP_VERSION environment variable as defined in app_config.env

# This script is meant for use with gh action runner, and does not confirm the server is off because it is a new run each time.
# It is run from pankosmia\[this-repo's-name]\windows\install directory in powershell by:  .\bundle_zip.ps1

# Assumes app_setup.bat has already been run, along with `npm install` on this repo; They have in buildWindowsX64.yml

get-content ..\..\app_config.env | foreach {
  $name, $value = $_.split('=')
  if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
    # skip empty or comment line in ENV file
    return
  }
  Set-Variable -Name $name -Value $value
}

# Ths shouldn't happen in gh actions as the runner would have just built the server
If (-Not (Test-Path ..\..\local_server\target\release\local_server.exe)) {
  echo "`n"
  echo "   ***************************************************************"
  echo "   * IMPORTANT: Build the local server, then re-run this script! *"
  echo "   ***************************************************************"
  echo "`n"
  exit
}

echo "`n"
echo "Version is $APP_VERSION"
echo "`n"

cd ..\..\
# Ths shouldn't ever happen in gh actions as the runner is new each time
If (Test-Path releases\windows\*.zip) {
  echo "A previous windows .zip release exists. Removing..."
  Remove-Item releases\windows\*.zip
}

# Assumes build_server_wo_clean.bat has just been run.
cd windows\build
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
cd ..\install