import SharedDesignSystem
import SwiftUI

public struct LoadingView: View {
    private let title: String

    public init(_ title: String = "Loading") {
        self.title = title
    }

    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
