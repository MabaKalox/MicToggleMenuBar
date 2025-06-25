import AppIntents
import Foundation

struct ToggleMicIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Toggle Microphone"
    static var description = IntentDescription("Mutes or unmutes your microphone.")

    func perform() async throws -> some IntentResult {
        DistributedNotificationCenter.default().post(name: .toggleMicMuteRequest, object: nil)
        
        return .result()
    }
}

