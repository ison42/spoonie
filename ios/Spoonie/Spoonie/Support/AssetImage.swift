import SwiftUI
import UIKit

enum AppAsset {
    static func url(_ relativePath: String) -> URL {
        Bundle.main.bundleURL
            .appendingPathComponent("AppAssets")
            .appendingPathComponent(relativePath)
    }

    static func image(_ relativePath: String) -> UIImage? {
        UIImage(contentsOfFile: url(relativePath).path)
    }
}

struct AssetImage: View {
    let path: String
    var contentMode: ContentMode = .fit

    var body: some View {
        if let image = AppAsset.image(path) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            Color.clear
        }
    }
}

struct AnimatedCapybara: View {
    let state: CapybaraState
    var frameCount: Int = 16
    var frameInterval: TimeInterval = 0.16

    var body: some View {
        TimelineView(.periodic(from: .now, by: frameInterval)) { context in
            let tick = Int(context.date.timeIntervalSinceReferenceDate / frameInterval)
            let index = abs(tick) % frameCount
            AssetImage(path: "\(state.frameDirectory)/frame_\(String(format: "%02d", index)).png")
        }
    }
}

extension Color {
    static let spoonieBackground = Color(red: 0.95, green: 0.94, blue: 1.0)
    static let spooniePurple = Color(red: 0.59, green: 0.53, blue: 0.96)
    static let spooniePurpleDeep = Color(red: 0.24, green: 0.25, blue: 0.61)
    static let spoonieInk = Color(red: 0.12, green: 0.12, blue: 0.28)
    static let spoonieMuted = Color(red: 0.46, green: 0.46, blue: 0.59)
    static let spoonieCard = Color(red: 0.98, green: 0.97, blue: 0.99)
}

extension View {
    func spoonieCard(radius: CGFloat = 16) -> some View {
        self
            .background(Color.spoonieCard)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(.white, lineWidth: 1)
            )
            .shadow(color: Color.spooniePurple.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
