import Foundation
import SwiftUI

@objc
public class SwiftCode: NSObject {
    @MainActor  // Fix concurrency issue
    private static var windowController: NSWindowController?

    @MainActor
    private static let dbManager: SQLManager? = try? SQLManager()
    
    @objc
    public static func helloWorld(_ input: String) -> String {
        return "Hello from Swift! You said: \(input)"
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
    @MainActor  // Fix concurrency issue
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

    private struct ContentView: SwiftUI.View {
        private func playHaptic(_ pattern: Int = 0) {
            SwiftCode.triggerHapticFeedback(pattern)
        }
        var body: some SwiftUI.View {
            VStack(spacing: 16) {
                Text("Native GUI")
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
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
