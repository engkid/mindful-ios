import Foundation

@MainActor
public protocol ReflectionRepository {
    func generateReflection(locale: String, tone: String) async throws -> Reflection

    func saveReflection(_ reflection: Reflection) throws

    func loadSavedReflections() throws -> [Reflection]

    func deleteReflection(id: UUID) throws
}
