import Foundation

struct StatementAIRequest {
    var tags: [String]
    var weather: WeatherContext
    var date: Date
    var primaryState: CapybaraState
    var supplementalNote: String = ""
    var supplementalImageCount: Int = 0
    var supplementalImageRefs: [String] = []
}

protocol StatementAIProviding {
    func generateStatement(_ request: StatementAIRequest) async throws -> String
}

struct LocalStatementAIService: StatementAIProviding {
    func generateStatement(_ request: StatementAIRequest) async throws -> String {
        try await Task.sleep(nanoseconds: 900_000_000)
        return Self.fallbackStatement(
            tags: request.tags,
            weather: request.weather,
            supplementalNote: request.supplementalNote,
            supplementalImageCount: request.supplementalImageCount,
            primaryState: request.primaryState
        )
    }

    static func fallbackStatement(
        tags: [String],
        weather: WeatherContext,
        supplementalNote: String = "",
        supplementalImageCount: Int = 0,
        primaryState: CapybaraState = .chestTightHug
    ) -> String {
        let selected = Array(tags.prefix(4))
        let leadingTerm = selected.first ?? "有点累"
        let tagSentence = naturalTagPhrase(selected)
        let weatherLine = weather.shortText.contains("无天气") ? "" : "外面是\(weather.shortText.replacingOccurrences(of: " · ", with: "的"))，"
        let trimmedNote = supplementalNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasExtra = !trimmedNote.isEmpty || supplementalImageCount > 0
        let extraLine = hasExtra ? extraContextLine(primaryState: primaryState) : "不用急着把自己解释清楚，今天先少用一点力气也可以。"

        return """
        今天的你像是被生活轻轻按住了暂停键，\(leadingTerm)不是矫情，是身体和心里都在提醒你慢一点。

        \(weatherLine)\(tagSentence)，这些感受不用立刻被整理好，也不用马上变得很像平常的自己。

        \(extraLine)
        """
    }

    private static func naturalTagPhrase(_ tags: [String]) -> String {
        guard !tags.isEmpty else { return "有些感受没有名字也没关系" }
        if tags.count == 1 {
            return "你选了“\(tags[0])”"
        }
        let head = tags.dropLast().map { "“\($0)”" }.joined(separator: "、")
        return "\(head)和“\(tags.last ?? "")”挤在同一天里"
    }

    private static func extraContextLine(primaryState: CapybaraState) -> String {
        switch primaryState {
        case .hideBehindSpoon:
            return "你多放进来的那些细节，我会当作一小块隐私的屏风收好：可以不回复，也可以晚一点再面对。"
        case .fearTomorrowNight:
            return "你多放进来的那些细节，我先帮你放在这里：明天还没来，今晚不用先替它用完力气。"
        case .overwhelmedNoise:
            return "你多放进来的那些细节，我先帮你降一点音量：世界太吵时，退后一步不是失败。"
        case .sleepyLiedDown, .noAppetiteBlanket:
            return "你多放进来的那些细节，我会轻轻收好：今天先把自己安顿住，比把所有事做好更重要。"
        case .phoneDazed:
            return "你多放进来的那些细节，我先帮你放稳：发呆、刷手机、躲一会儿，可能只是你在找回一点缓冲。"
        case .idleDefault, .chestTightHug, .drawerKeeper:
            return "你多放进来的那些细节，我也先帮你收好，不必一次说完；被看见一点点，就已经很够了。"
        }
    }
}

struct StatementAIServiceFactory {
    static func make() -> StatementAIProviding {
        if let endpoint = configuredCloudBaseEndpoint {
            return FallbackStatementAIService(
                primary: CloudBaseStatementAIService(endpoint: endpoint),
                fallback: LocalStatementAIService()
            )
        }
        return LocalStatementAIService()
    }

    private static var configuredCloudBaseEndpoint: URL? {
        let defaultsValue = UserDefaults.standard.string(forKey: "cloudBaseGenerateDeclarationURL")
        let plistValue = Bundle.main.object(forInfoDictionaryKey: "SpoonieCloudBaseGenerateDeclarationURL") as? String
        let rawValue = [defaultsValue, plistValue]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty && !$0.contains("<") }
        return rawValue.flatMap(URL.init(string:))
    }
}

struct FallbackStatementAIService: StatementAIProviding {
    let primary: StatementAIProviding
    let fallback: StatementAIProviding

    func generateStatement(_ request: StatementAIRequest) async throws -> String {
        do {
            return try await primary.generateStatement(request)
        } catch {
            return try await fallback.generateStatement(request)
        }
    }
}

struct CloudBaseStatementAIService: StatementAIProviding {
    let endpoint: URL

    func generateStatement(_ request: StatementAIRequest) async throws -> String {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 18

        urlRequest.httpBody = try JSONEncoder().encode(Payload(
            tags: request.tags,
            weatherNarrative: request.weather.narrative,
            weatherShort: request.weather.shortText,
            dateISO: ISO8601DateFormatter().string(from: request.date),
            primaryState: request.primaryState.rawValue,
            supplementalNoteHint: privacyPreservingHint(from: request.supplementalNote),
            supplementalImageCount: request.supplementalImageCount,
            supplementalImageRefs: request.supplementalImageRefs,
            style: "friend_companion",
            targetLength: "90-140"
        ))

        let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
        if let httpResponse = urlResponse as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
        return decodedResponse.statement
    }

    private func privacyPreservingHint(from note: String) -> String {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        let maxLength = 180
        if trimmed.count <= maxLength {
            return trimmed
        }
        return String(trimmed.prefix(maxLength)) + "..."
    }

    private struct Payload: Encodable {
        var tags: [String]
        var weatherNarrative: String
        var weatherShort: String
        var dateISO: String
        var primaryState: String
        var supplementalNoteHint: String
        var supplementalImageCount: Int
        var supplementalImageRefs: [String]
        var style: String
        var targetLength: String
    }

    private struct Response: Decodable {
        var statement: String
    }
}
