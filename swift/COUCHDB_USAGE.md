# CouchDB Integration Usage

This document explains how to use the CouchDB Swift integration in your Node.js application.

## Installation

First, build the Swift addon:

```bash
cd swift
npm install
npm run build
```

## Usage

### Initialize CouchDB Client

```javascript
const swiftAddon = require('./swift/js/index.js')

// Initialize the CouchDB client
const result = swiftAddon.initCouchDB('localhost', 5984, 'admin', 'password')
console.log(result) // "CouchDB client initialized"
```

### Get All Databases

```javascript
swiftAddon.getAllDBs((dbs, error) => {
  if (error) {
    console.error('Error:', error)
    return
  }
  console.log('Databases:', dbs)
})
```

### Create a Database

```javascript
swiftAddon.createDB('mydb', (response, error) => {
  if (error) {
    console.error('Error:', error)
    return
  }
  console.log('Database created:', response)
})
```

### Insert a Document

```javascript
const document = {
  _id: 'doc1',
  name: 'John Doe',
  age: 30
}

swiftAddon.insertDocument('mydb', JSON.stringify(document), (response, error) => {
  if (error) {
    console.error('Error:', error)
    return
  }
  console.log('Document inserted:', response)
})
```

### Get a Document

```javascript
swiftAddon.getDocument('mydb', 'doc1', (document, error) => {
  if (error) {
    console.error('Error:', error)
    return
  }
  console.log('Document:', document)
})
```

### Delete a Database

```javascript
swiftAddon.deleteDB('mydb', (response, error) => {
  if (error) {
    console.error('Error:', error)
    return
  }
  console.log('Database deleted:', response)
})
```

## Complete Example

```javascript
const swiftAddon = require('./swift/js/index.js')

// Initialize CouchDB client
console.log(swiftAddon.initCouchDB('localhost', 5984, 'admin', 'password'))

// Get all databases
swiftAddon.getAllDBs((dbs, error) => {
  if (error) {
    console.error('Error getting databases:', error)
    return
  }
  console.log('Available databases:', dbs)
  
  // Create a new database
  swiftAddon.createDB('testdb', (createResponse, createError) => {
    if (createError) {
      console.error('Error creating database:', createError)
      return
    }
    console.log('Database created:', createResponse)
    
    // Insert a document
    const doc = {
      _id: 'test-doc-1',
      title: 'Test Document',
      content: 'This is a test'
    }
    
    swiftAddon.insertDocument('testdb', JSON.stringify(doc), (insertResponse, insertError) => {
      if (insertError) {
        console.error('Error inserting document:', insertError)
        return
      }
      console.log('Document inserted:', insertResponse)
      
      // Retrieve the document
      swiftAddon.getDocument('testdb', 'test-doc-1', (getResponse, getError) => {
        if (getError) {
          console.error('Error getting document:', getError)
          return
        }
        console.log('Retrieved document:', getResponse)
      })
    })
  })
})
```

## Notes

- All CouchDB operations are asynchronous and use callbacks
- The CouchDB client must be initialized before any other operations
- Callbacks follow the Node.js convention: `(result, error)`
- If an error occurs, `result` will be `null` and `error` will contain the error message
- If successful, `error` will be `null` and `result` will contain the response data

