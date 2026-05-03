import Foundation
import ReflectionFeature
import Testing

@Suite
@MainActor
struct ReflectionUseCaseTests {
    @Test
    func executeReturnsGeneratedReflectionFromRepository() async throws {
        let expectedReflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
            text: "Pause and notice one steady breath.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            model: "gemini-2.5-flash"
        )
        let repository = MockReflectionRepository(
            generateResult: .success(expectedReflection)
        )
        let useCase = DefaultGenerateReflectionUseCase(repository: repository)

        let reflection = try await useCase.execute(locale: "en", tone: "calm")

        #expect(reflection == expectedReflection)
    }

    @Test
    func executePropagatesRepositoryError() async {
        let repository = MockReflectionRepository(
            generateResult: .failure(MockReflectionError.generationFailed)
        )
        let useCase = DefaultGenerateReflectionUseCase(repository: repository)

        do {
            _ = try await useCase.execute(locale: "en", tone: "calm")
            Issue.record("Expected execute() to throw.")
        } catch let error as MockReflectionError {
            #expect(error == .generationFailed)
        } catch {
            Issue.record("Expected MockReflectionError, got \(error).")
        }
    }

    @Test
    func deleteSavedReflectionDeletesRepositoryReflection() throws {
        let repository = RecordingReflectionRepository(
            generateResult: .failure(MockReflectionError.generationFailed)
        )
        let useCase = DefaultDeleteSavedReflectionUseCase(repository: repository)
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000011") ?? UUID()

        try useCase.execute(id: id)

        #expect(repository.deletedIDs == [id])
    }
}

private struct MockReflectionRepository: ReflectionRepository {
    let generateResult: Result<Reflection, Error>

    func generateReflection(locale: String, tone: String) async throws -> Reflection {
        try generateResult.get()
    }

    func saveReflection(_ reflection: Reflection) throws {}

    func loadSavedReflections() throws -> [Reflection] {
        []
    }

    func deleteReflection(id: UUID) throws {}
}

@MainActor
private final class RecordingReflectionRepository: ReflectionRepository {
    private let generateResult: Result<Reflection, Error>
    private(set) var deletedIDs: [UUID] = []

    init(generateResult: Result<Reflection, Error>) {
        self.generateResult = generateResult
    }

    func generateReflection(locale: String, tone: String) async throws -> Reflection {
        try generateResult.get()
    }

    func saveReflection(_ reflection: Reflection) throws {}

    func loadSavedReflections() throws -> [Reflection] {
        []
    }

    func deleteReflection(id: UUID) throws {
        deletedIDs.append(id)
    }
}

private enum MockReflectionError: Error, Equatable {
    case generationFailed
}
