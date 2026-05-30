import SwiftUI
import UIKit

struct StatusBarShim: View {
    var body: some View {
        Color.clear.frame(height: 0)
    }
}

struct WeatherPill: View {
    let text: String
    var compact = false
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            content
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }

    private var content: some View {
        HStack(spacing: compact ? 4 : 6) {
            Image(systemName: "cloud")
                .font(.system(size: compact ? 12 : 16, weight: .medium))
            Text(text)
                .font(.system(size: compact ? 10 : 11))
                .lineLimit(1)
        }
        .foregroundStyle(Color.spoonieMuted)
        .padding(.horizontal, compact ? 0 : 10)
        .padding(.vertical, compact ? 0 : 7)
        .background(compact ? Color.clear : Color.white.opacity(0.68))
        .clipShape(Capsule())
    }
}

struct MoodChip: View {
    let title: String
    var isSelected: Bool
    var small = false

    var body: some View {
        HStack(spacing: small ? 0 : 4) {
            Text(title)
                .font(.system(size: small ? 10 : 14, weight: .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            if !small {
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .frame(width: 16, height: 16)
                    .background((isSelected ? Color.white.opacity(0.3) : Color(red: 0.88, green: 0.87, blue: 0.92)).opacity(isSelected ? 1 : 0.75))
                    .clipShape(Circle())
                    .foregroundStyle(isSelected ? .white : Color.spoonieMuted.opacity(0.55))
            }
        }
        .foregroundStyle(isSelected ? .white : (small ? Color.spooniePurpleDeep : Color.spoonieMuted))
        .padding(.horizontal, small ? 7 : 12)
        .padding(.vertical, small ? 5 : 10)
        .background {
            if isSelected {
                LinearGradient(
                    colors: [Color(red: 0.63, green: 0.59, blue: 0.97), Color(red: 0.58, green: 0.52, blue: 0.96)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                Color.white.opacity(small ? 0.0 : 0.72)
            }
        }
        .background(small ? Color(red: 0.91, green: 0.89, blue: 0.98) : Color.clear)
        .clipShape(Capsule())
    }
}

struct StatementChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 14))
            .foregroundStyle(Color.spooniePurpleDeep)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(Color(red: 0.91, green: 0.89, blue: 0.98))
            .clipShape(Capsule())
    }
}

struct PrimaryButton: View {
    let title: String
    var isEnabled = true
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(isLoading ? "正在生成" : title)
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                LinearGradient(
                    colors: isEnabled ? [Color(red: 0.65, green: 0.59, blue: 0.98), Color(red: 0.57, green: 0.51, blue: 0.95)] : [Color.gray.opacity(0.35), Color.gray.opacity(0.28)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
    }
}

struct SpoonieTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(AppTab.allCases) { tab in
                    Button {
                        selection = tab
                    } label: {
                        VStack(spacing: 4) {
                            tabIcon(tab)
                                .font(.system(size: 22, weight: .medium))
                                .frame(height: 28)
                            Text(tab.title)
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(selection == tab ? Color.spooniePurple : Color(red: 0.34, green: 0.34, blue: 0.39))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 51)

            RoundedRectangle(cornerRadius: 2)
                .fill(.black)
                .frame(width: 134, height: 5)
                .padding(.top, 10)
        }
        .frame(height: 83)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.82))
        .clipShape(TopRoundedRectangle(radius: 20))
        .overlay(
            TopRoundedRectangle(radius: 20)
                .stroke(Color.spooniePurple.opacity(0.18), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func tabIcon(_ tab: AppTab) -> some View {
        switch tab {
        case .today:
            Image(systemName: "calendar")
        case .drawer:
            Image(systemName: "archivebox")
        case .me:
            Image(systemName: "face.smiling")
        }
    }
}

struct TopRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
