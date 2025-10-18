const EventEmitter = require('node:events')

class SwiftAddon extends EventEmitter {
  constructor () {
    super()

    if (process.platform !== 'darwin') {
      throw new Error('This module is only available on macOS')
    }

    const native = require('bindings')('swift_addon')
    this.addon = new native.SwiftAddon()

    this.addon.on('triggerHapticFeedback', (payload) => {
      this.emit('triggerHapticFeedback', this.parse(payload))
    })
  }

  helloWorld (input = '') {
    return this.addon.helloWorld(input)
  }

  nativeGui () {
    this.addon.nativeGui()
  }

  triggerHapticFeedback (pattern) {
    this.addon.triggerHapticFeedback(pattern)
  }

  parse (payload) {
    const parsed = JSON.parse(payload)

    return { ...parsed, date: new Date(parsed.date) }
  }
}

if (process.platform === 'darwin') {
  module.exports = new SwiftAddon()
} else {
  module.exports = {}
}
