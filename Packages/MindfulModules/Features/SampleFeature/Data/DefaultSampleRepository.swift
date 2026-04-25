import CoreLogger

public struct DefaultSampleRepository: SampleRepository {
    private let remoteDataSource: any SampleRemoteDataSource
    private let logger: any Logger

    public init(
        remoteDataSource: any SampleRemoteDataSource,
        logger: any Logger
    ) {
        self.remoteDataSource = remoteDataSource
        self.logger = logger
    }

    public func fetchItems() async throws -> [SampleItem] {
        do {
            let items = try await remoteDataSource.fetchItems()
            logger.log("Fetched \(items.count) sample items.", level: .debug)
            return items.map { $0.toDomain() }
        } catch {
            logger.log("Failed to fetch sample items: \(error)", level: .error)
            throw error
        }
    }
}
