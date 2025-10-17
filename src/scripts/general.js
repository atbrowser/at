const { ipcRenderer } = require('electron')

document.getElementById('more-button').addEventListener('click', () => {
    ipcRenderer.send('trigger-haptic-feedback', 2)
})

const commandInput = document.getElementById('command-input');
commandInput.addEventListener('keypress', (event) => {
    if (event.key === 'Enter') {
        try {
            eval(commandInput.value);
        } catch (error) {
            console.error(error);
            alert('Error: ' + error.message);
        }
    }
})