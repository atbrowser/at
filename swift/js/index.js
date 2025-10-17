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

  helloGui () {
    this.addon.helloGui()
  }

  triggerHapticFeedback (pattern) {
    this.addon.triggerHapticFeedback(pattern)
  }

  // CouchDB methods
  initCouchDB (host, port, username, password) {
    return this.addon.initCouchDB(host, port, username, password)
  }

  getAllDBs (callback) {
    this.addon.getAllDBs((result, error) => {
      if (error) {
        callback(null, error)
      } else {
        callback(JSON.parse(result), null)
      }
    })
  }

  createDB (dbName, callback) {
    this.addon.createDB(dbName, (result, error) => {
      if (error) {
        callback(null, error)
      } else {
        callback(JSON.parse(result), null)
      }
    })
  }

  deleteDB (dbName, callback) {
    this.addon.deleteDB(dbName, (result, error) => {
      if (error) {
        callback(null, error)
      } else {
        callback(JSON.parse(result), null)
      }
    })
  }

  insertDocument (dbName, documentJson, callback) {
    this.addon.insertDocument(dbName, documentJson, (result, error) => {
      if (error) {
        callback(null, error)
      } else {
        callback(JSON.parse(result), null)
      }
    })
  }

  getDocument (dbName, docId, callback) {
    this.addon.getDocument(dbName, docId, (result, error) => {
      if (error) {
        callback(null, error)
      } else {
        callback(JSON.parse(result), null)
      }
    })
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