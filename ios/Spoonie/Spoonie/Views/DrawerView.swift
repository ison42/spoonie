import SwiftUI

struct DrawerView: View {
    @EnvironmentObject private var store: SpoonieStore
    @State private var showCollapsedHeader = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.spoonieBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: DrawerScrollOffsetKey.self, value: proxy.frame(in: .named("drawerScroll")).minY)
                    }
                    .frame(height: 0)

                    VStack(spacing: 16) {
                        header

                        ForEach(store.entries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                DrawerEntryCard(entry: entry)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 11)
                    .padding(.bottom, 24)
                }
                .coordinateSpace(name: "drawerScroll")
                .onPreferenceChange(DrawerScrollOffsetKey.self) { value in
                    withAnimation(.easeInOut(duration: 0.18)) {
                        showCollapsedHeader = value < -116
                    }
                }

                if showCollapsedHeader {
                    collapsedHeader
                }
            }
            .navigationBarBackButtonHidden()
        }
    }

    private var header: some View {
        ZStack(alignment: .topLeading) {
            AssetImage(path: "decor/drawer/days_drawer_header_decor_transparent.png")
                .frame(width: 375, height: 125)
                .offset(y: 88)

            AnimatedCapybara(state: .drawerKeeper)
                .frame(width: 166, height: 166)
                .offset(x: 183, y: 29)

            VStack(alignment: .leading, spacing: 4) {
                Text("日子抽屉")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.spoonieInk)
                Text("每个日子，都是你认真过的证据")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spoonieMuted)
            }
            .padding(.leading, 24)
            .padding(.top, 20)

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .semibold))
                Text("已连续记录 12 天")
                    .font(.system(size: 12))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color.spooniePurple.opacity(0.86))
            .clipShape(Capsule())
            .offset(x: 24, y: 130)
        }
        .frame(height: 196)
    }

    private var collapsedHeader: some View {
        HStack {
            Text("日子抽屉")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.spoonieInk)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .frame(height: 64, alignment: .top)
        .background(.ultraThinMaterial)
        .background(Color.spoonieBackground.opacity(0.86))
    }
}

private struct DrawerScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DrawerEntryCard: View {
    let entry: DailyEntry

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    Text(entry.dateTitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.spoonieInk)
                    WeatherPill(text: entry.weather, compact: true)
                    Spacer()
                }

                HStack(spacing: 6) {
                    ForEach(entry.tags.prefix(3), id: \.self) { tag in
                        MoodChip(title: tag, isSelected: false, small: true)
                    }
                }

                Text(entry.statement)
                    .font(.system(size: 12))
                    .lineSpacing(4)
                    .foregroundStyle(Color(red: 0.29, green: 0.27, blue: 0.40))
                    .frame(width: 204, alignment: .leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let stamp = entry.capybaraState.drawerStamp {
                AssetImage(path: stamp)
                    .frame(width: 129, height: 129)
                    .opacity(0.9)
                    .offset(x: -1, y: 2)
            }
        }
        .frame(height: 129)
        .spoonieCard(radius: 16)
    }
}

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: DailyEntry

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.spoonieBackground.ignoresSafeArea()

                AssetImage(path: "decor/collect/collect_header_square_bg_true_transparent.png")
                    .frame(width: 375, height: 375)
                    .offset(y: 52)
                    .allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color.spoonieInk)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white.opacity(0.72))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(entry.dateTitle)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(Color.spoonieInk)
                                Text("放在抽屉里的这一天")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.spoonieMuted)
                            }
                            Spacer()
                            WeatherPill(text: entry.weatherShort, compact: false)
                                .frame(width: 128)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        AnimatedCapybara(state: entry.capybaraState)
                            .frame(width: 236, height: 236)
                            .padding(.top, 6)

                        DeclarationContentCard(title: "那天的你", entry: entry)
                            .padding(.top, -4)

                        if entry.hasSupplementalContext {
                            SupplementalContextPanel(entry: entry)
                                .frame(width: 341)
                                .padding(.top, 12)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, max(36, geometry.safeAreaInsets.bottom + 28))
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
