const { ipcRenderer } = require('electron')

document.getElementById('more-button').addEventListener('click', () => {
    ipcRenderer.send('trigger-haptic-feedback', 2)
})

const commandInput = document.getElementById('command-input');
const nonJScommands = [
    {
        command: 'devtools',
        function: () => {
            ipcRenderer.send('devtools');
        }
    },
    {
        command: 'swiftui',
        function: () => {
            ipcRenderer.send('swiftui');
        }
    }
]
commandInput.addEventListener('keypress', (event) => {
    if (event.key === 'Enter') {
        try {
            eval(commandInput.value);
        } catch (error) {
            if (nonJScommands.find(command => command.command === commandInput.value)) {
                nonJScommands.find(command => command.command === commandInput.value).function();
            } else {
                console.error(error);
                alert('Error: ' + error.message);
            }
        }
    }
})