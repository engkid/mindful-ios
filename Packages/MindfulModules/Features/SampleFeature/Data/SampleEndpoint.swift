import CoreNetworking

public struct SampleEndpoint: APIRequest {
    public typealias Response = [SampleItemDTO]

    public let path: String

    public init(path: String = "posts") {
        self.path = path
    }
}
