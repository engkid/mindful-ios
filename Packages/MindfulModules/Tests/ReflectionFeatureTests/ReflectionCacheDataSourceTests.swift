import CoreStorage
import Foundation
import ReflectionFeature
import SwiftData
import Testing

@Suite
@MainActor
struct ReflectionCacheDataSourceTests {
    @Test
    func saveReflectionPersistsInSwiftData() throws {
        let dataSource = try makeDataSource()
        let reflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004") ?? UUID(),
            text: "Rest your attention on the next breath.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_300),
            model: "gemini-2.5-flash"
        )

        try dataSource.save(reflection)

        #expect(try dataSource.fetchSaved() == [reflection])
    }

    @Test
    func savedReflectionsLoadNewestFirst() throws {
        let dataSource = try makeDataSource()
        let olderReflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005") ?? UUID(),
            text: "Older reflection.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_300),
            model: "gemini-2.5-flash"
        )
        let newerReflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000006") ?? UUID(),
            text: "Newer reflection.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_400),
            model: "gemini-2.5-flash"
        )

        try dataSource.save(olderReflection)
        try dataSource.save(newerReflection)

        #expect(try dataSource.fetchSaved() == [newerReflection, olderReflection])
    }

    @Test
    func deleteReflectionRemovesPersistedReflection() throws {
        let dataSource = try makeDataSource()
        let deletedReflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000009") ?? UUID(),
            text: "Deleted reflection.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_500),
            model: "gemini-2.5-flash"
        )
        let remainingReflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010") ?? UUID(),
            text: "Remaining reflection.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_600),
            model: "gemini-2.5-flash"
        )

        try dataSource.save(deletedReflection)
        try dataSource.save(remainingReflection)
        try dataSource.delete(id: deletedReflection.id)

        #expect(try dataSource.fetchSaved() == [remainingReflection])
    }

    private func makeDataSource() throws -> SwiftDataReflectionCacheDataSource {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(
            for: CachedReflectionItem.self,
            configurations: configuration
        )
        return SwiftDataReflectionCacheDataSource(modelContainer: modelContainer)
    }
}
