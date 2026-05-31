import Foundation

final class SpoonieDatabase {
    private let entriesURL: URL
    private let echoPostsURL: URL
    private let echoThreadsURL: URL
    private let userProfileURL: URL

    init(fileManager: FileManager = .default) {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.entriesURL = documents.appendingPathComponent("daily_entries.json")
        self.echoPostsURL = documents.appendingPathComponent("echo_posts.json")
        self.echoThreadsURL = documents.appendingPathComponent("echo_threads.json")
        self.userProfileURL = documents.appendingPathComponent("user_profile.json")
    }

    func loadEntries() -> [DailyEntry] {
        guard let data = try? Data(contentsOf: entriesURL) else { return [] }
        return (try? JSONDecoder.spoonie.decode([DailyEntry].self, from: data)) ?? []
    }

    func saveEntries(_ entries: [DailyEntry]) {
        guard let data = try? JSONEncoder.spoonie.encode(entries) else { return }
        try? data.write(to: entriesURL, options: [.atomic])
    }

    func loadEchoPosts() -> [EchoPost] {
        guard let data = try? Data(contentsOf: echoPostsURL) else { return [] }
        return (try? JSONDecoder.spoonie.decode([EchoPost].self, from: data)) ?? []
    }

    func saveEchoPosts(_ posts: [EchoPost]) {
        guard let data = try? JSONEncoder.spoonie.encode(posts) else { return }
        try? data.write(to: echoPostsURL, options: [.atomic])
    }

    func loadEchoThreads() -> [EchoThread] {
        guard let data = try? Data(contentsOf: echoThreadsURL) else { return [] }
        return (try? JSONDecoder.spoonie.decode([EchoThread].self, from: data)) ?? []
    }

    func saveEchoThreads(_ threads: [EchoThread]) {
        guard let data = try? JSONEncoder.spoonie.encode(threads) else { return }
        try? data.write(to: echoThreadsURL, options: [.atomic])
    }

    func loadUserProfile() -> UserProfile? {
        guard let data = try? Data(contentsOf: userProfileURL) else { return nil }
        return try? JSONDecoder.spoonie.decode(UserProfile.self, from: data)
    }

    func saveUserProfile(_ profile: UserProfile) {
        guard let data = try? JSONEncoder.spoonie.encode(profile) else { return }
        try? data.write(to: userProfileURL, options: [.atomic])
    }
}

private extension JSONEncoder {
    static var spoonie: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var spoonie: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
