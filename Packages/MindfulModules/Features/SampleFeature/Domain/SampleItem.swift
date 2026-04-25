import Foundation

public struct SampleItem: Identifiable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let detail: String

    public init(id: Int, title: String, detail: String) {
        self.id = id
        self.title = title
        self.detail = detail
    }
}
