import CoreFirebase
import UIKit

@MainActor
internal final class AppDelegate: NSObject, UIApplicationDelegate {
    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseBootstrap.configureIfPossible()
        fetchRemoteConfig()
        return true
    }

    internal func fetchRemoteConfig() {
        guard FirebaseBootstrap.isConfigured else {
            return
        }

        Task { @MainActor in
            _ = await FirebaseRemoteConfigAIModelFetcher.shared.fetchModels()
        }
    }
}
