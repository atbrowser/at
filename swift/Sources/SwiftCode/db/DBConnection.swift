import Foundation
import SQLite

public class DBConnection {
    private let isDev = true
    public let db: Connection
    
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
    }
}