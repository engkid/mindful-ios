import CoreNetworking

public protocol SampleRemoteDataSource: Sendable {
    func fetchItems() async throws -> [SampleItemDTO]
}

public struct URLSessionSampleRemoteDataSource: SampleRemoteDataSource {
    private let apiClient: any APIClient

    public init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    public func fetchItems() async throws -> [SampleItemDTO] {
        try await apiClient.send(SampleEndpoint())
    }
}
