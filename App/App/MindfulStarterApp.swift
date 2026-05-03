import CoreStorage
import SwiftData
import SwiftUI

@main
internal struct MindfulStarterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var coordinator: AppCoordinator
    private let container: DependencyContainer
    private let modelContainer: ModelContainer

    internal init() {
        let container = DependencyContainer.live()
        self.container = container
        self.modelContainer = container.modelContainer
        _coordinator = State(initialValue: AppCoordinator(container: container))
    }

    internal var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator)
                .modelContainer(modelContainer)
        }
    }
}
