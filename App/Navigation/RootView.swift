import HomeFeature
import SwiftUI

internal struct RootView: View {
    @Bindable private var coordinator: AppCoordinator

    internal init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    internal var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView(
                onShowSample: {
                    coordinator.showSample()
                },
                onShowBreathingTutorial: {
                    coordinator.showBreathingTutorial()
                },
                onShowReflection: {
                    coordinator.showReflection()
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                coordinator.view(for: route)
            }
        }
    }
}
