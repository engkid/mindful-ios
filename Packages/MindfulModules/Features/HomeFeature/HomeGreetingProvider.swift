import Foundation

public struct HomeGreetingProvider: Sendable {
    private let calendar: Calendar

    public init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
    }

    public func greeting(for date: Date = .now) -> String {
        switch hour(for: date) {
        case 5..<12:
            "Good morning"
        case 12..<17:
            "Good afternoon"
        case 17..<21:
            "Good evening"
        default:
            "Good night"
        }
    }

    private func hour(for date: Date) -> Int {
        calendar.component(.hour, from: date)
    }
}
