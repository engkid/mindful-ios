import Foundation

@MainActor
public struct DefaultReflectionRepository: ReflectionRepository {
    private let remoteDataSource: any ReflectionRemoteDataSource
    private let cacheDataSource: any ReflectionCacheDataSource

    public init(
        remoteDataSource: any ReflectionRemoteDataSource,
        cacheDataSource: any ReflectionCacheDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.cacheDataSource = cacheDataSource
    }

    public func generateReflection(locale: String, tone: String) async throws -> Reflection {
        let generatedReflection = try await remoteDataSource.generateReflection(
            locale: locale,
            tone: tone
        )

        return Reflection(
            text: generatedReflection.text,
            createdAt: Date(),
            model: generatedReflection.model
        )
    }

    public func saveReflection(_ reflection: Reflection) throws {
        try cacheDataSource.save(reflection)
    }

    public func loadSavedReflections() throws -> [Reflection] {
        try cacheDataSource.fetchSaved()
    }

    public func deleteReflection(id: UUID) throws {
        try cacheDataSource.delete(id: id)
    }
}
