import Foundation

struct StatementAIRequest {
    var tags: [String]
    var weather: WeatherContext
    var date: Date
    var primaryState: CapybaraState
}

protocol StatementAIProviding {
    func generateStatement(_ request: StatementAIRequest) async throws -> String
}

struct LocalStatementAIService: StatementAIProviding {
    func generateStatement(_ request: StatementAIRequest) async throws -> String {
        try await Task.sleep(nanoseconds: 900_000_000)
        return Self.fallbackStatement(tags: request.tags, weather: request.weather)
    }

    static func fallbackStatement(tags: [String], weather: WeatherContext) -> String {
        let terms = tags.prefix(3).joined(separator: "/")
        let weatherTail = weather.shortText.contains("无天气") ? "" : "\n外面也不是很轻，你不用急着把自己解释清楚。"
        return """
        今天已经很沉了。
        \(terms)，
        这些不是你在偷懒，
        而是身体和心里都在把门关小一点。\(weatherTail)
        """
    }
}

struct RemoteStatementAIService: StatementAIProviding {
    let endpoint: URL
    let apiKeyProvider: () -> String?

    func generateStatement(_ request: StatementAIRequest) async throws -> String {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let apiKey = apiKeyProvider() {
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpBody = try JSONEncoder().encode(Payload(
            tags: request.tags,
            weatherNarrative: request.weather.narrative,
            weatherShort: request.weather.shortText,
            primaryState: request.primaryState.rawValue
        ))

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let response = try JSONDecoder().decode(Response.self, from: data)
        return response.statement
    }

    private struct Payload: Encodable {
        var tags: [String]
        var weatherNarrative: String
        var weatherShort: String
        var primaryState: String
    }

    private struct Response: Decodable {
        var statement: String
    }
}
