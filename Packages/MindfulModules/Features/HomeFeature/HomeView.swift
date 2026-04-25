import SharedDesignSystem
import SharedUIComponents
import SwiftUI

public struct HomeView: View {
    private let onShowSample: () -> Void

    public init(onShowSample: @escaping () -> Void) {
        self.onShowSample = onShowSample
    }

    public var body: some View {
        List {
            Section {
                Button(action: onShowSample) {
                    Label("Open Sample Feature", systemImage: "rectangle.stack")
                }
            }
        }
        .navigationTitle("Mindful")
        .scrollContentBackground(.hidden)
        .background(AppColor.background)
    }
}

#Preview {
    NavigationStack {
        HomeView {}
    }
}
