public protocol FetchSampleItemsUseCase: Sendable {
    func execute() async throws -> [SampleItem]
}

public struct DefaultFetchSampleItemsUseCase: FetchSampleItemsUseCase {
    private let repository: any SampleRepository

    public init(repository: any SampleRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [SampleItem] {
        try await repository.fetchItems()
    }
}
