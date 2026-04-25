import Foundation

public struct SampleItemDTO: Decodable, Sendable {
    public let id: Int
    public let title: String
    public let body: String

    public init(id: Int, title: String, body: String) {
        self.id = id
        self.title = title
        self.body = body
    }

    public func toDomain() -> SampleItem {
        SampleItem(id: id, title: title, detail: body)
    }
}
