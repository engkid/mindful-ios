import Foundation
import Observation

@MainActor
@Observable
public final class SampleViewModel {
    public private(set) var state: SampleViewState = .idle

    private let fetchItemsUseCase: any FetchSampleItemsUseCase

    public init(fetchItemsUseCase: any FetchSampleItemsUseCase) {
        self.fetchItemsUseCase = fetchItemsUseCase
    }

    public func load() async {
        guard !state.isLoading else {
            return
        }

        state = .loading

        do {
            let items = try await fetchItemsUseCase.execute()
            state = .loaded(items)
        } catch {
            state = .failed("Unable to load sample items.")
        }
    }
}

public enum SampleViewState: Equatable, Sendable {
    case idle
    case loading
    case loaded([SampleItem])
    case failed(String)

    public var isLoading: Bool {
        self == .loading
    }
}
