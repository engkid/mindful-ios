public protocol SampleRepository: Sendable {
    func fetchItems() async throws -> [SampleItem]
}
