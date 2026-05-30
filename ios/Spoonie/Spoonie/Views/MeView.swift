import SwiftUI

struct MeView: View {
    @EnvironmentObject private var store: SpoonieStore
    @State private var activeSheet: MeSheet?

    var body: some View {
        ZStack(alignment: .top) {
            Color.spoonieBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    StatusBarShim()

                    header
                        .padding(.top, 8)

                    QuietStatusCard(entries: store.entries)

                    QuietSettingsCard(
                        weatherText: store.weatherStatus.displayText,
                        onWeather: { activeSheet = .weather },
                        onDrawer: { store.selectedTab = .drawer },
                        onSafety: { activeSheet = .safety }
                    )
                }
                .padding(.bottom, 26)
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .weather:
                MeInfoSheet(
                    title: "天气与位置",
                    intro: "天气只用来给今天的声明一点氛围，不会决定你是什么状态。",
                    sections: [
                        MeInfoSection(
                            icon: "location",
                            title: "只需要城市级天气",
                            body: "授权后只用于获取附近城市和基础天气，不保存精确经纬度。"
                        ),
                        MeInfoSection(
                            icon: "cloud",
                            title: "不授权也可以用",
                            body: "拒绝定位时，会进入无天气模式，状态收集和今日声明都不会被拦住。"
                        )
                    ]
                )
                .presentationDetents([.height(330), .medium])
            case .safety:
                MeInfoSheet(
                    title: "安心说明",
                    intro: "这里放一些边界和说明，平时不用反复看。",
                    sections: [
                        MeInfoSection(
                            icon: "lock",
                            title: "隐私",
                            body: "记录优先放在本地；AI 生成只使用声明所需的状态、天气和补充上下文。"
                        ),
                        MeInfoSection(
                            icon: "heart.text.square",
                            title: "AI 边界",
                            body: "今日声明是陪伴式文字，不是医疗建议，也不是心理咨询。"
                        ),
                        MeInfoSection(
                            icon: "cross.case",
                            title: "需要帮助时",
                            body: "如果有伤害自己或他人的想法，请尽快联系身边可信任的人或当地紧急服务。"
                        ),
                        MeInfoSection(
                            icon: "questionmark.circle",
                            title: "关于勺子",
                            body: "勺子是一种能量隐喻。水豚拿着勺子，是想陪你承认：有些日子就是只能慢慢来。"
                        )
                    ]
                )
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            AnimatedCapybara(state: .idleDefault)
                .frame(width: 92, height: 92)
                .background(Color.white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("我的")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.spoonieInk)
                Text("今天也不用很厉害")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spoonieMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private enum MeSheet: Identifiable {
    case weather
    case safety

    var id: String {
        switch self {
        case .weather: return "weather"
        case .safety: return "safety"
        }
    }
}

private struct QuietStatusCard: View {
    let entries: [DailyEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "archivebox")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.spooniePurple)
                    .frame(width: 30, height: 30)
                    .background(Color(red: 0.92, green: 0.90, blue: 0.99))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.spoonieInk)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spoonieMuted)
                }
                Spacer()
            }
        }
        .padding(16)
        .spoonieCard(radius: 18)
        .padding(.horizontal, 16)
    }

    private var title: String {
        if entries.isEmpty {
            return "还没有放进抽屉的日子"
        }
        return "抽屉里已有 \(entries.count) 天"
    }

    private var subtitle: String {
        guard let latest = entries.sorted(by: { $0.date > $1.date }).first else {
            return "等你想放的时候再放"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return "最近放好：\(formatter.string(from: latest.date))"
    }
}

private struct QuietSettingsCard: View {
    let weatherText: String
    let onWeather: () -> Void
    let onDrawer: () -> Void
    let onSafety: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            QuietSettingRow(
                icon: "cloud",
                title: "天气与位置",
                subtitle: weatherText,
                action: onWeather
            )

            Divider().padding(.leading, 56)

            QuietSettingRow(
                icon: "archivebox",
                title: "日子抽屉",
                subtitle: "看看放好的日子",
                action: onDrawer
            )

            Divider().padding(.leading, 56)

            QuietSettingRow(
                icon: "shield",
                title: "安心说明",
                subtitle: "隐私、AI 边界、需要帮助时",
                action: onSafety
            )
        }
        .spoonieCard(radius: 18)
        .padding(.horizontal, 16)
    }
}

private struct QuietSettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.spooniePurple)
                    .frame(width: 28, height: 28)
                    .background(Color(red: 0.92, green: 0.90, blue: 0.99))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.spoonieInk)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.spoonieMuted)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.spoonieMuted.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct MeInfoSheet: View {
    let title: String
    let intro: String
    let sections: [MeInfoSection]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.spoonieInk)
                    Text(intro)
                        .font(.system(size: 13))
                        .lineSpacing(4)
                        .foregroundStyle(Color.spoonieMuted)
                }

                VStack(spacing: 10) {
                    ForEach(sections) { section in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: section.icon)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.spooniePurple)
                                .frame(width: 28, height: 28)
                                .background(Color(red: 0.92, green: 0.90, blue: 0.99))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(section.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.spoonieInk)
                                Text(section.body)
                                    .font(.system(size: 12))
                                    .lineSpacing(4)
                                    .foregroundStyle(Color.spoonieMuted)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.62))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .padding(24)
        }
        .background(Color.spoonieBackground.ignoresSafeArea())
    }
}

private struct MeInfoSection: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let body: String
}
