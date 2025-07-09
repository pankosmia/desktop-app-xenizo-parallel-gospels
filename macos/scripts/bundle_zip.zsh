#!/usr/bin/env zsh

# This script uses the APP_VERSION and APP_NAME environment variables as defined in app_config.env

# run from pankosmia/[this-repo's-name]/macos/scripts directory by:  ./bundle_tgz.zsh

echo
if read -q "choice?Is the server off?[Y/N]? "; then

  source ../../app_config.env

  if [ ! -f ../../local_server/target/release/local_server ]; then
    echo
    echo "   ***************************************************************"
    echo "   * IMPORTANT: Build the local server, then re-run this script! *"
    echo "   ***************************************************************"
    echo
    exit
  fi

  echo
  echo "Running app_setup to ensure version number consistency between buildSpec.json and this build bundle:"
  ./app_setup.zsh

  echo
  echo "Version is $APP_VERSION"
  echo

  cd ../../

  if [ $(ls releases/macos/*.zip 2>/dev/null | wc -l) -gt 0 ]; then
    echo "A previous macos .zip release exists. Removing..."
    rm releases/macos/*.zip
  fi

  echo "checkout main"
  git checkout main &> /dev/null
  echo "pull"
  git pull
  echo "npm install"
  npm install
  cd macos/scripts

  if [ -f ../build ]; then
    echo "Removing last build environment"
    rm -rf ../build
  fi

  echo "Assembling build environment"
  node build.js
  echo
  echo "   **********************************"
  echo "   *                                *"
  echo "   *           ====                 *"
  echo "   * Bundling. Wait for the prompt. *"
  echo "   *           ====                 *"
  echo "   *                                *"
  echo "   **********************************"
  echo

  cd ../build
  # Use lower case app name in filename
  APP_NAME=${APP_NAME:l}
  # Replace spaces with a dash (-) in filename
  APP_NAME=${APP_NAME// /-}
  # Make executable and zip
  chmod +x $APP_NAME.zsh
  zip -r ../../releases/macos/$APP_NAME-macos-$APP_VERSION.zip * -x post_install_script.sh appLauncher.sh
  cd ../scripts

else
  echo
  echo
  echo "Exiting..."
  echo
  echo "If the server is on, turn it off with Ctrl-C in the terminal window in which it is running, then re-run this script.";
  echo
fi