import Foundation

public struct Session: Equatable, Sendable {
    public let accessToken: String
    public let userID: String

    public init(accessToken: String, userID: String) {
        self.accessToken = accessToken
        self.userID = userID
    }
}

public actor SessionStore {
    private var session: Session?

    public init(session: Session? = nil) {
        self.session = session
    }

    public func currentSession() -> Session? {
        session
    }

    public func update(session: Session) {
        self.session = session
    }

    public func clear() {
        session = nil
    }
}
