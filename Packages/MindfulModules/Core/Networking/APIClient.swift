import Foundation

public protocol APIClient: Sendable {
    func send<Request: APIRequest>(_ request: Request) async throws -> Request.Response
}

public protocol APIRequest: Sendable {
    associatedtype Response: Decodable & Sendable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
}

public extension APIRequest {
    var method: HTTPMethod { .get }
    var headers: [String: String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: Data? { nil }
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public enum APIError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case unacceptableStatusCode(Int)
}

public final class URLSessionAPIClient: APIClient, @unchecked Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    public func send<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
        let urlRequest = try makeURLRequest(from: request)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.unacceptableStatusCode(httpResponse.statusCode)
        }

        return try decoder.decode(Request.Response.self, from: data)
    }

    private func makeURLRequest<Request: APIRequest>(from request: Request) throws -> URLRequest {
        let url = baseURL.appending(path: request.path)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems
        }

        guard let finalURL = components.url else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }
}
