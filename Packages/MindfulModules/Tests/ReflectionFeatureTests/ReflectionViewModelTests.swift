import Foundation
import ReflectionFeature
import Testing

@Suite
@MainActor
struct ReflectionViewModelTests {
    @Test
    func generateSuccessSetsGeneratedReflection() async {
        let expectedReflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
            text: "Let this breath be enough.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_100),
            model: "gemini-2.5-flash"
        )
        let viewModel = ReflectionViewModel(
            generateReflectionUseCase: MockGenerateReflectionUseCase(
                result: .success(expectedReflection)
            ),
            saveReflectionUseCase: MockSaveReflectionUseCase(),
            fetchSavedReflectionsUseCase: MockFetchSavedReflectionsUseCase(),
            deleteSavedReflectionUseCase: MockDeleteSavedReflectionUseCase()
        )

        await viewModel.generateReflection()

        #expect(viewModel.generatedReflection == expectedReflection)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func generateFailureSetsErrorMessage() async {
        let viewModel = ReflectionViewModel(
            generateReflectionUseCase: MockGenerateReflectionUseCase(
                result: .failure(MockReflectionError.generationFailed)
            ),
            saveReflectionUseCase: MockSaveReflectionUseCase(),
            fetchSavedReflectionsUseCase: MockFetchSavedReflectionsUseCase(),
            deleteSavedReflectionUseCase: MockDeleteSavedReflectionUseCase()
        )

        await viewModel.generateReflection()

        #expect(viewModel.generatedReflection == nil)
        #expect(viewModel.errorMessage == "Unable to generate reflection.")
    }

    @Test
    func missingServiceConfigurationSetsConfigurationError() async {
        let viewModel = ReflectionViewModel(
            generateReflectionUseCase: MockGenerateReflectionUseCase(
                result: .failure(ReflectionError.serviceNotConfigured)
            ),
            saveReflectionUseCase: MockSaveReflectionUseCase(),
            fetchSavedReflectionsUseCase: MockFetchSavedReflectionsUseCase(),
            deleteSavedReflectionUseCase: MockDeleteSavedReflectionUseCase()
        )

        await viewModel.generateReflection()

        #expect(viewModel.errorMessage == "Reflection service is not configured.")
    }

    @Test
    func saveStoresCurrentReflection() async {
        let reflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID(),
            text: "Choose one kind next step.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_200),
            model: "gemini-2.5-flash"
        )
        let saveUseCase = MockSaveReflectionUseCase()
        let fetchUseCase = MockFetchSavedReflectionsUseCase(savedReflections: [reflection])
        let viewModel = ReflectionViewModel(
            generateReflectionUseCase: MockGenerateReflectionUseCase(result: .success(reflection)),
            saveReflectionUseCase: saveUseCase,
            fetchSavedReflectionsUseCase: fetchUseCase,
            deleteSavedReflectionUseCase: MockDeleteSavedReflectionUseCase()
        )

        await viewModel.generateReflection()
        viewModel.saveCurrentReflection()

        #expect(saveUseCase.savedReflections == [reflection])
        #expect(viewModel.savedReflections == [reflection])
    }

    @Test
    func deleteSavedReflectionRemovesReflectionAndReloadsSavedList() {
        let deletedReflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000007") ?? UUID(),
            text: "Delete this reflection.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_300),
            model: "gemini-2.5-flash"
        )
        let remainingReflection = Reflection(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000008") ?? UUID(),
            text: "Keep this reflection.",
            createdAt: Date(timeIntervalSince1970: 1_700_000_400),
            model: "gemini-2.5-flash"
        )
        let fetchUseCase = MockFetchSavedReflectionsUseCase(
            savedReflections: [deletedReflection, remainingReflection]
        )
        let deleteUseCase = MockDeleteSavedReflectionUseCase()
        let viewModel = ReflectionViewModel(
            generateReflectionUseCase: MockGenerateReflectionUseCase(
                result: .failure(MockReflectionError.generationFailed)
            ),
            saveReflectionUseCase: MockSaveReflectionUseCase(),
            fetchSavedReflectionsUseCase: fetchUseCase,
            deleteSavedReflectionUseCase: deleteUseCase
        )

        viewModel.loadSavedReflections()
        fetchUseCase.savedReflections = [remainingReflection]
        viewModel.deleteSavedReflection(deletedReflection)

        #expect(deleteUseCase.deletedIDs == [deletedReflection.id])
        #expect(viewModel.savedReflections == [remainingReflection])
        #expect(viewModel.errorMessage == nil)
    }
}

private final class MockGenerateReflectionUseCase: GenerateReflectionUseCase {
    private let result: Result<Reflection, Error>

    init(result: Result<Reflection, Error>) {
        self.result = result
    }

    func execute(locale: String, tone: String) async throws -> Reflection {
        try result.get()
    }
}

@MainActor
private final class MockSaveReflectionUseCase: SaveReflectionUseCase {
    private(set) var savedReflections: [Reflection] = []

    func execute(_ reflection: Reflection) throws {
        savedReflections.append(reflection)
    }
}

@MainActor
private final class MockFetchSavedReflectionsUseCase: FetchSavedReflectionsUseCase {
    var savedReflections: [Reflection]

    init(savedReflections: [Reflection] = []) {
        self.savedReflections = savedReflections
    }

    func execute() throws -> [Reflection] {
        savedReflections
    }
}

@MainActor
private final class MockDeleteSavedReflectionUseCase: DeleteSavedReflectionUseCase {
    private(set) var deletedIDs: [UUID] = []

    func execute(id: UUID) throws {
        deletedIDs.append(id)
    }
}

private enum MockReflectionError: Error {
    case generationFailed
}
