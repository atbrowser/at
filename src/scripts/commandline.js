const commandInput = document.getElementById('command-input');

document.addEventListener('DOMContentLoaded', () => {
    commandInput.focus();
});

const helpText = `
<pre>
<code>
    Non-JavaScript commands:
        help - Show this page
        devtools - Open the developer tools
        dt - Open the developer tools
        native - Open the native GUI
        clear - Clear the contentarea
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
            document.querySelector('.contentarea').innerHTML = helpText;
        }
    },{
    command: 'clear',
    function: () => {
        document.querySelector('.contentarea').innerHTML = '';
    }
}]

// Get all available commands for autocomplete
const allCommands = nonJScommands.map(cmd => cmd.command);

// Create suggestion element
const suggestionSpan = document.createElement('span');
const inputStyles = window.getComputedStyle(commandInput);

suggestionSpan.style.position = 'absolute';
suggestionSpan.style.pointerEvents = 'none';
suggestionSpan.style.left = commandInput.offsetLeft + 'px';
suggestionSpan.style.top = (commandInput.offsetTop + 10.5) + 'px';
suggestionSpan.style.width = inputStyles.width;
suggestionSpan.style.height = inputStyles.height;
suggestionSpan.style.padding = inputStyles.padding;
suggestionSpan.style.paddingLeft = inputStyles.paddingLeft;
suggestionSpan.style.paddingTop = inputStyles.paddingTop;
suggestionSpan.style.fontSize = inputStyles.fontSize;
suggestionSpan.style.fontFamily = inputStyles.fontFamily;
suggestionSpan.style.fontWeight = inputStyles.fontWeight;
suggestionSpan.style.lineHeight = inputStyles.lineHeight;
suggestionSpan.style.letterSpacing = inputStyles.letterSpacing;
suggestionSpan.style.border = 'none';
suggestionSpan.style.whiteSpace = 'pre';

commandInput.parentElement.style.position = 'relative';
commandInput.parentElement.appendChild(suggestionSpan);

let currentSuggestion = '';

commandInput.addEventListener('input', (event) => {
    const inputValue = event.target.value;
    
    if (inputValue.length > 0) {
        // Find matching command
        const match = allCommands.find(cmd => 
            cmd.toLowerCase().startsWith(inputValue.toLowerCase()) && 
            cmd.toLowerCase() !== inputValue.toLowerCase()
        );
        
        if (match) {
            currentSuggestion = match;
            // Create invisible text for typed part, then visible suggestion
            const typedPart = document.createElement('span');
            typedPart.style.opacity = '0';
            typedPart.textContent = inputValue;
            
            const suggestedPart = document.createElement('span');
            suggestedPart.style.color = 'var(--unfocused-color)';
            suggestedPart.textContent = match.slice(inputValue.length);
            
            suggestionSpan.innerHTML = '';
            suggestionSpan.appendChild(typedPart);
            suggestionSpan.appendChild(suggestedPart);
        } else {
            currentSuggestion = '';
            suggestionSpan.innerHTML = '';
        }
    } else {
        currentSuggestion = '';
        suggestionSpan.innerHTML = '';
    }
});

// Accept suggestion with Tab key
commandInput.addEventListener('keydown', (event) => {
    if (event.key === 'Tab' && currentSuggestion) {
        event.preventDefault();
        commandInput.value = currentSuggestion;
        currentSuggestion = '';
        suggestionSpan.innerHTML = '';
    }
});

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