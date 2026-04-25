import SharedDesignSystem
import SharedUIComponents
import SwiftUI

public struct SampleView: View {
    @State private var viewModel: SampleViewModel

    public init(viewModel: SampleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle("Sample")
            .task {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView("Loading samples")
        case .loaded(let items):
            List(items) { item in
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, AppSpacing.xs)
            }
        case .failed(let message):
            ErrorStateView(message: message) {
                Task {
                    await viewModel.load()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SampleView(
            viewModel: SampleViewModel(
                fetchItemsUseCase: PreviewFetchSampleItemsUseCase()
            )
        )
    }
}

private struct PreviewFetchSampleItemsUseCase: FetchSampleItemsUseCase {
    func execute() async throws -> [SampleItem] {
        [
            SampleItem(id: 1, title: "First Item", detail: "Preview detail"),
            SampleItem(id: 2, title: "Second Item", detail: "Another detail")
        ]
    }
}
