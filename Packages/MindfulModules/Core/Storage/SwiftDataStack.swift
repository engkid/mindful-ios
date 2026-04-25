import SwiftData

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

public enum SwiftDataStack {
    @MainActor
    public static func makeModelContainer() throws -> ModelContainer {
        try ModelContainer(for: CachedSampleItem.self)
    }
}
