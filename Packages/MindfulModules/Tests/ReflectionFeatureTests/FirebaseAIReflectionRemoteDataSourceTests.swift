import CoreFirebase
import Foundation
import ReflectionFeature
import Testing

@Suite
@MainActor
struct FirebaseAIReflectionRemoteDataSourceTests {
    @Test
    func generateFallsBackToNextModelWhenCurrentModelIsRateLimited() async throws {
        let textGenerator = MockReflectionTextGenerator(
            resultsByModel: [
                "model-a": .failure(NSError(domain: "test", code: 429)),
                "model-b": .success(" A steady breath is enough. ")
            ]
        )
        let dataSource = FirebaseAIReflectionRemoteDataSource(
            modelCatalogFetcher: MockAIModelCatalogFetcher(models: ["model-a", "model-b"]),
            rotationStore: AIModelRotationStore(),
            textGenerator: textGenerator,
            requiresFirebaseConfiguration: false
        )

        let reflection = try await dataSource.generateReflection(locale: "en", tone: "calm")

        #expect(reflection.text == "A steady breath is enough.")
        #expect(reflection.model == "model-b")
        #expect(textGenerator.requestedModels == ["model-a", "model-b"])
    }

    @Test
    func generateStopsOnNonRateLimitFailure() async throws {
        let textGenerator = MockReflectionTextGenerator(
            resultsByModel: [
                "model-a": .failure(NSError(domain: "test", code: 500)),
                "model-b": .success("This should not be used.")
            ]
        )
        let dataSource = FirebaseAIReflectionRemoteDataSource(
            modelCatalogFetcher: MockAIModelCatalogFetcher(models: ["model-a", "model-b"]),
            rotationStore: AIModelRotationStore(),
            textGenerator: textGenerator,
            requiresFirebaseConfiguration: false
        )

        do {
            _ = try await dataSource.generateReflection(locale: "en", tone: "calm")
            Issue.record("Expected generation failure.")
        } catch ReflectionError.generationFailed {
            #expect(textGenerator.requestedModels == ["model-a"])
        } catch {
            Issue.record("Expected ReflectionError.generationFailed, got \(error).")
        }
    }

    @Test
    func generateUsesEngagingReflectionPrompt() async throws {
        let textGenerator = MockReflectionTextGenerator(
            resultsByModel: [
                "model-a": .success("Let curiosity make the next moment lighter.")
            ]
        )
        let dataSource = FirebaseAIReflectionRemoteDataSource(
            modelCatalogFetcher: MockAIModelCatalogFetcher(models: ["model-a"]),
            rotationStore: AIModelRotationStore(),
            textGenerator: textGenerator,
            requiresFirebaseConfiguration: false
        )

        _ = try await dataSource.generateReflection(locale: "en", tone: "calm")

        let prompt = try #require(textGenerator.requestedPrompts.first)
        #expect(prompt.contains("everyday life lessons"))
        #expect(prompt.contains("practical wisdom"))
        #expect(prompt.contains("gentle motivation"))
        #expect(prompt.contains("surprising but broadly verifiable fact"))
        #expect(prompt.contains("not limited to breathing techniques"))
        #expect(prompt.contains("under 45 words"))
        #expect(prompt.contains("Return only the reflection text."))
    }

    @Test
    func decodedRemoteConfigModelsTrimsAndRemovesDuplicates() {
        let models = FirebaseRemoteConfigAIModelFetcher.decodedModels(
            from: "[\" model-a \",\"model-b\",\"model-a\",\"\"]",
            fallback: ["fallback-model"]
        )

        #expect(models == ["model-a", "model-b"])
    }
}

@MainActor
private struct MockAIModelCatalogFetcher: AIModelCatalogFetching {
    let models: [String]

    func fetchModels() async -> [String] {
        models
    }
}

@MainActor
private final class MockReflectionTextGenerator: ReflectionTextGenerating {
    private let resultsByModel: [String: Result<String, Error>]
    private(set) var requestedModels: [String] = []
    private(set) var requestedPrompts: [String] = []

    init(resultsByModel: [String: Result<String, Error>]) {
        self.resultsByModel = resultsByModel
    }

    func generateText(modelName: String, prompt: String) async throws -> String {
        requestedModels.append(modelName)
        requestedPrompts.append(prompt)
        return try resultsByModel[modelName, default: .failure(NSError(domain: "test", code: 404))].get()
    }
}
