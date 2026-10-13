import SwiftUI
import AVKit
import WebKit

@main
struct CarVievoApp: App {
    @StateObject private var screenManager = ExternalScreenManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(screenManager)
        }
    }
}

// Araç / Harici Ekran Algılayıcı ve Yansıtıcı
class ExternalScreenManager: ObservableObject {
    var additionalWindow: UIWindow?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenDidConnect), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenDidDisconnect), name: UIScreen.didDisconnectNotification, object: nil)
        checkCurrentScreen()
    }
    
    func checkCurrentScreen() {
        if UIScreen.screens.count > 1 {
            setupExternalScreen(UIScreen.screens[1])
        }
    }
    
    @objc func screenDidConnect(notification: Notification) {
        guard let newScreen = notification.object as? UIScreen else { return }
        setupExternalScreen(newScreen)
    }
    
    @objc func screenDidDisconnect(notification: Notification) {
        additionalWindow?.isHidden = true
        additionalWindow = nil
    }
    
    func setupExternalScreen(_ screen: UIScreen) {
        let window = UIWindow(frame: screen.bounds)
        window.screen = screen
        window.rootViewController = UIHostingController(rootView: ExternalPlayerView())
        window.isHidden = false
        self.additionalWindow = window
    }
}
