import Foundation
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case drawer
    case me

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "今天"
        case .drawer: return "抽屉"
        case .me: return "我的"
        }
    }
}

enum CapybaraState: String, Identifiable, Codable {
    case idleDefault = "idle_default"
    case sleepyLiedDown = "sleepy_lied_down"
    case phoneDazed = "phone_dazed"
    case chestTightHug = "chest_tight_hug"
    case hideBehindSpoon = "hide_behind_spoon"
    case fearTomorrowNight = "fear_tomorrow_night"
    case noAppetiteBlanket = "no_appetite_blanket"
    case overwhelmedNoise = "overwhelmed_noise"
    case drawerKeeper = "drawer_keeper"

    var id: String { rawValue }

    var frameDirectory: String {
        switch self {
        case .idleDefault:
            return "ip/states/idle_default_natural/frames"
        case .sleepyLiedDown:
            return "ip/states/sleepy_lied_down_natural/frames"
        case .phoneDazed:
            return "ip/states/phone_dazed_natural/frames"
        case .chestTightHug:
            return "ip/states/chest_tight_hug_natural/frames"
        case .hideBehindSpoon:
            return "ip/states/hide_behind_spoon_natural/frames"
        case .fearTomorrowNight:
            return "ip/states/fear_tomorrow_night_natural/frames"
        case .noAppetiteBlanket:
            return "ip/states/no_appetite_blanket_natural/frames"
        case .overwhelmedNoise:
            return "ip/states/overwhelmed_noise_natural/frames"
        case .drawerKeeper:
            return "ip/states/drawer_keeper_natural/frames"
        }
    }

    var drawerStamp: String? {
        switch self {
        case .sleepyLiedDown:
            return "ip/drawer-stamps/sleepy_lied_down_stamp_final.png"
        case .phoneDazed:
            return "ip/drawer-stamps/phone_dazed_stamp_final.png"
        case .chestTightHug, .hideBehindSpoon, .noAppetiteBlanket, .overwhelmedNoise:
            return "ip/drawer-stamps/chest_tight_hug_stamp_final.png"
        case .fearTomorrowNight:
            return "ip/drawer-stamps/fear_tomorrow_night_stamp_final.png"
        case .idleDefault, .drawerKeeper:
            return "ip/drawer-stamps/sleepy_lied_down_stamp_final.png"
        }
    }
}

struct MoodTag: Identifiable, Hashable {
    let id: UUID
    let title: String
    let category: String
    let capybaraState: CapybaraState
    let rotation: Double
    let width: CGFloat
    let isCustom: Bool

    init(
        id: UUID = UUID(),
        title: String,
        category: String,
        capybaraState: CapybaraState,
        rotation: Double,
        width: CGFloat,
        isCustom: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.capybaraState = capybaraState
        self.rotation = rotation
        self.width = width
        self.isCustom = isCustom
    }
}

struct DailyEntry: Identifiable, Hashable, Codable {
    var id = UUID()
    var date: Date
    var weather: String
    var weatherShort: String
    var tags: [String]
    var statement: String
    var capybaraState: CapybaraState
    var supplementalNote: String
    var supplementalImages: [DailyAttachment]

    init(
        id: UUID = UUID(),
        date: Date,
        weather: String,
        weatherShort: String,
        tags: [String],
        statement: String,
        capybaraState: CapybaraState,
        supplementalNote: String = "",
        supplementalImages: [DailyAttachment] = []
    ) {
        self.id = id
        self.date = date
        self.weather = weather
        self.weatherShort = weatherShort
        self.tags = tags
        self.statement = statement
        self.capybaraState = capybaraState
        self.supplementalNote = supplementalNote
        self.supplementalImages = supplementalImages
    }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case weather
        case weatherShort
        case tags
        case statement
        case capybaraState
        case supplementalNote
        case supplementalImages
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try container.decode(Date.self, forKey: .date)
        weather = try container.decode(String.self, forKey: .weather)
        weatherShort = try container.decode(String.self, forKey: .weatherShort)
        tags = try container.decode([String].self, forKey: .tags)
        statement = try container.decode(String.self, forKey: .statement)
        capybaraState = try container.decode(CapybaraState.self, forKey: .capybaraState)
        supplementalNote = try container.decodeIfPresent(String.self, forKey: .supplementalNote) ?? ""
        supplementalImages = try container.decodeIfPresent([DailyAttachment].self, forKey: .supplementalImages) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(weather, forKey: .weather)
        try container.encode(weatherShort, forKey: .weatherShort)
        try container.encode(tags, forKey: .tags)
        try container.encode(statement, forKey: .statement)
        try container.encode(capybaraState, forKey: .capybaraState)
        try container.encode(supplementalNote, forKey: .supplementalNote)
        try container.encode(supplementalImages, forKey: .supplementalImages)
    }

    var dateTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: date).replacingOccurrences(of: "星期", with: "周")
    }

    var hasSupplementalContext: Bool {
        !supplementalNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !supplementalImages.isEmpty
    }
}

struct DailyAttachment: Identifiable, Hashable, Codable {
    var id = UUID()
    var mimeType = "image/jpeg"
    var dataBase64: String

    var data: Data? {
        Data(base64Encoded: dataBase64)
    }
}

struct SupplementalDraft: Equatable {
    var note = ""
    var images: [DailyAttachment] = []

    var hasContent: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !images.isEmpty
    }

    var summaryText: String {
        var parts: [String] = []
        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("已写")
        }
        if !images.isEmpty {
            parts.append("\(images.count)张图")
        }
        return parts.isEmpty ? "说多点" : parts.joined(separator: " · ")
    }
}

struct WeatherContext: Equatable {
    var city: String
    var narrative: String
    var shortText: String
    var source: String

    static let fallback = WeatherContext(
        city: "广州",
        narrative: "广州 · 天灰蒙蒙的，像罩了层毛玻璃",
        shortText: "广州 · 微风有雾",
        source: "fallback"
    )
}

enum WeatherStatus: Equatable {
    case needsPermission
    case requesting
    case ready(WeatherContext)
    case denied
    case failed(String)

    var displayText: String {
        switch self {
        case .needsPermission:
            return "授权位置，看看外面像什么"
        case .requesting:
            return "正在看看外面的天气"
        case .ready(let context):
            return context.narrative
        case .denied:
            return "未开启位置，先用无天气模式"
        case .failed:
            return WeatherContext.fallback.narrative
        }
    }

    var shortText: String {
        switch self {
        case .ready(let context):
            return context.shortText
        case .requesting:
            return "天气生成中"
        case .denied:
            return "无天气"
        case .needsPermission, .failed:
            return WeatherContext.fallback.shortText
        }
    }
}

enum GenerationStatus: Equatable {
    case idle
    case loading
    case failed(String)
}

enum SpoonieStoreError: Error {
    case emptyTags
}

final class SpoonieStore: ObservableObject {
    @Published var selectedTab: AppTab = .today
    @Published var selectedTags: Set<String> = ["躺了一天", "胸口闷", "不想回消息"]
    @Published var customTags: [MoodTag] = []
    @Published var todayEntry: DailyEntry?
    @Published var entries: [DailyEntry] = DailyEntry.samples
    @Published var weatherStatus: WeatherStatus = .needsPermission
    @Published var generationStatus: GenerationStatus = .idle
    @Published var selectedEntry: DailyEntry?
    @Published var supplementalDraft = SupplementalDraft()

    private let database = SpoonieDatabase()
    private let weatherService = LocationWeatherService()
    private let statementService: StatementAIProviding = StatementAIServiceFactory.make()
    private var activeGenerationID: UUID?

    let baseMoodTags: [MoodTag] = [
        MoodTag(title: "躺了一天", category: "生理", capybaraState: .sleepyLiedDown, rotation: 4, width: 110),
        MoodTag(title: "没洗头", category: "生理", capybaraState: .noAppetiteBlanket, rotation: -2, width: 92),
        MoodTag(title: "嗜睡", category: "生理", capybaraState: .sleepyLiedDown, rotation: 2, width: 78),
        MoodTag(title: "胸口闷", category: "生理", capybaraState: .chestTightHug, rotation: -5, width: 96),
        MoodTag(title: "没有食欲", category: "生理", capybaraState: .noAppetiteBlanket, rotation: 3, width: 108),
        MoodTag(title: "沉迷刷手机", category: "生理", capybaraState: .phoneDazed, rotation: -3, width: 126),
        MoodTag(title: "身体很沉", category: "生理", capybaraState: .sleepyLiedDown, rotation: 2, width: 108),
        MoodTag(title: "睡得很碎", category: "生理", capybaraState: .sleepyLiedDown, rotation: -3, width: 108),
        MoodTag(title: "头有点胀", category: "生理", capybaraState: .overwhelmedNoise, rotation: 3, width: 108),
        MoodTag(title: "不想回消息", category: "心理", capybaraState: .hideBehindSpoon, rotation: 3, width: 126),
        MoodTag(title: "觉得委屈", category: "心理", capybaraState: .chestTightHug, rotation: -2, width: 104),
        MoodTag(title: "无故流泪", category: "心理", capybaraState: .chestTightHug, rotation: 2, width: 104),
        MoodTag(title: "害怕明天", category: "心理", capybaraState: .fearTomorrowNight, rotation: -5, width: 104),
        MoodTag(title: "随便吧", category: "心理", capybaraState: .phoneDazed, rotation: 2, width: 92),
        MoodTag(title: "正在发呆", category: "心理", capybaraState: .phoneDazed, rotation: 4, width: 104),
        MoodTag(title: "脑子停不下来", category: "心理", capybaraState: .overwhelmedNoise, rotation: -2, width: 138),
        MoodTag(title: "什么都不想管", category: "心理", capybaraState: .hideBehindSpoon, rotation: 3, width: 138),
        MoodTag(title: "外面太吵", category: "环境", capybaraState: .overwhelmedNoise, rotation: -3, width: 108),
        MoodTag(title: "天气闷闷的", category: "环境", capybaraState: .chestTightHug, rotation: 2, width: 126),
        MoodTag(title: "房间很乱", category: "环境", capybaraState: .overwhelmedNoise, rotation: -2, width: 108),
        MoodTag(title: "被消息淹没", category: "环境", capybaraState: .overwhelmedNoise, rotation: 3, width: 126),
        MoodTag(title: "什么都很刺耳", category: "环境", capybaraState: .overwhelmedNoise, rotation: -3, width: 138),
        MoodTag(title: "不想解释", category: "关系", capybaraState: .hideBehindSpoon, rotation: 2, width: 108),
        MoodTag(title: "怕别人失望", category: "关系", capybaraState: .fearTomorrowNight, rotation: -2, width: 126),
        MoodTag(title: "装正常好累", category: "关系", capybaraState: .hideBehindSpoon, rotation: 3, width: 126),
        MoodTag(title: "不想见人", category: "关系", capybaraState: .hideBehindSpoon, rotation: -3, width: 108)
    ]

    init() {
        let storedEntries = database.loadEntries()
        if !storedEntries.isEmpty {
            entries = storedEntries
            todayEntry = storedEntries.first { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        }
    }

    var moodTags: [MoodTag] {
        customTags + baseMoodTags
    }

    var selectedMoodTags: [MoodTag] {
        moodTags.filter { selectedTags.contains($0.title) }
    }

    var primaryCapybaraState: CapybaraState {
        selectedMoodTags.first?.capybaraState ?? .idleDefault
    }

    func toggle(_ tag: MoodTag) {
        if selectedTags.contains(tag.title) {
            selectedTags.remove(tag.title)
        } else {
            selectedTags.insert(tag.title)
        }
    }

    func addCustomTag(_ text: String) {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        guard !moodTags.contains(where: { $0.title == cleaned }) else {
            selectedTags.insert(cleaned)
            return
        }
        let tag = MoodTag(
            title: cleaned,
            category: "自定义",
            capybaraState: .chestTightHug,
            rotation: [-3, -1, 2, 4].randomElement() ?? 2,
            width: min(max(CGFloat(cleaned.count * 16 + 42), 92), 160),
            isCustom: true
        )
        customTags.insert(tag, at: 0)
        selectedTags.insert(cleaned)
    }

    @MainActor
    func requestWeatherPermissionAndLoad() async {
        weatherStatus = .requesting
        do {
            let context = try await weatherService.requestWeatherContext()
            weatherStatus = .ready(context)
        } catch LocationWeatherError.denied {
            weatherStatus = .denied
        } catch {
            weatherStatus = .failed("天气暂时没有端稳")
        }
    }

    @MainActor
    func generateTodayDeclaration() async {
        guard !selectedTags.isEmpty else {
            generationStatus = .failed("先选一个状态就好")
            return
        }

        let generationID = UUID()
        activeGenerationID = generationID
        generationStatus = .loading
        let startedAt = Date()
        let tags = selectedMoodTags.map(\.title)
        let weather = currentWeatherContext
        let capybaraState = primaryCapybaraState == .idleDefault ? .chestTightHug : primaryCapybaraState
        let note = supplementalDraft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let images = supplementalDraft.images
        let request = StatementAIRequest(
            tags: tags,
            weather: weather,
            date: Date(),
            primaryState: capybaraState,
            supplementalNote: note,
            supplementalImageCount: images.count
        )

        let statement: String
        do {
            statement = try await statementService.generateStatement(request)
        } catch {
            statement = LocalStatementAIService.fallbackStatement(
                tags: tags,
                weather: weather,
                supplementalNote: note,
                supplementalImageCount: images.count,
                primaryState: capybaraState
            )
        }

        let minimumLoadingDuration: TimeInterval = 2.25
        let remainingLoadingTime = minimumLoadingDuration - Date().timeIntervalSince(startedAt)
        if remainingLoadingTime > 0 {
            try? await Task.sleep(nanoseconds: UInt64(remainingLoadingTime * 1_000_000_000))
        }

        guard activeGenerationID == generationID else { return }
        commitTodayEntry(
            tags: tags,
            weather: weather,
            statement: statement,
            capybaraState: capybaraState,
            supplementalNote: note,
            supplementalImages: images
        )
    }

    @MainActor
    func cancelGeneration() {
        activeGenerationID = nil
        if generationStatus == .loading {
            generationStatus = .idle
        }
    }

    @MainActor
    func finishGenerationWithLocalStatement() {
        guard generationStatus == .loading, !selectedTags.isEmpty else { return }
        activeGenerationID = nil
        let tags = selectedMoodTags.map(\.title)
        let weather = currentWeatherContext
        let capybaraState = primaryCapybaraState == .idleDefault ? .chestTightHug : primaryCapybaraState
        let note = supplementalDraft.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let images = supplementalDraft.images
        let statement = LocalStatementAIService.fallbackStatement(
            tags: tags,
            weather: weather,
            supplementalNote: note,
            supplementalImageCount: images.count,
            primaryState: capybaraState
        )
        commitTodayEntry(
            tags: tags,
            weather: weather,
            statement: statement,
            capybaraState: capybaraState,
            supplementalNote: note,
            supplementalImages: images
        )
    }

    @MainActor
    private func commitTodayEntry(
        tags: [String],
        weather: WeatherContext,
        statement: String,
        capybaraState: CapybaraState,
        supplementalNote: String,
        supplementalImages: [DailyAttachment]
    ) {
        let entry = DailyEntry(
            date: Date(),
            weather: weather.narrative,
            weatherShort: weather.shortText,
            tags: tags,
            statement: statement,
            capybaraState: capybaraState,
            supplementalNote: supplementalNote,
            supplementalImages: supplementalImages
        )
        todayEntry = entry
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        entries.insert(entry, at: 0)
        database.saveEntries(entries)
        supplementalDraft = SupplementalDraft()
        activeGenerationID = nil
        generationStatus = .idle
    }

    func resetToday() {
        todayEntry = nil
        activeGenerationID = nil
        generationStatus = .idle
        supplementalDraft = SupplementalDraft()
    }

    var currentWeatherContext: WeatherContext {
        if case .ready(let context) = weatherStatus {
            return context
        }
        return WeatherContext.fallback
    }
}

extension DailyEntry {
    static var samples: [DailyEntry] {
        let calendar = Calendar.current
        let today = Date()
        return [
            DailyEntry(
                date: calendar.date(byAdding: .day, value: -38, to: today) ?? today,
                weather: "广州 · 微风有雾",
                weatherShort: "广州 · 微风有雾",
                tags: ["躺了一天", "胸口闷", "不想回消息"],
                statement: "雨把世界调成了低音量，今天少一点力气，不是你的错。",
                capybaraState: .sleepyLiedDown
            ),
            DailyEntry(
                date: calendar.date(byAdding: .day, value: -39, to: today) ?? today,
                weather: "广州 · 微风有雾",
                weatherShort: "广州 · 微风有雾",
                tags: ["躺了一天", "胸口闷", "不想回消息"],
                statement: "雨把世界调成了低音量，今天少一点力气，不是你的错。",
                capybaraState: .chestTightHug
            ),
            DailyEntry(
                date: calendar.date(byAdding: .day, value: -40, to: today) ?? today,
                weather: "广州 · 微风有雾",
                weatherShort: "广州 · 微风有雾",
                tags: ["躺了一天", "胸口闷", "不想回消息"],
                statement: "雨把世界调成了低音量，今天少一点力气，不是你的错。",
                capybaraState: .phoneDazed
            )
        ]
    }
}
