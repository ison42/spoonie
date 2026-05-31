import Foundation
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case echo
    case drawer
    case me

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "今天"
        case .echo: return "回声"
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
    var echoPostId: UUID?
    var echoPublishedAt: Date?
    var echoSourceText: String?

    init(
        id: UUID = UUID(),
        date: Date,
        weather: String,
        weatherShort: String,
        tags: [String],
        statement: String,
        capybaraState: CapybaraState,
        supplementalNote: String = "",
        supplementalImages: [DailyAttachment] = [],
        echoPostId: UUID? = nil,
        echoPublishedAt: Date? = nil,
        echoSourceText: String? = nil
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
        self.echoPostId = echoPostId
        self.echoPublishedAt = echoPublishedAt
        self.echoSourceText = echoSourceText
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
        case echoPostId
        case echoPublishedAt
        case echoSourceText
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
        echoPostId = try container.decodeIfPresent(UUID.self, forKey: .echoPostId)
        echoPublishedAt = try container.decodeIfPresent(Date.self, forKey: .echoPublishedAt)
        echoSourceText = try container.decodeIfPresent(String.self, forKey: .echoSourceText)
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
        try container.encodeIfPresent(echoPostId, forKey: .echoPostId)
        try container.encodeIfPresent(echoPublishedAt, forKey: .echoPublishedAt)
        try container.encodeIfPresent(echoSourceText, forKey: .echoSourceText)
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

struct UserProfile: Hashable, Codable {
    var id = UUID()
    var phoneNumber: String?
    var displayName: String
    var avatarPreset: Int
    var avatarImageBase64: String?
    var isLoggedIn: Bool

    static func randomGuest() -> UserProfile {
        UserProfile(
            displayName: randomName(),
            avatarPreset: Int.random(in: 0..<avatarPalette.count),
            avatarImageBase64: nil,
            isLoggedIn: false
        )
    }

    static func randomName() -> String {
        let prefixes = ["慢慢", "轻轻", "小睡", "雾里", "抱勺", "发呆", "晚风", "云边"]
        let suffixes = ["水豚", "小勺", "纸条", "月亮", "软垫", "小岛", "云朵", "回声"]
        return "\(prefixes.randomElement() ?? "抱勺")\(suffixes.randomElement() ?? "水豚")"
    }

    static let avatarPalette: [AvatarPalette] = [
        AvatarPalette(symbol: "moon", colors: [Color(red: 0.72, green: 0.68, blue: 1.0), Color(red: 0.93, green: 0.88, blue: 1.0)]),
        AvatarPalette(symbol: "cloud", colors: [Color(red: 0.72, green: 0.86, blue: 1.0), Color(red: 0.93, green: 0.90, blue: 1.0)]),
        AvatarPalette(symbol: "leaf", colors: [Color(red: 0.70, green: 0.88, blue: 0.78), Color(red: 0.94, green: 0.96, blue: 0.86)]),
        AvatarPalette(symbol: "sparkles", colors: [Color(red: 0.98, green: 0.75, blue: 0.84), Color(red: 0.93, green: 0.88, blue: 1.0)]),
        AvatarPalette(symbol: "cup.and.saucer", colors: [Color(red: 0.95, green: 0.82, blue: 0.60), Color(red: 0.95, green: 0.90, blue: 0.78)])
    ]
}

struct AvatarPalette {
    let symbol: String
    let colors: [Color]
}

enum EchoIdentityMode: String, CaseIterable, Identifiable, Codable {
    case anonymous
    case named

    var id: String { rawValue }

    var title: String {
        switch self {
        case .anonymous: return "匿名"
        case .named: return "用头像昵称"
        }
    }

    var subtitle: String {
        switch self {
        case .anonymous: return "别人只看到匿名纸条"
        case .named: return "展示你的头像和昵称"
        }
    }
}

enum EchoReactionType: String, CaseIterable, Identifiable, Codable {
    case sameHere
    case hug
    case spoon
    case slowly
    case sitTogether

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sameHere: return "我也有过"
        case .hug: return "抱一下"
        case .spoon: return "放一把小勺子"
        case .slowly: return "慢慢来"
        case .sitTogether: return "陪你坐会儿"
        }
    }

    var icon: String {
        switch self {
        case .sameHere: return "sparkles"
        case .hug: return "heart"
        case .spoon: return "circle.grid.cross"
        case .slowly: return "leaf"
        case .sitTogether: return "moon"
        }
    }
}

struct EchoPost: Identifiable, Hashable, Codable {
    var id = UUID()
    var sourceEntryId: UUID?
    var authorHash: String
    var text: String
    var tags: [String]
    var weatherShort: String?
    var createdAt: Date
    var reactionCounts: [EchoReactionType: Int]
    var myReactions: Set<EchoReactionType>
    var identityMode: EchoIdentityMode
    var authorDisplayName: String?
    var authorAvatarPreset: Int?
    var isMine: Bool
    var isHidden: Bool
    var isReported: Bool

    init(
        id: UUID = UUID(),
        sourceEntryId: UUID? = nil,
        authorHash: String,
        text: String,
        tags: [String],
        weatherShort: String? = nil,
        createdAt: Date = Date(),
        reactionCounts: [EchoReactionType: Int] = [:],
        myReactions: Set<EchoReactionType> = [],
        identityMode: EchoIdentityMode = .anonymous,
        authorDisplayName: String? = nil,
        authorAvatarPreset: Int? = nil,
        isMine: Bool = false,
        isHidden: Bool = false,
        isReported: Bool = false
    ) {
        self.id = id
        self.sourceEntryId = sourceEntryId
        self.authorHash = authorHash
        self.text = text
        self.tags = tags
        self.weatherShort = weatherShort
        self.createdAt = createdAt
        self.reactionCounts = reactionCounts
        self.myReactions = myReactions
        self.identityMode = identityMode
        self.authorDisplayName = authorDisplayName
        self.authorAvatarPreset = authorAvatarPreset
        self.isMine = isMine
        self.isHidden = isHidden
        self.isReported = isReported
    }

    var visibleReactionTotal: Int {
        reactionCounts.values.reduce(0, +)
    }

    var myReaction: EchoReactionType? {
        myReactions.first
    }

    var fuzzyTime: String {
        let interval = Date().timeIntervalSince(createdAt)
        if interval < 60 * 20 {
            return "刚刚"
        }
        if Calendar.current.isDateInToday(createdAt) {
            return "今天"
        }
        if Calendar.current.isDateInYesterday(createdAt) {
            return "昨天"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: createdAt)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case sourceEntryId
        case authorHash
        case text
        case tags
        case weatherShort
        case createdAt
        case reactionCounts
        case myReaction
        case myReactions
        case identityMode
        case authorDisplayName
        case authorAvatarPreset
        case isMine
        case isHidden
        case isReported
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        sourceEntryId = try container.decodeIfPresent(UUID.self, forKey: .sourceEntryId)
        authorHash = try container.decode(String.self, forKey: .authorHash)
        text = try container.decode(String.self, forKey: .text)
        tags = try container.decode([String].self, forKey: .tags)
        weatherShort = try container.decodeIfPresent(String.self, forKey: .weatherShort)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        reactionCounts = try container.decodeIfPresent([EchoReactionType: Int].self, forKey: .reactionCounts) ?? [:]
        if let reactions = try container.decodeIfPresent(Set<EchoReactionType>.self, forKey: .myReactions) {
            myReactions = reactions
        } else if let reaction = try container.decodeIfPresent(EchoReactionType.self, forKey: .myReaction) {
            myReactions = [reaction]
        } else {
            myReactions = []
        }
        identityMode = try container.decodeIfPresent(EchoIdentityMode.self, forKey: .identityMode) ?? .anonymous
        authorDisplayName = try container.decodeIfPresent(String.self, forKey: .authorDisplayName)
        authorAvatarPreset = try container.decodeIfPresent(Int.self, forKey: .authorAvatarPreset)
        isMine = try container.decodeIfPresent(Bool.self, forKey: .isMine) ?? false
        isHidden = try container.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
        isReported = try container.decodeIfPresent(Bool.self, forKey: .isReported) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(sourceEntryId, forKey: .sourceEntryId)
        try container.encode(authorHash, forKey: .authorHash)
        try container.encode(text, forKey: .text)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(weatherShort, forKey: .weatherShort)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(reactionCounts, forKey: .reactionCounts)
        try container.encode(myReactions, forKey: .myReactions)
        try container.encode(identityMode, forKey: .identityMode)
        try container.encodeIfPresent(authorDisplayName, forKey: .authorDisplayName)
        try container.encodeIfPresent(authorAvatarPreset, forKey: .authorAvatarPreset)
        try container.encode(isMine, forKey: .isMine)
        try container.encode(isHidden, forKey: .isHidden)
        try container.encode(isReported, forKey: .isReported)
    }
}

struct EchoThread: Identifiable, Hashable, Codable {
    var id = UUID()
    var postId: UUID
    var authorHash: String
    var participantHash: String
    var createdAt: Date
    var updatedAt: Date
    var messages: [EchoMessage]
    var isHidden: Bool
    var isReported: Bool

    init(
        id: UUID = UUID(),
        postId: UUID,
        authorHash: String,
        participantHash: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        messages: [EchoMessage] = [],
        isHidden: Bool = false,
        isReported: Bool = false
    ) {
        self.id = id
        self.postId = postId
        self.authorHash = authorHash
        self.participantHash = participantHash
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = messages
        self.isHidden = isHidden
        self.isReported = isReported
    }
}

struct EchoMessage: Identifiable, Hashable, Codable {
    var id = UUID()
    var senderHash: String
    var text: String
    var identityMode: EchoIdentityMode
    var senderDisplayName: String?
    var senderAvatarPreset: Int?
    var createdAt: Date
    var isRead: Bool
    var isHidden: Bool
    var isReported: Bool

    init(
        id: UUID = UUID(),
        senderHash: String,
        text: String,
        identityMode: EchoIdentityMode,
        senderDisplayName: String? = nil,
        senderAvatarPreset: Int? = nil,
        createdAt: Date = Date(),
        isRead: Bool = false,
        isHidden: Bool = false,
        isReported: Bool = false
    ) {
        self.id = id
        self.senderHash = senderHash
        self.text = text
        self.identityMode = identityMode
        self.senderDisplayName = senderDisplayName
        self.senderAvatarPreset = senderAvatarPreset
        self.createdAt = createdAt
        self.isRead = isRead
        self.isHidden = isHidden
        self.isReported = isReported
    }
}

enum EchoPublishError: LocalizedError {
    case empty
    case sensitive

    var errorDescription: String? {
        switch self {
        case .empty:
            return "先写一点想被看见的话"
        case .sensitive:
            return "这段话里可能有太私密或太危险的内容，先别放进回声里。"
        }
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
    @Published var echoPosts: [EchoPost] = EchoPost.samples
    @Published var echoThreads: [EchoThread] = []
    @Published var userProfile = UserProfile.randomGuest()

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
        let storedEchoPosts = database.loadEchoPosts()
        if !storedEchoPosts.isEmpty {
            echoPosts = storedEchoPosts
        }
        let storedEchoThreads = database.loadEchoThreads()
        if !storedEchoThreads.isEmpty {
            echoThreads = storedEchoThreads
        }
        if let storedProfile = database.loadUserProfile() {
            userProfile = storedProfile
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

    var visibleEchoPosts: [EchoPost] {
        let selected = Set((todayEntry?.tags ?? selectedMoodTags.map(\.title)).prefix(6))
        return echoPosts
            .filter { !$0.isHidden && !$0.isReported && !isEchoMine($0) }
            .sorted { lhs, rhs in
                let lhsScore = lhs.tags.filter { selected.contains($0) }.count
                let rhsScore = rhs.tags.filter { selected.contains($0) }.count
                if lhsScore != rhsScore {
                    return lhsScore > rhsScore
                }
                return lhs.createdAt > rhs.createdAt
            }
    }

    var myEchoPosts: [EchoPost] {
        echoPosts
            .filter { isEchoMine($0) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var myInteractedEchoPosts: [EchoPost] {
        let participatedPostIds = Set(
            echoThreads
                .filter { !$0.isHidden && !$0.isReported && !$0.messages.isEmpty && $0.participantHash == userProfile.id.uuidString }
                .map(\.postId)
        )
        return echoPosts
            .filter { post in
                !isEchoMine(post)
                    && !post.isHidden
                    && !post.isReported
                    && (!post.myReactions.isEmpty || participatedPostIds.contains(post.id))
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var threadsForMyPosts: [EchoThread] {
        echoThreads
            .filter { !$0.isHidden && !$0.isReported && !$0.messages.isEmpty && $0.authorHash == userProfile.id.uuidString }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var threadsIParticipateIn: [EchoThread] {
        echoThreads
            .filter {
                !$0.isHidden
                    && !$0.isReported
                    && !$0.messages.isEmpty
                    && $0.participantHash == userProfile.id.uuidString
                    && $0.authorHash != userProfile.id.uuidString
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var unreadEchoCount: Int {
        threadsForMyPosts.reduce(0) { count, thread in
            count + thread.messages.filter { !$0.isRead && $0.senderHash != userProfile.id.uuidString }.count
        }
    }

    func isEchoMine(_ post: EchoPost) -> Bool {
        post.isMine || post.authorHash == userProfile.id.uuidString
    }

    func suggestedEchoText(for entry: DailyEntry) -> String {
        entry.supplementalNote.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @discardableResult
    func publishEcho(from entry: DailyEntry, text: String, identityMode: EchoIdentityMode) throws -> EchoPost {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { throw EchoPublishError.empty }
        guard !containsUnsafeEchoContent(cleaned) else { throw EchoPublishError.sensitive }

        let post = EchoPost(
            sourceEntryId: entry.id,
            authorHash: userProfile.id.uuidString,
            text: cleaned,
            tags: entry.tags,
            weatherShort: entry.weatherShort,
            reactionCounts: [
                .sameHere: 0,
                .hug: 0,
                .spoon: 0,
                .slowly: 0,
                .sitTogether: 0
            ],
            identityMode: identityMode,
            authorDisplayName: identityMode == .named ? userProfile.displayName : nil,
            authorAvatarPreset: identityMode == .named ? userProfile.avatarPreset : nil,
            isMine: true
        )

        echoPosts.insert(post, at: 0)
        markEntryPublishedToEcho(entryID: entry.id, post: post)
        database.saveEchoPosts(echoPosts)
        return post
    }

    func react(to postID: UUID, with reaction: EchoReactionType) {
        toggleReaction(on: postID, with: reaction)
    }

    func toggleReaction(on postID: UUID, with reaction: EchoReactionType) {
        guard let index = echoPosts.firstIndex(where: { $0.id == postID }) else { return }
        if echoPosts[index].myReactions.contains(reaction) {
            echoPosts[index].myReactions.remove(reaction)
            echoPosts[index].reactionCounts[reaction] = max(0, (echoPosts[index].reactionCounts[reaction] ?? 0) - 1)
        } else {
            echoPosts[index].myReactions.insert(reaction)
            echoPosts[index].reactionCounts[reaction] = (echoPosts[index].reactionCounts[reaction] ?? 0) + 1
        }
        database.saveEchoPosts(echoPosts)
    }

    @discardableResult
    func startOrOpenThread(postID: UUID) -> EchoThread? {
        guard let post = echoPosts.first(where: { $0.id == postID }) else { return nil }
        let participantHash = isEchoMine(post) ? userProfile.id.uuidString : userProfile.id.uuidString
        let authorHash = post.authorHash
        if let thread = echoThreads.first(where: {
            $0.postId == postID
                && $0.authorHash == authorHash
                && $0.participantHash == participantHash
                && !$0.isHidden
                && !$0.isReported
        }) {
            return thread
        }
        guard !isEchoMine(post) else { return nil }
        let thread = EchoThread(
            postId: postID,
            authorHash: authorHash,
            participantHash: participantHash
        )
        echoThreads.insert(thread, at: 0)
        database.saveEchoThreads(echoThreads)
        return thread
    }

    func sendEchoMessage(threadID: UUID, text: String, identityMode: EchoIdentityMode) throws {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { throw EchoPublishError.empty }
        guard !containsUnsafeEchoContent(cleaned) else { throw EchoPublishError.sensitive }
        guard let index = echoThreads.firstIndex(where: { $0.id == threadID }) else { return }
        let senderHash = userProfile.id.uuidString
        let message = EchoMessage(
            senderHash: senderHash,
            text: cleaned,
            identityMode: identityMode,
            senderDisplayName: identityMode == .named ? userProfile.displayName : nil,
            senderAvatarPreset: identityMode == .named ? userProfile.avatarPreset : nil,
            isRead: senderHash == echoThreads[index].authorHash
        )
        echoThreads[index].messages.append(message)
        echoThreads[index].updatedAt = message.createdAt
        database.saveEchoThreads(echoThreads)
    }

    func visibleThreads(for post: EchoPost) -> [EchoThread] {
        let userHash = userProfile.id.uuidString
        return echoThreads
            .filter { thread in
                thread.postId == post.id
                    && !thread.isHidden
                    && !thread.isReported
                    && (isEchoMine(post) || thread.participantHash == userHash)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func post(for thread: EchoThread) -> EchoPost? {
        echoPosts.first { $0.id == thread.postId }
    }

    func markEchoThreadRead(_ threadID: UUID) {
        guard let index = echoThreads.firstIndex(where: { $0.id == threadID }) else { return }
        let userHash = userProfile.id.uuidString
        var changed = false
        for messageIndex in echoThreads[index].messages.indices where echoThreads[index].messages[messageIndex].senderHash != userHash {
            if !echoThreads[index].messages[messageIndex].isRead {
                echoThreads[index].messages[messageIndex].isRead = true
                changed = true
            }
        }
        if changed {
            database.saveEchoThreads(echoThreads)
        }
    }

    func hideEcho(_ postID: UUID) {
        guard let index = echoPosts.firstIndex(where: { $0.id == postID }) else { return }
        echoPosts[index].isHidden = true
        database.saveEchoPosts(echoPosts)
    }

    func reportEcho(_ postID: UUID) {
        guard let index = echoPosts.firstIndex(where: { $0.id == postID }) else { return }
        echoPosts[index].isReported = true
        database.saveEchoPosts(echoPosts)
    }

    func retractEcho(_ postID: UUID) {
        echoPosts.removeAll { $0.id == postID && $0.isMine }
        echoThreads.removeAll { $0.postId == postID }
        if let todayEntry, todayEntry.echoPostId == postID {
            self.todayEntry?.echoPostId = nil
            self.todayEntry?.echoPublishedAt = nil
            self.todayEntry?.echoSourceText = nil
        }
        for index in entries.indices where entries[index].echoPostId == postID {
            entries[index].echoPostId = nil
            entries[index].echoPublishedAt = nil
            entries[index].echoSourceText = nil
        }
        database.saveEntries(entries)
        database.saveEchoPosts(echoPosts)
        database.saveEchoThreads(echoThreads)
    }

    private func markEntryPublishedToEcho(entryID: UUID, post: EchoPost) {
        if todayEntry?.id == entryID {
            todayEntry?.echoPostId = post.id
            todayEntry?.echoPublishedAt = post.createdAt
            todayEntry?.echoSourceText = post.text
        }
        if let index = entries.firstIndex(where: { $0.id == entryID }) {
            entries[index].echoPostId = post.id
            entries[index].echoPublishedAt = post.createdAt
            entries[index].echoSourceText = post.text
        }
        database.saveEntries(entries)
    }

    private func containsUnsafeEchoContent(_ text: String) -> Bool {
        let normalized = text.lowercased()
        let blockedKeywords = [
            "自杀", "轻生", "不想活", "死了算", "伤害自己", "伤害别人", "杀了",
            "微信", "电话", "手机号", "qq", "地址", "身份证"
        ]
        if blockedKeywords.contains(where: { normalized.contains($0) }) {
            return true
        }
        if normalized.range(of: #"1[3-9]\d{9}"#, options: .regularExpression) != nil {
            return true
        }
        return false
    }

    func login(phoneNumber: String) {
        let cleaned = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        userProfile.phoneNumber = cleaned
        userProfile.isLoggedIn = true
        if userProfile.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            userProfile.displayName = UserProfile.randomName()
        }
        database.saveUserProfile(userProfile)
    }

    func updateProfile(displayName: String, avatarPreset: Int, avatarImageBase64: String?) {
        let cleaned = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        userProfile.displayName = cleaned.isEmpty ? UserProfile.randomName() : cleaned
        userProfile.avatarPreset = avatarPreset
        userProfile.avatarImageBase64 = avatarImageBase64
        database.saveUserProfile(userProfile)
    }

    func randomizeProfile() {
        userProfile.displayName = UserProfile.randomName()
        userProfile.avatarPreset = Int.random(in: 0..<UserProfile.avatarPalette.count)
        userProfile.avatarImageBase64 = nil
        database.saveUserProfile(userProfile)
    }

    func randomizeAvatar() {
        userProfile.avatarPreset = Int.random(in: 0..<UserProfile.avatarPalette.count)
        userProfile.avatarImageBase64 = nil
        database.saveUserProfile(userProfile)
    }

    func randomizeName() {
        userProfile.displayName = UserProfile.randomName()
        database.saveUserProfile(userProfile)
    }

    func logout() {
        userProfile.phoneNumber = nil
        userProfile.isLoggedIn = false
        database.saveUserProfile(userProfile)
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

extension EchoPost {
    static var samples: [EchoPost] {
        let calendar = Calendar.current
        let now = Date()
        return [
            EchoPost(
                authorHash: "sample_a",
                text: "今天只是想安静一点，不想解释也不想被问太多。能把自己照顾到现在，已经很不容易了。",
                tags: ["不想解释", "装正常好累", "不想回消息"],
                weatherShort: "微风有雾",
                createdAt: calendar.date(byAdding: .minute, value: -18, to: now) ?? now,
                reactionCounts: [.sameHere: 6, .hug: 3, .spoon: 2]
            ),
            EchoPost(
                authorHash: "sample_b",
                text: "睡得很碎，醒来以后脑子还是停不下来。先不逼自己恢复满格，今天慢一点也可以。",
                tags: ["睡得很碎", "脑子停不下来", "身体很沉"],
                weatherShort: "天灰蒙蒙的",
                createdAt: calendar.date(byAdding: .hour, value: -4, to: now) ?? now,
                reactionCounts: [.sameHere: 4, .slowly: 5, .sitTogether: 1]
            ),
            EchoPost(
                authorHash: "sample_c",
                text: "外面的声音都很刺耳，连消息提示也像在催我。希望今晚可以把世界调小声一点。",
                tags: ["外面太吵", "什么都很刺耳", "被消息淹没"],
                weatherShort: "无天气",
                createdAt: calendar.date(byAdding: .hour, value: -21, to: now) ?? now,
                reactionCounts: [.hug: 4, .spoon: 4, .sitTogether: 2]
            )
        ]
    }
}
