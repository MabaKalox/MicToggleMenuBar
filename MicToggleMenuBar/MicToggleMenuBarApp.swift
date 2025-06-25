import AudioToolbox
import OSLog
import SwiftUI

@main
struct MicToggleMenuBar: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No windows needed
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var isMuted: Bool = false
    var updateTimer: Timer?

    var soundMicOnID: SystemSoundID = 0
    var soundMicOffID: SystemSoundID = 0

    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "microphoneToggleMute"
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        statusItem.button?.action = #selector(toggleMic)
        statusItem.button?.target = self

        DistributedNotificationCenter.default()
            .addObserver(
                self,
                selector: #selector(toggleMicPlaySound),
                name: .toggleMicMuteRequest,
                object: nil
            )

        queryAndUpdateIcon()

        // Update mute status every 60 seconds, in case it was modified externaly
        updateTimer = Timer.scheduledTimer(
            timeInterval: 60.0,
            target: self,
            selector: #selector(queryAndUpdateIcon),
            userInfo: nil,
            repeats: true
        )
        updateTimer?.tolerance = 5.0

        if let onURL = Bundle.main.url(
            forResource: "mic_on",
            withExtension: "wav"
        ) {
            AudioServicesCreateSystemSoundID(onURL as CFURL, &soundMicOnID)
        }
        if let offURL = Bundle.main.url(
            forResource: "mic_off",
            withExtension: "wav"
        ) {
            AudioServicesCreateSystemSoundID(offURL as CFURL, &soundMicOffID)
        }
    }

    @objc private func queryAndUpdateIcon() {
        let ret = get_mic_mute(&isMuted)
        if ret != 0 {
            logger.error("Failed to check default mic mute status: \(ret)")
            exit(ret)
        }
        updateIcon()
    }
    
    @objc private func toggleMic() {
        let ret = toggle_mic_mute(&self.isMuted)
        if ret != 0 {
            self.logger.error(
                "Failed to check default mic mute status: \(ret)"
            )
            exit(ret)
        }

        self.updateIcon()
    }

    @objc private func toggleMicPlaySound() {
        self.toggleMic()
        if self.isMuted {
            AudioServicesPlaySystemSound(soundMicOffID)
        } else {
            AudioServicesPlaySystemSound(soundMicOnID)
        }
    }

    func updateIcon() {
        let iconName = isMuted ? "mic.slash" : "mic"
        statusItem.button?.image = NSImage(
            systemSymbolName: iconName,
            accessibilityDescription: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        AudioServicesDisposeSystemSoundID(soundMicOnID)
        AudioServicesDisposeSystemSoundID(soundMicOffID)
    }
}
