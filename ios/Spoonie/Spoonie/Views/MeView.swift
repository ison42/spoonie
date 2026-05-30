import SwiftUI

struct MeView: View {
    @EnvironmentObject private var store: SpoonieStore

    var body: some View {
        ZStack(alignment: .top) {
            Color.spoonieBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    StatusBarShim()

                    HStack(alignment: .center, spacing: 16) {
                        AnimatedCapybara(state: .idleDefault)
                            .frame(width: 92, height: 92)
                            .background(Color.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("我的")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(Color.spoonieInk)
                            Text("你来不来都可以，记录会安静放好。")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.spoonieMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    PreferenceCard(title: "今日偏好", rows: [
                        ("cloud", "天气城市", store.currentWeatherContext.shortText),
                        ("text.bubble", "声明语气", "轻一点，慢一点"),
                        ("bell", "提醒", "不催，只在晚上轻轻问")
                    ])

                    PreferenceCard(title: "记录与数据", rows: [
                        ("tray.full", "导出日子抽屉", "本地文件"),
                        ("trash", "删除全部记录", "随时可以清空"),
                        ("lock", "隐私与本地缓存", "只存必要信息")
                    ])

                    PreferenceCard(title: "安全与说明", rows: [
                        ("cross.case", "危机帮助入口", "需要时马上看到"),
                        ("heart.text.square", "AI 非医疗声明", "它不是医生或咨询师"),
                        ("questionmark.circle", "关于勺子", "第一次之外也能回看")
                    ])
                }
                .padding(.bottom, 26)
            }
        }
    }
}

struct PreferenceCard: View {
    let title: String
    let rows: [(String, String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.spoonieInk)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            VStack(spacing: 0) {
                ForEach(rows.indices, id: \.self) { index in
                    let row = rows[index]
                    HStack(spacing: 12) {
                        Image(systemName: row.0)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.spooniePurple)
                            .frame(width: 28, height: 28)
                            .background(Color(red: 0.92, green: 0.90, blue: 0.99))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(row.1)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.spoonieInk)
                            Text(row.2)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.spoonieMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.spoonieMuted.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if index < rows.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
        .spoonieCard(radius: 18)
        .padding(.horizontal, 16)
    }
}
