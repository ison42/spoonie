import SwiftUI

struct MeView: View {
    @EnvironmentObject private var store: SpoonieStore
    @State private var activeSheet: MeSheet?

    var body: some View {
        ZStack(alignment: .top) {
            Color.spoonieBackground.ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ProfileHero(profile: store.userProfile) {
                            activeSheet = store.userProfile.isLoggedIn ? .profile : .login
                        }

                        ProfileSettingsCard(
                            weatherText: store.weatherStatus.displayText,
                            onWeather: { activeSheet = .weather },
                            onAboutSpoon: { activeSheet = .aboutSpoon },
                            onHelp: { activeSheet = .help },
                            onContact: { activeSheet = .contact }
                        )
                        .padding(.top, 4)

                        if store.userProfile.isLoggedIn {
                            Button {
                                store.logout()
                            } label: {
                                Text("退出登录")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.spoonieMuted)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 18)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, -2)
                        }

                        Spacer(minLength: 24)
                    }
                    .frame(width: proxy.size.width)
                    .padding(.bottom, 30)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .login:
                LoginSheet(reason: "登录后可以保存头像昵称，也可以发回声和轻轻回应别人。")
                    .environmentObject(store)
                    .presentationDetents([.height(560), .large])
            case .profile:
                ProfileEditSheet()
                    .environmentObject(store)
                    .presentationDetents([.height(380), .medium])
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
            case .aboutSpoon:
                MeInfoSheet(
                    title: "关于勺子",
                    intro: "勺子在这里不是工具，是一点点能量的隐喻。",
                    sections: [
                        MeInfoSection(
                            icon: "heart",
                            title: "为什么是勺子",
                            body: "有些日子不是不努力，而是手里的力气真的有限。勺子代表今天还能慢慢使用的一点点能量。"
                        ),
                        MeInfoSection(
                            icon: "pawprint",
                            title: "为什么是水豚",
                            body: "水豚拿着木勺，是这个 App 的陪伴 IP。它不催你变好，只陪你把今天先放稳。"
                        )
                    ]
                )
                .presentationDetents([.height(390), .medium])
            case .help:
                MeInfoSheet(
                    title: "需要帮助时",
                    intro: "今日声明是陪伴式文字，不替代医疗建议或心理咨询。",
                    sections: [
                        MeInfoSection(
                            icon: "person.2",
                            title: "先找一个真实的人",
                            body: "如果今天很难撑住，优先联系身边可信任的人，让对方知道你现在需要陪伴。"
                        ),
                        MeInfoSection(
                            icon: "cross.case",
                            title: "出现危险想法时",
                            body: "如果有伤害自己或他人的想法，请尽快联系当地紧急服务，或前往附近医院急诊。"
                        )
                    ]
                )
                .presentationDetents([.height(390), .medium])
            case .contact:
                MeInfoSheet(
                    title: "联系我",
                    intro: "这里会放正式版的反馈入口。现在先把它留成一个很轻的位置。",
                    sections: [
                        MeInfoSection(
                            icon: "bubble.left.and.text.bubble.right",
                            title: "体验反馈",
                            body: "如果你觉得哪里不舒服、哪里被接住了，后续可以从这里发给我们。"
                        ),
                        MeInfoSection(
                            icon: "sparkles",
                            title: "一起打磨",
                            body: "勺子星人会优先把反馈变成更低压力、更好理解的体验。"
                        )
                    ]
                )
                .presentationDetents([.height(340), .medium])
            }
        }
    }
}

private enum MeSheet: Identifiable {
    case login
    case profile
    case weather
    case aboutSpoon
    case help
    case contact

    var id: String {
        switch self {
        case .login: return "login"
        case .profile: return "profile"
        case .weather: return "weather"
        case .aboutSpoon: return "aboutSpoon"
        case .help: return "help"
        case .contact: return "contact"
        }
    }
}

private struct ProfileHero: View {
    let profile: UserProfile
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                AssetImage(path: "decor/profile/profile_header_curved_v1.png", contentMode: .fit)
                    .frame(height: 356)
                    .frame(maxWidth: .infinity)

                Button(action: onEdit) {
                    UserAvatar(
                        preset: profile.avatarPreset,
                        imageBase64: profile.avatarImageBase64,
                        size: 96
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: Color.spooniePurple.opacity(0.18), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.top, 260)
            }

            Button(action: onEdit) {
                Text(profile.isLoggedIn ? profile.displayName : "未登录")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Color.spoonieInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 48)
                    .padding(.top, 8)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ProfileSettingsCard: View {
    let weatherText: String
    let onWeather: () -> Void
    let onAboutSpoon: () -> Void
    let onHelp: () -> Void
    let onContact: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileSettingRow(
                icon: "cloud",
                title: "天气与位置",
                action: onWeather
            )

            Divider().padding(.leading, 82)

            ProfileSettingRow(
                icon: "star.circle",
                title: "关于勺子",
                action: onAboutSpoon
            )

            Divider().padding(.leading, 82)

            ProfileSettingRow(
                icon: "heart.text.square",
                title: "需要帮助时",
                action: onHelp
            )

            Divider().padding(.leading, 82)

            ProfileSettingRow(
                icon: "envelope",
                title: "联系我",
                action: onContact
            )
        }
        .frame(maxWidth: .infinity)
        .spoonieCard(radius: 24)
        .padding(.horizontal, 24)
    }
}

private struct ProfileSettingRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.spooniePurple)
                    .frame(width: 48, height: 48)
                    .background(Color(red: 0.92, green: 0.90, blue: 0.99))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(title)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Color.spoonieInk)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.spoonieMuted.opacity(0.56))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 17)
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
