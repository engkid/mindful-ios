import FirebaseCore
import Foundation

@MainActor
public enum FirebaseBootstrap {
    public static var isConfigured: Bool {
        FirebaseApp.app() != nil
    }

    public static func configureIfPossible(bundle: Bundle = .main) {
        guard !isConfigured else {
            return
        }

        guard bundle.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return
        }

        FirebaseApp.configure()
    }
}
