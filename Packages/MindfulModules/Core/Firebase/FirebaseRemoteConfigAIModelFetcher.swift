import FirebaseRemoteConfig
import Foundation

@MainActor
public protocol AIModelCatalogFetching {
    func fetchModels() async -> [String]
}

@MainActor
public final class FirebaseRemoteConfigAIModelFetcher: AIModelCatalogFetching {
    public static let shared = FirebaseRemoteConfigAIModelFetcher()
    public static let modelsKey = "reflection_ai_models"
    public static let defaultModels = [
        "gemini-2.5-flash-lite",
        "gemini-2.5-flash",
        "gemini-2.0-flash-lite"
    ]

    private let remoteConfig: RemoteConfig?
    private let modelsKey: String
    private let defaultModels: [String]

    public convenience init(
        modelsKey: String = FirebaseRemoteConfigAIModelFetcher.modelsKey,
        defaultModels: [String] = FirebaseRemoteConfigAIModelFetcher.defaultModels,
        minimumFetchInterval: TimeInterval = 43_200,
        fetchTimeout: TimeInterval = 10
    ) {
        let remoteConfig = FirebaseBootstrap.isConfigured ? RemoteConfig.remoteConfig() : nil
        self.init(
            remoteConfig: remoteConfig,
            modelsKey: modelsKey,
            defaultModels: defaultModels,
            minimumFetchInterval: minimumFetchInterval,
            fetchTimeout: fetchTimeout
        )
    }

    internal init(
        remoteConfig: RemoteConfig?,
        modelsKey: String = FirebaseRemoteConfigAIModelFetcher.modelsKey,
        defaultModels: [String] = FirebaseRemoteConfigAIModelFetcher.defaultModels,
        minimumFetchInterval: TimeInterval = 43_200,
        fetchTimeout: TimeInterval = 10
    ) {
        self.remoteConfig = remoteConfig
        self.modelsKey = modelsKey
        self.defaultModels = Self.normalizedModels(defaultModels)

        guard let remoteConfig else {
            return
        }

        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = minimumFetchInterval
        settings.fetchTimeout = fetchTimeout
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            modelsKey: Self.encodedModels(self.defaultModels) as NSString
        ])
    }

    public func fetchModels() async -> [String] {
        guard let remoteConfig else {
            return defaultModels
        }

        do {
            try await remoteConfig.ensureInitialized()
            _ = try await remoteConfig.fetchAndActivate()
        } catch {
            return activeModels(from: remoteConfig)
        }

        return activeModels(from: remoteConfig)
    }

    public static func decodedModels(from value: String, fallback: [String]) -> [String] {
        guard let data = value.data(using: .utf8) else {
            return normalizedModels(fallback)
        }

        do {
            let decodedModels = try JSONDecoder().decode([String].self, from: data)
            let models = normalizedModels(decodedModels)
            return models.isEmpty ? normalizedModels(fallback) : models
        } catch {
            return normalizedModels(fallback)
        }
    }

    private func activeModels(from remoteConfig: RemoteConfig) -> [String] {
        let value = remoteConfig[modelsKey].stringValue
        return Self.decodedModels(from: value, fallback: defaultModels)
    }

    private static func encodedModels(_ models: [String]) -> String {
        guard
            let data = try? JSONEncoder().encode(normalizedModels(models)),
            let value = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }

        return value
    }

    private static func normalizedModels(_ models: [String]) -> [String] {
        var seenModels = Set<String>()

        return models.compactMap { model in
            let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedModel.isEmpty, seenModels.insert(trimmedModel).inserted else {
                return nil
            }
            return trimmedModel
        }
    }
}
