import Foundation
import HomeFeature
import Testing

@Suite
struct HomeGreetingProviderTests {
    @Test
    func greetingUsesMorningFromConfiguredTimezone() throws {
        let provider = HomeGreetingProvider(calendar: calendar(timeZoneIdentifier: "Asia/Jakarta"))
        let date = try date("2026-05-03T23:30:00Z")

        #expect(provider.greeting(for: date) == "Good morning")
    }

    @Test
    func greetingUsesAfternoonFromConfiguredTimezone() throws {
        let provider = HomeGreetingProvider(calendar: calendar(timeZoneIdentifier: "Asia/Jakarta"))
        let date = try date("2026-05-03T06:00:00Z")

        #expect(provider.greeting(for: date) == "Good afternoon")
    }

    @Test
    func greetingUsesEveningFromConfiguredTimezone() throws {
        let provider = HomeGreetingProvider(calendar: calendar(timeZoneIdentifier: "Asia/Jakarta"))
        let date = try date("2026-05-03T12:00:00Z")

        #expect(provider.greeting(for: date) == "Good evening")
    }

    @Test
    func greetingUsesNightFromConfiguredTimezone() throws {
        let provider = HomeGreetingProvider(calendar: calendar(timeZoneIdentifier: "Asia/Jakarta"))
        let date = try date("2026-05-03T16:00:00Z")

        #expect(provider.greeting(for: date) == "Good night")
    }

    @Test
    func sameInstantCanResolveDifferentlyAcrossTimezones() throws {
        let jakartaProvider = HomeGreetingProvider(calendar: calendar(timeZoneIdentifier: "Asia/Jakarta"))
        let newYorkProvider = HomeGreetingProvider(calendar: calendar(timeZoneIdentifier: "America/New_York"))
        let date = try date("2026-05-03T23:30:00Z")

        #expect(jakartaProvider.greeting(for: date) == "Good morning")
        #expect(newYorkProvider.greeting(for: date) == "Good evening")
    }

    private func calendar(timeZoneIdentifier: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .gmt
        return calendar
    }

    private func date(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        return try #require(formatter.date(from: value))
    }
}
