import Foundation

struct GoogleCalendarEvent: Decodable {
    let id: String
    let summary: String?
    let start: EventDate
    let end: EventDate?

    struct EventDate: Decodable {
        let dateTime: Date?
        let date: String?
    }
}

private struct GoogleCalendarEventsResponse: Decodable {
    let items: [GoogleCalendarEvent]
}

protocol GoogleCalendarFetching {
    func fetchUpcomingEvents(calendarId: String, accessToken: String) async throws -> [GoogleCalendarEvent]
}

enum GoogleCalendarServiceError: LocalizedError {
    case missingCalendarID
    case missingAccessToken
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .missingCalendarID:
            return "Google Calendar の calendarId が未設定です。"
        case .missingAccessToken:
            return "Google Calendar のアクセストークンが未設定です。"
        case .requestFailed:
            return "Google Calendar から予定を取得できませんでした。"
        }
    }
}

struct GoogleCalendarService: GoogleCalendarFetching {
    func fetchUpcomingEvents(calendarId: String, accessToken: String) async throws -> [GoogleCalendarEvent] {
        guard !calendarId.isEmpty else {
            throw GoogleCalendarServiceError.missingCalendarID
        }

        guard !accessToken.isEmpty else {
            throw GoogleCalendarServiceError.missingAccessToken
        }

        let escapedCalendarID = calendarId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? calendarId
        let timeMin = ISO8601DateFormatter().string(from: Date())
        guard let url = URL(
            string: "https://www.googleapis.com/calendar/v3/calendars/\(escapedCalendarID)/events?singleEvents=true&orderBy=startTime&maxResults=10&timeMin=\(timeMin)"
        ) else {
            throw GoogleCalendarServiceError.requestFailed
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw GoogleCalendarServiceError.requestFailed
        }

        return try decoder.decode(GoogleCalendarEventsResponse.self, from: data).items
    }
}
