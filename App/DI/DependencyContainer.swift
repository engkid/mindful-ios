import CoreLogger
import CoreNetworking
import CoreStorage
import Foundation
import SampleFeature
import SwiftData

@MainActor
internal struct DependencyContainer {
    internal let apiClient: any APIClient
    internal let logger: any Logger
    internal let sessionStore: SessionStore
    internal let modelContainer: ModelContainer

    internal init(
        apiClient: any APIClient,
        logger: any Logger,
        sessionStore: SessionStore,
        modelContainer: ModelContainer
    ) {
        self.apiClient = apiClient
        self.logger = logger
        self.sessionStore = sessionStore
        self.modelContainer = modelContainer
    }

    internal static func live() -> DependencyContainer {
        let baseURL = URL(string: "https://jsonplaceholder.typicode.com") ?? URL(fileURLWithPath: "/")
        let modelContainer = (try? SwiftDataStack.makeModelContainer()) ?? fallbackModelContainer()

        return DependencyContainer(
            apiClient: URLSessionAPIClient(baseURL: baseURL),
            logger: ConsoleLogger(),
            sessionStore: SessionStore(),
            modelContainer: modelContainer
        )
    }

    internal func makeSampleViewModel() -> SampleViewModel {
        let remoteDataSource = URLSessionSampleRemoteDataSource(apiClient: apiClient)
        let repository = DefaultSampleRepository(
            remoteDataSource: remoteDataSource,
            logger: logger
        )
        let useCase = DefaultFetchSampleItemsUseCase(repository: repository)
        return SampleViewModel(fetchItemsUseCase: useCase)
    }

    private static func fallbackModelContainer() -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(
                for: CachedSampleItem.self,
                configurations: configuration
            )
        } catch {
            fatalError("Unable to create SwiftData model container: \(error)")
        }
    }
}
