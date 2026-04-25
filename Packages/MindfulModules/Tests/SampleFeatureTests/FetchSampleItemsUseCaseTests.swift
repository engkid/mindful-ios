import SampleFeature
import Testing

@Suite
struct FetchSampleItemsUseCaseTests {
    @Test
    func executeReturnsItemsFromRepository() async throws {
        let expectedItems = [
            SampleItem(id: 1, title: "Title", detail: "Detail")
        ]
        let repository = MockSampleRepository(result: .success(expectedItems))
        let useCase = DefaultFetchSampleItemsUseCase(repository: repository)

        let items = try await useCase.execute()

        #expect(items == expectedItems)
    }

    @Test
    func executeThrowsRepositoryError() async {
        let repository = MockSampleRepository(result: .failure(MockSampleError.networkUnavailable))
        let useCase = DefaultFetchSampleItemsUseCase(repository: repository)

        do {
            _ = try await useCase.execute()
            Issue.record("Expected execute() to throw.")
        } catch let error as MockSampleError {
            #expect(error == .networkUnavailable)
        } catch {
            Issue.record("Expected MockSampleError, got \(error).")
        }
    }
}

private struct MockSampleRepository: SampleRepository {
    let result: Result<[SampleItem], Error>

    func fetchItems() async throws -> [SampleItem] {
        try result.get()
    }
}

private enum MockSampleError: Error, Equatable {
    case networkUnavailable
}
