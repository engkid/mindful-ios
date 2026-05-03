import CoreStorage
import Foundation
import SwiftData

@MainActor
public protocol ReflectionRemoteDataSource {
    func generateReflection(locale: String, tone: String) async throws -> GeneratedReflection
}

@MainActor
public protocol ReflectionCacheDataSource {
    func save(_ reflection: Reflection) throws
    func fetchSaved() throws -> [Reflection]
    func delete(id: UUID) throws
}

@MainActor
public struct UnconfiguredReflectionRemoteDataSource: ReflectionRemoteDataSource {
    public init() {}

    public func generateReflection(locale: String, tone: String) async throws -> GeneratedReflection {
        throw ReflectionError.serviceNotConfigured
    }
}

@MainActor
public final class SwiftDataReflectionCacheDataSource: ReflectionCacheDataSource {
    private let modelContainer: ModelContainer

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    public func save(_ reflection: Reflection) throws {
        let context = ModelContext(modelContainer)
        let cachedItem = CachedReflectionItem(
            id: reflection.id,
            text: reflection.text,
            createdAt: reflection.createdAt,
            model: reflection.model
        )
        context.insert(cachedItem)
        try context.save()
    }

    public func fetchSaved() throws -> [Reflection] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedReflectionItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return try context.fetch(descriptor).map {
            Reflection(
                id: $0.id,
                text: $0.text,
                createdAt: $0.createdAt,
                model: $0.model
            )
        }
    }

    public func delete(id: UUID) throws {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<CachedReflectionItem>(
            predicate: #Predicate { item in
                item.id == id
            }
        )

        let items = try context.fetch(descriptor)
        for item in items {
            context.delete(item)
        }

        try context.save()
    }
}
