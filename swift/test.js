
// Load our addon
const myAddon = require('./js')

// Try the helloWorld function
const result = myAddon.helloWorld('This is a test')

// Should print: "Hello from Swift! You said: This is a test"
console.log(result)

// Test haptic feedback
console.log('\nTesting Haptic Feedback:')
console.log('Playing haptic pattern 0 (generic)...')
myAddon.triggerHapticFeedback(0)

setTimeout(() => {
  console.log('Playing haptic pattern 1 (alignment)...')
  myAddon.triggerHapticFeedback(1)
}, 500)

setTimeout(() => {
  console.log('Playing haptic pattern 2 (level change)...')
  myAddon.triggerHapticFeedback(2)
}, 1000)

setTimeout(() => {
  console.log('\nHaptic feedback test complete!')
  console.log('If your Mac has a Force Touch trackpad, you should have felt the haptic feedback.')
}, 1500)