import HomeFeature
import Observation
import ReflectionFeature
import SampleFeature
import SwiftUI

@MainActor
@Observable
internal final class AppCoordinator {
    internal var path: [AppRoute] = []

    private let container: DependencyContainer

    internal init(container: DependencyContainer) {
        self.container = container
    }

    internal func showSample() {
        path.append(.sample)
    }

    internal func showBreathingTutorial() {
        path.append(.breathingTutorial)
    }

    internal func showReflection() {
        path.append(.reflection)
    }

    @ViewBuilder
    internal func view(for route: AppRoute) -> some View {
        switch route {
        case .sample:
            SampleView(viewModel: container.makeSampleViewModel())
        case .breathingTutorial:
            BreathingTutorialView()
        case .reflection:
            ReflectionView(viewModel: container.makeReflectionViewModel())
        }
    }
}
