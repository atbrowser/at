import Foundation
import SQLite

public class SQLManager {
    private let db: DBConnection
    
    // Define table
    private let users = Table("users")
    
    // Define columns
    private let id = Expression<Int64>("id")
    private let email = Expression<String>("email")
    private let name = Expression<String?>("name")
    
    public init() throws {
        db = try DBConnection()
        try createTable()
    }
    
    private func createTable() throws {
        try db.db.run(users.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(email, unique: true)
            t.column(name)
        })
    }
    
    public func insertUser(email: String, name: String?) throws {
        try db.db.run(users.insert(self.email <- email, self.name <- name))
    }
    
    public func getAllUsers() throws -> [[String: Any?]] {
        let rows = try Array(db.db.prepare(users))
        return rows.map { row in
            [
                "id": row[id],
                "email": row[email],
                "name": row[name]
            ]
        }
    }
}