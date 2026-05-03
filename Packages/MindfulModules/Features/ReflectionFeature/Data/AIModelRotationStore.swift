public actor AIModelRotationStore {
    public static let shared = AIModelRotationStore()

    private var preferredModelName: String?

    public init() {}

    public func orderedModels(from models: [String]) -> [String] {
        guard
            let preferredModelName,
            let preferredIndex = models.firstIndex(of: preferredModelName)
        else {
            return models
        }

        return Array(models[preferredIndex...]) + Array(models[..<preferredIndex])
    }

    public func markModelRateLimited(_ modelName: String, in models: [String]) {
        guard
            let limitedModelIndex = models.firstIndex(of: modelName),
            !models.isEmpty
        else {
            preferredModelName = models.first
            return
        }

        let nextModelIndex = models.index(after: limitedModelIndex) == models.endIndex
            ? models.startIndex
            : models.index(after: limitedModelIndex)
        preferredModelName = models[nextModelIndex]
    }

    public func markModelSuccessful(_ modelName: String) {
        preferredModelName = modelName
    }
}
