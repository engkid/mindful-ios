import Foundation

public struct Reflection: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let text: String
    public let createdAt: Date
    public let model: String

    public init(
        id: UUID = UUID(),
        text: String,
        createdAt: Date = Date(),
        model: String
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.model = model
    }
}

public struct GeneratedReflection: Equatable, Sendable {
    public let text: String
    public let model: String

    public init(text: String, model: String) {
        self.text = text
        self.model = model
    }
}

public enum ReflectionError: Error, Equatable, Sendable {
    case serviceNotConfigured
    case emptyResponse
    case generationFailed
}
