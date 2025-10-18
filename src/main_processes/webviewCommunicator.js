const { app, ipcMain, BrowserWindow } = require('electron');
const myAddon = require('../../swift')

app.on("ready", () => {
    ipcMain.on('swipe-coordinates', (event, arg) => {
        console.log(`Swipe coordinates: (${arg[0]}, ${arg[1]})`);
        const focusedWindow = BrowserWindow.getFocusedWindow();
        if (focusedWindow) {
            focusedWindow.webContents.send('swipe-coordinates', arg);
        }
    })
    ipcMain.on('trigger-haptic-feedback', (event, arg) => {
        console.log(`Trigger haptic feedback: ${arg}`);
        myAddon.triggerHapticFeedback(arg)
    })
    ipcMain.on('devtools', (event, arg) => {
        const focusedWindow = BrowserWindow.getFocusedWindow();
        focusedWindow.webContents.openDevTools();
    })
    ipcMain.on('swiftui', (event, arg) => {
        myAddon.nativeGui();
    })
});