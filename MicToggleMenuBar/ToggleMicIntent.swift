import AppIntents
import Foundation

extension Notification.Name {
    static let toggleMicIntent = Notification.Name("toggleMicIntent")
}

struct ToggleMicIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Toggle Microphone"
    static var description = IntentDescription("Mutes or unmutes your microphone.")

    func perform() async throws -> some IntentResult {
        DistributedNotificationCenter.default().post(name: .toggleMicIntent, object: nil)
        
        return .result()
    }
}

