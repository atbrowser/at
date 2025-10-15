const { ipcRenderer } = require('electron')

document.getElementById('more-button').addEventListener('mousemove', () => {
    ipcRenderer.send('trigger-haptic-feedback', 2)
})