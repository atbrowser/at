import Foundation
import SQLite

public class SQLManager {
    private let isDev = true
    private let db: Connection
    
    // Define table
    private let users = Table("users")
    
    // Define columns
    private let id = Expression<Int64>("id")
    private let email = Expression<String>("email")
    private let name = Expression<String?>("name")
    
    public init() throws {
      // Get the Application Support directory for the current user
        let fileManager = FileManager.default
        
        guard let appSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw NSError(domain: "SQLManager", code: 1, 
                         userInfo: [NSLocalizedDescriptionKey: "Could not find Application Support directory"])
        }
        let appURL = appSupportURL.appendingPathComponent("at", isDirectory: true)
        try fileManager.createDirectory(at: appURL, withIntermediateDirectories: true)
        let dbURL = appURL.appendingPathComponent("my.db")
        
        if isDev {
            db = try Connection("./swift/Sources/SwiftCode/db/my.db")
        } else {
            db = try Connection(dbURL.path)
        }
        
        try createTable()
    }
    
    private func createTable() throws {
        try db.run(users.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(email, unique: true)
            t.column(name)
        })
    }
    
    public func insertUser(email: String, name: String?) throws {
        try db.run(users.insert(self.email <- email, self.name <- name))
    }
    
    public func getAllUsers() throws -> [Row] {
        return try Array(db.prepare(users))
    }
}