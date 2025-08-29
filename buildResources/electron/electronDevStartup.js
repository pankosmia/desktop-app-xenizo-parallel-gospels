/**
 * @fileoverview Electron startup script for managing application lifecycle and window creation. (This is the dev viewer version; Server start and stop is handled separately.)
 *
 * @synopsis
 * This script serves as the main entry point for the dev version the Electronite viewer, handling:
 * - Application window management
 * - Custom menu creation (especially for macOS)
 * - Application events and shutdown procedures
 *
 * @description
 * The script manages the lifecycle of the Electron frontend. (This is the dev viewer version; The backend server process is handled separately.)
 * It creates the main application viewer window on port 19119,
 * For macOS, it creates a custom application menu with standard operations.
 *
 * @requirements
 * - Electron.js
 * - A compatible backend server binary (server.bin for macOS/Linux or server.exe for Windows)
 * - Port 19119 must be available for the backend server
 * - For macOS/Linux: lsof command must be available for port checking
 * - Environment variable APP_NAME must be set for proper application naming
 */

const { app, BrowserWindow, Menu, shell, ipcMain, ipcRenderer, contextBridge, dialog } = require('electron');
const { spawn, execSync } = require('child_process');
const path = require('path');

app.name = '${APP_NAME}';
const port = '19119';
let canClose = true;

/**
 * wraps timer in a Promise to make an async function that continues after a specific number of milliseconds.
 * @param {number} ms
 * @returns {Promise<unknown>}
 */
function delay(ms) {
  return new Promise((resolve) =>
    setTimeout(resolve, ms)
  );
}

function handleSetCanClose(event, newCanClose) {
    canClose = newCanClose;
}

function createWindow() {
    delay(500).then(() => {
        console.log('createWindow() - dev viewer');
        const win = new BrowserWindow({
            width: 1024,
            height: 768,
            autoHideMenuBar: true,
            show: false,  // Don't show until ready to maximize
            icon: path.join(__dirname, 'icon.png'),
            webPreferences: {
                preload: path.join(__dirname, 'preload.js')
              }
        });

        win.once('ready-to-show', () => {
            win.maximize();
            win.show();
        });

        // Show a dialog to the user to confirm the close
        win.on('close', (event) => {
            if (!canClose) {
                event.preventDefault();
                dialog.showMessageBox(win, {
                    type: 'question',
                    title: 'Unsaved changes',
                    message: 'You have unsaved changes. Are you sure you want to close the application?',
                    buttons: ['Yes', 'No'],
                }).then((result) => {
                    if (result.response === 0) {
                        canClose = true;
                        win.close();
                    }
                });
            }
        });

        // Show a dialog to the user switch pages
        win.webContents.on('will-navigate', async (event, url) => {
            if (!canClose) {
                event.preventDefault();
                dialog.showMessageBox(win, {
                    title: 'Unsaved changes',
                    type: 'question',
                    message: 'You have unsaved changes. Are you sure you want to leave this page?',
                    buttons: ['Yes', 'No'],
                }).then((result) => {
                    if (result.response === 0) {
                        canClose = true;
                        win.loadURL(url);
                    }
                });
            }
        });

        win.loadURL(`http://127.0.0.1:${port}`);
    })

}

app.whenReady().then(() => {
  // Set a custom menu with desired app name
  ipcMain.on('setCanClose', handleSetCanClose);
  const isMac = process.platform === 'darwin';
  if (isMac) {
    const template = [
      {
        label: app.name, // <--- This name will show in the macOS app menu
        submenu: [
          {role: 'hide'},
          {role: 'hideothers'},
          {role: 'unhide'},
          {type: 'separator'},
          {role: 'quit'}
        ]
      },
      {
        label: 'Edit',
        submenu: [
          {role: 'undo'},
          {role: 'redo'},
          {type: 'separator'},
          {role: 'cut'},
          {role: 'copy'},
          {role: 'paste'},
          {role: 'pasteAndMatchStyle'},
          {role: 'delete'},
          {role: 'selectAll'}
        ]
      },
      {
        label: 'View',
        submenu: [
          {role: 'reload'},
          {role: 'forcereload'},
          {role: 'toggledevtools'},
          {type: 'separator'},
          {role: 'resetzoom'},
          {role: 'zoomin'},
          {role: 'zoomout'},
          {type: 'separator'},
          {role: 'togglefullscreen'}
        ]
      },
      {
        label: 'Window',
        submenu: [
          {role: 'minimize'},
          {role: 'zoom'},
          {type: 'separator'},
          {role: 'front'},
          {role: 'window'}
        ]
      }
    ];
    // Removed from the first menu section above for now:
      /**
            {role: 'about'},
            {type: 'separator'},
            {role: 'services'},
            {type: 'separator'},
      */
    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);
  }

  setTimeout(createWindow, 0); // Wait 0 seconds for server to start (dev viewer)
});

app.on('window-all-closed', () => {
  console.log('window-all-closed() - app quitting');
  // On macOS, apps are expected to stay alive until explicitly quit
  // but we quit anyway so server doesn't remain running
  app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    console.log('activate() - app creating window since there are none');
    createWindow();
  } else {
    console.log('activate() - app not creating window since there are already windows');
  }
});