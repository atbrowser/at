import Foundation
import SwiftUI
import CouchDBClient
import AsyncHTTPClient
import NIOFoundationCompat
import NIOCore


// Wrapper class to hold the actor
private class CouchDBClientWrapper {
    let client: CouchDBClient
    
    init(config: CouchDBClient.Config) {
        self.client = CouchDBClient(config: config)
    }
}

@objc
public class SwiftCode: NSObject {
    private static var windowController: NSWindowController?
    private static var clientWrapper: CouchDBClientWrapper?
    
    @objc
    public static func helloWorld(_ input: String) -> String {
        return "Hello from Swift! You said: \(input)"
    }
    
    @objc
    public static func initCouchDB(host: String, port: Int, username: String, password: String) -> String {
        // Initialize in a detached task to ensure proper Swift concurrency context
        Task.detached {
            let config = CouchDBClient.Config(
                couchProtocol: .http,
                couchHost: host,
                couchPort: port,
                userName: username,
                userPassword: password,
                requestsTimeout: 30
            )
            clientWrapper = CouchDBClientWrapper(config: config)
        }
        return "CouchDB client initialization started"
    }
    
    @objc
    public static func getAllDBs(_ callback: @escaping (String?, String?) -> Void) {
        guard let wrapper = clientWrapper else {
            callback(nil, "CouchDB client not initialized")
            return
        }
        
        Task {
            do {
                let dbs = try await wrapper.client.getAllDBs()
                let jsonData = try JSONEncoder().encode(dbs)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    callback(jsonString, nil)
                } else {
                    callback(nil, "Failed to encode response")
                }
            } catch {
                callback(nil, error.localizedDescription)
            }
        }
    }
    
    @objc
    public static func createDB(dbName: String, callback: @escaping (String?, String?) -> Void) {
        guard let wrapper = clientWrapper else {
            callback(nil, "CouchDB client not initialized")
            return
        }
        
        Task {
            do {
                let response = try await wrapper.client.createDB(dbName)
                let jsonData = try JSONEncoder().encode(response)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    callback(jsonString, nil)
                } else {
                    callback(nil, "Failed to encode response")
                }
            } catch {
                callback(nil, error.localizedDescription)
            }
        }
    }
    
    @objc
    public static func deleteDB(dbName: String, callback: @escaping (String?, String?) -> Void) {
        guard let wrapper = clientWrapper else {
            callback(nil, "CouchDB client not initialized")
            return
        }
        
        Task {
            do {
                let response = try await wrapper.client.deleteDB(dbName)
                let jsonData = try JSONEncoder().encode(response)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    callback(jsonString, nil)
                } else {
                    callback(nil, "Failed to encode response")
                }
            } catch {
                callback(nil, error.localizedDescription)
            }
        }
    }
    
    @objc
    public static func insertDocument(dbName: String, documentJson: String, callback: @escaping (String?, String?) -> Void) {
        guard let wrapper = clientWrapper else {
            callback(nil, "CouchDB client not initialized")
            return
        }
        
        guard let documentData = documentJson.data(using: .utf8) else {
            callback(nil, "Invalid JSON string")
            return
        }
        
        Task {
            do {
                let body: HTTPClientRequest.Body = .bytes(ByteBuffer(data: documentData))
                let response = try await wrapper.client.insert(dbName: dbName, body: body)
                let jsonData = try JSONEncoder().encode(response)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    callback(jsonString, nil)
                } else {
                    callback(nil, "Failed to encode response")
                }
            } catch {
                callback(nil, error.localizedDescription)
            }
        }
    }
    
    @objc
    public static func getDocument(dbName: String, docId: String, callback: @escaping (String?, String?) -> Void) {
        guard let wrapper = clientWrapper else {
            callback(nil, "CouchDB client not initialized")
            return
        }
        
        Task {
            do {
                let response = try await wrapper.client.get(fromDB: dbName, uri: docId)
                let body = response.body
                let expectedBytes = response.headers.first(name: "content-length").flatMap(Int.init) ?? 1024 * 1024 * 10
                var bytes = try await body.collect(upTo: expectedBytes)
                
                if let data = bytes.readData(length: bytes.readableBytes),
                   let jsonString = String(data: data, encoding: .utf8) {
                    callback(jsonString, nil)
                } else {
                    callback(nil, "Failed to read response data")
                }
            } catch {
                callback(nil, error.localizedDescription)
            }
        }
    }
    
    @objc
    public static func triggerHapticFeedback(_ pattern: Int) {
        let feedbackPerformer = NSHapticFeedbackManager.defaultPerformer
        
        switch pattern {
        case 0:
            feedbackPerformer.perform(.generic, performanceTime: .default)
        case 1:
            feedbackPerformer.perform(.alignment, performanceTime: .default)
        case 2:
            feedbackPerformer.perform(.levelChange, performanceTime: .default)
        default:
            feedbackPerformer.perform(.generic, performanceTime: .default)
        }
    }
    
    private static func encodeToJson<T: Encodable>(_ item: T) -> String? {
        let encoder = JSONEncoder()

        // Encode date as milliseconds since 1970, which is what the JS side expects
        encoder.dateEncodingStrategy = .custom { date, encoder in
            let milliseconds = Int64(date.timeIntervalSince1970 * 1000)
            var container = encoder.singleValueContainer()
            try container.encode(milliseconds)
        }

        guard let jsonData = try? encoder.encode(item),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }

    @objc
    public static func helloGui() -> Void {
        let contentView = NSHostingView(rootView: ContentView(

        ))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "haptics"
        window.contentView = contentView
        window.center()

        windowController = NSWindowController(window: window)
        windowController?.showWindow(nil)

        NSApp.activate(ignoringOtherApps: true)
    }

    private struct TodoItem: Identifiable, Codable {
        let id: UUID
        var text: String
        var date: Date

        init(id: UUID = UUID(), text: String, date: Date) {
            self.id = id
            self.text = text
            self.date = date
        }
    }

    private struct ContentView: View {
        private func playHaptic(_ pattern: Int = 0) {
            SwiftCode.triggerHapticFeedback(pattern)
        }
        var body: some View {
            VStack(spacing: 16) {
                Text("Todo List")
                Button(action: {
                    playHaptic(0)
                }) {
                    Text("Play Haptic 0")
                }
                Button(action: {
                    playHaptic(1)
                }) {
                    Text("Play Haptic 1")
                }
                Button(action: {
                    playHaptic(2)
                }) {
                    Text("Play Haptic 2")
                }
            }
        }
    }
}