import Foundation

final class SpoonieDatabase {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = documents.appendingPathComponent("daily_entries.json")
    }

    func loadEntries() -> [DailyEntry] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder.spoonie.decode([DailyEntry].self, from: data)) ?? []
    }

    func saveEntries(_ entries: [DailyEntry]) {
        guard let data = try? JSONEncoder.spoonie.encode(entries) else { return }
        try? data.write(to: fileURL, options: [.atomic])
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
