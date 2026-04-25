import SampleFeature
import Testing

@Suite
@MainActor
struct SampleViewModelTests {
    @Test
    func loadSetsLoadedState() async {
        let expectedItems = [
            SampleItem(id: 1, title: "Title", detail: "Detail")
        ]
        let viewModel = SampleViewModel(
            fetchItemsUseCase: MockFetchSampleItemsUseCase(result: .success(expectedItems))
        )

        await viewModel.load()

        #expect(viewModel.state == .loaded(expectedItems))
    }
}

private struct MockFetchSampleItemsUseCase: FetchSampleItemsUseCase {
    let result: Result<[SampleItem], Error>

    func execute() async throws -> [SampleItem] {
        try result.get()
    }
}
