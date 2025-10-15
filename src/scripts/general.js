const { ipcRenderer } = require('electron')

document.getElementById('more-button').addEventListener('click', () => {
    ipcRenderer.send('trigger-haptic-feedback', 2)
})