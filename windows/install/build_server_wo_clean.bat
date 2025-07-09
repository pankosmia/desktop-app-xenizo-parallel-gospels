@echo off

# No need to clean; gh action runner is new
# Overkill to confirm it doesn't already exist on a new runner...
if not exist ..\..\local_server\target\release\local_server.exe (
    echo "Building local server"
    cd ..\..\local_server
    cargo build --release
    # Probably not needed on runner as it needs location specified in the next step...
    cd ..\windows\scripts
)
# Overkill to confirm it doesn't already exist on a new runner...
if not exist ..\build (
  echo "Assembling build environment"
  node ..\scripts\build.js
)