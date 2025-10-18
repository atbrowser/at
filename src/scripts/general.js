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
        command: 'dt',
        function: () => {
            ipcRenderer.send('devtools');
        }
    },
    {
        command: 'native',
        function: () => {
            ipcRenderer.send('swiftui');
        }
    },
    {
        command: 'help',
        function: () => {
            document.querySelector('.contentarea').innerHTML = `
<pre>
<code>
    Non-JavaScript commands:
        help - Show this page
        devtools - Open the developer tools
        dt - Open the developer tools
        native - Open the native GUI
</code>
<code>
    JavaScript commands:
        wv -> webview selector
        wv.add() -> Add a webview to the contentarea 
        wv.url(url) -> Set the url of the webview (adds a webview too if none exists)
        wv.reload() -> Reload the webview
        wv.stop() -> Stop loading of the webview
    The other JS scripts could be used here as well.
</code>
</pre>
            `;
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