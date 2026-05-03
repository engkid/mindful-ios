import Foundation
import Observation

@MainActor
@Observable
public final class ReflectionViewModel {
    public private(set) var generatedReflection: Reflection?
    public private(set) var savedReflections: [Reflection] = []
    public private(set) var isGenerating = false
    public private(set) var isSaving = false
    public var errorMessage: String?

    private let generateReflectionUseCase: any GenerateReflectionUseCase
    private let saveReflectionUseCase: any SaveReflectionUseCase
    private let fetchSavedReflectionsUseCase: any FetchSavedReflectionsUseCase
    private let deleteSavedReflectionUseCase: any DeleteSavedReflectionUseCase

    public init(
        generateReflectionUseCase: any GenerateReflectionUseCase,
        saveReflectionUseCase: any SaveReflectionUseCase,
        fetchSavedReflectionsUseCase: any FetchSavedReflectionsUseCase,
        deleteSavedReflectionUseCase: any DeleteSavedReflectionUseCase
    ) {
        self.generateReflectionUseCase = generateReflectionUseCase
        self.saveReflectionUseCase = saveReflectionUseCase
        self.fetchSavedReflectionsUseCase = fetchSavedReflectionsUseCase
        self.deleteSavedReflectionUseCase = deleteSavedReflectionUseCase
    }

    public func loadSavedReflections() {
        do {
            savedReflections = try fetchSavedReflectionsUseCase.execute()
        } catch {
            errorMessage = "Unable to load saved reflections."
        }
    }

    public func generateReflection() async {
        guard !isGenerating else {
            return
        }

        isGenerating = true
        errorMessage = nil

        do {
            generatedReflection = try await generateReflectionUseCase.execute(
                locale: "en",
                tone: "calm"
            )
        } catch ReflectionError.serviceNotConfigured {
            errorMessage = "Reflection service is not configured."
        } catch {
            errorMessage = "Unable to generate reflection."
        }

        isGenerating = false
    }

    public func saveCurrentReflection() {
        guard let generatedReflection, !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            try saveReflectionUseCase.execute(generatedReflection)
            savedReflections = try fetchSavedReflectionsUseCase.execute()
        } catch {
            errorMessage = "Unable to save reflection."
        }

        isSaving = false
    }

    public func deleteSavedReflection(_ reflection: Reflection) {
        errorMessage = nil

        do {
            try deleteSavedReflectionUseCase.execute(id: reflection.id)
            savedReflections = try fetchSavedReflectionsUseCase.execute()
        } catch {
            errorMessage = "Unable to delete reflection."
        }
    }
}
