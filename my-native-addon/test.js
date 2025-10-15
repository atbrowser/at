
// Load our addon
const myAddon = require('./js')

// Try the helloWorld function
const result = myAddon.helloWorld('This is a test')

// Should print: "Hello from C++! You said: This is a test"
console.log(result)