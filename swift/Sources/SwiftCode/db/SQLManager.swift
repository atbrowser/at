import Foundation
import SQLite

public class SQLManager {
    private let db: Connection
    
    // Define table
    private let users = Table("users")
    
    // Define columns
    private let id = Expression<Int64>("id")
    private let email = Expression<String>("email")
    private let name = Expression<String?>("name")
    
    public init() throws {
        // Initialize database connection
        db = try Connection("./my.db")
        
        // Create table if it doesn't exist
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