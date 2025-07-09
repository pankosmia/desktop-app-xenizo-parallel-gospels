Steps to run makeInstall.zsh (which requires shc - do `brew install shc`):
1. make sure APP_VERSION, APP_NAME, and all other environment variables are set in app_config.env
2. run clone script
3. run build clients script
4. run build-server script
5. then cd into `macos/install`
6. then run:
```shell
chmod +x ./makeInstall.zsh
./makeInstall.zsh
```