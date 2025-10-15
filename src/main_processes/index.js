const { app, screen, ipcMain, BrowserWindow, globalShortcut } = require('electron');
const path = require('path');
const myAddon = require('../../my-native-addon/')

console.log(myAddon.helloWorld('Electron'))

const mainWindow = require(path.join(__dirname, './mainWindow.js'));
const webviewCommunicator = require(path.join(__dirname, './webviewCommunicator.js'));
const appStorageManager = require(path.join(__dirname, './appStorageManager.js'));

try {
    require('electron-reloader')(module)
} catch (_) {}

