#!/usr/bin/env zsh

set -e
set -u

echo

if [ ! -f ../../buildSpec.json ] || [ ! -f ../../globalBuildResources/i18nPatch.json ] || [ ! -f ../buildResources/setup/app_setup.json ]; then
  ./app_setup.zsh
  echo
  echo "  +-----------------------------------------------------------------------------+"
  echo "  | Config files were rebuilt by \`./app_setup.bsh\` as one or more were missing. |"
  echo "  +-----------------------------------------------------------------------------+"
  echo 
fi

# Do not clean if the -c $1 positional argument is provided
buildWithoutClean="${1:-yes}" # -c = "yes"
if ! [[ $buildWithoutClean =~ ^(-c) ]]; then
  ./clean.bsh
fi

if [ ! -f ../../local_server/target/release/local_server ]; then
    echo "Building local server"
    cd ../../local_server
    OPENSSL_STATIC=yes cargo build --release
    cd ../macos/scripts
fi

if [ ! -d ../build ]; then
  echo "Assembling build environment"
  node ./build.js
fi
