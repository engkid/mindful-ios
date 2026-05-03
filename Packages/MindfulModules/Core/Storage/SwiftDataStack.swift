import SwiftData
import Foundation

@Model
public final class CachedSampleItem {
    public var id: Int
    public var title: String
    public var detail: String

    public init(id: Int, title: String, detail: String) {
        self.id = id
        self.title = title
        self.detail = detail
    }
}

@Model
public final class CachedReflectionItem {
    public var id: UUID
    public var text: String
    public var createdAt: Date
    public var model: String

    public init(
        id: UUID,
        text: String,
        createdAt: Date,
        model: String
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.model = model
    }
}

public enum SwiftDataStack {
    @MainActor
    public static func makeModelContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CachedSampleItem.self,
            CachedReflectionItem.self
        )
    }
}
