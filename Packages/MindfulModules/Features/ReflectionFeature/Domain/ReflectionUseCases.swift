import Foundation

@MainActor
public protocol GenerateReflectionUseCase {
    func execute(locale: String, tone: String) async throws -> Reflection
}

@MainActor
public protocol SaveReflectionUseCase {
    func execute(_ reflection: Reflection) throws
}

@MainActor
public protocol FetchSavedReflectionsUseCase {
    func execute() throws -> [Reflection]
}

@MainActor
public protocol DeleteSavedReflectionUseCase {
    func execute(id: UUID) throws
}

@MainActor
public struct DefaultGenerateReflectionUseCase: GenerateReflectionUseCase {
    private let repository: any ReflectionRepository

    public init(repository: any ReflectionRepository) {
        self.repository = repository
    }

    public func execute(locale: String, tone: String) async throws -> Reflection {
        try await repository.generateReflection(locale: locale, tone: tone)
    }
}

@MainActor
public struct DefaultSaveReflectionUseCase: SaveReflectionUseCase {
    private let repository: any ReflectionRepository

    public init(repository: any ReflectionRepository) {
        self.repository = repository
    }

    public func execute(_ reflection: Reflection) throws {
        try repository.saveReflection(reflection)
    }
}

@MainActor
public struct DefaultFetchSavedReflectionsUseCase: FetchSavedReflectionsUseCase {
    private let repository: any ReflectionRepository

    public init(repository: any ReflectionRepository) {
        self.repository = repository
    }

    public func execute() throws -> [Reflection] {
        try repository.loadSavedReflections()
    }
}

@MainActor
public struct DefaultDeleteSavedReflectionUseCase: DeleteSavedReflectionUseCase {
    private let repository: any ReflectionRepository

    public init(repository: any ReflectionRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) throws {
        try repository.deleteReflection(id: id)
    }
}
