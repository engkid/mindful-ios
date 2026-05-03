import CoreFirebase
import FirebaseAILogic
import Foundation

@MainActor
public final class FirebaseAIReflectionRemoteDataSource: ReflectionRemoteDataSource, @unchecked Sendable {
    private let modelCatalogFetcher: any AIModelCatalogFetching
    private let rotationStore: AIModelRotationStore
    private let textGenerator: any ReflectionTextGenerating
    private let requiresFirebaseConfiguration: Bool
    private let tonePromptPrefix: String

    public init(
        modelCatalogFetcher: any AIModelCatalogFetching = FirebaseRemoteConfigAIModelFetcher.shared,
        rotationStore: AIModelRotationStore = .shared,
        textGenerator: any ReflectionTextGenerating = FirebaseAIReflectionTextGenerator(),
        requiresFirebaseConfiguration: Bool = true,
        tonePromptPrefix: String = "Create one short, engaging mindful reflection for a mobile app user."
    ) {
        self.modelCatalogFetcher = modelCatalogFetcher
        self.rotationStore = rotationStore
        self.textGenerator = textGenerator
        self.requiresFirebaseConfiguration = requiresFirebaseConfiguration
        self.tonePromptPrefix = tonePromptPrefix
    }

    public func generateReflection(locale: String, tone: String) async throws -> GeneratedReflection {
        guard !requiresFirebaseConfiguration || FirebaseBootstrap.isConfigured else {
            throw ReflectionError.serviceNotConfigured
        }

        let fetchedModels = await modelCatalogFetcher.fetchModels()
        let models = await rotationStore.orderedModels(from: fetchedModels)

        guard !models.isEmpty else {
            throw ReflectionError.generationFailed
        }

        var latestError: Error?

        for modelName in models {
            do {
                let text = try await generateText(
                    modelName: modelName,
                    locale: locale,
                    tone: tone
                )
                await rotationStore.markModelSuccessful(modelName)
                return GeneratedReflection(text: text, model: modelName)
            } catch let error as ReflectionError {
                throw error
            } catch {
                latestError = error

                guard isRateLimitError(error) else {
                    throw ReflectionError.generationFailed
                }

                await rotationStore.markModelRateLimited(modelName, in: models)
            }
        }

        if let latestError, !isRateLimitError(latestError) {
            throw ReflectionError.generationFailed
        }

        throw ReflectionError.generationFailed
    }

    private func generateText(
        modelName: String,
        locale: String,
        tone: String
    ) async throws -> String {
        let text = try await textGenerator.generateText(
            modelName: modelName,
            prompt: prompt(locale: locale, tone: tone)
        )
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            throw ReflectionError.emptyResponse
        }

        return trimmedText
    }

    private func isRateLimitError(_ error: Error) -> Bool {
        if case GenerateContentError.internalError(let underlyingError) = error {
            return isRateLimitNSError(underlyingError as NSError)
        }

        return isRateLimitNSError(error as NSError)
    }

    private func isRateLimitNSError(_ error: NSError) -> Bool {
        let description = error.localizedDescription.lowercased()
        return error.code == 429
            || description.contains("resource_exhausted")
            || description.contains("rate limit")
            || description.contains("quota")
    }

    private func prompt(locale: String, tone: String) -> String {
        [
            tonePromptPrefix,
            "Tone: \(tone).",
            "Locale: \(locale).",
            "Choose one varied theme from mindful breathing, everyday life lessons, practical wisdom, gentle motivation, personal growth, or knowledge-sharing inspired by a surprising but broadly verifiable fact.",
            "Make it feel fresh and useful, not limited to breathing techniques.",
            "Keep it calm, practical, non-religious, and under 45 words.",
            "Do not include statistics, citations, labels, or medical or financial advice.",
            "Return only the reflection text."
        ].joined(separator: " ")
    }
}

@MainActor
public protocol ReflectionTextGenerating {
    func generateText(modelName: String, prompt: String) async throws -> String
}

@MainActor
public struct FirebaseAIReflectionTextGenerator: ReflectionTextGenerating {
    public init() {}

    public func generateText(modelName: String, prompt: String) async throws -> String {
        let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
            modelName: modelName,
            generationConfig: GenerationConfig(
                temperature: 0.8,
                candidateCount: 1,
                maxOutputTokens: 80
            )
        )

        let response = try await model.generateContent(prompt)
        return response.text ?? ""
    }
}
