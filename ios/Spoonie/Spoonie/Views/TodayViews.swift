import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var store: SpoonieStore
    @AppStorage("tagCloudVariant") private var tagCloudVariant = "ribbon"
    @State private var isShowingCustomInput = false
    @State private var customText = ""

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 375, 1.12)
            let topInset = geometry.safeAreaInsets.top
            ZStack(alignment: .top) {
                Color.spoonieBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    StatusBarShim()
                    topWeather
                    Spacer(minLength: 0)
                }

                AssetImage(path: "decor/collect/collect_header_square_bg_true_transparent.png")
                    .frame(width: 360 * scale, height: 360 * scale)
                    .offset(y: max(-22, topInset - 50))
                    .allowsHitTesting(false)

                AnimatedCapybara(state: .idleDefault)
                    .frame(width: 206 * scale, height: 206 * scale)
                    .offset(y: max(34, topInset - 10))
                    .animation(.easeInOut(duration: 0.25), value: store.primaryCapybaraState)

                VStack(spacing: 8) {
                    Text("今天的你还好吗？")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.spoonieInk)
                    Text("选选几个词，看看今天的你")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spoonieMuted)
                }
                .frame(width: 375)
                .offset(y: max(264, topInset + 210))

                TagCloudExperimentView(variant: tagCloudVariant, tags: store.moodTags) {
                    customText = ""
                    isShowingCustomInput = true
                }
                    .environmentObject(store)
                    .frame(width: 375, height: 324)
                    .offset(y: max(346, topInset + 296))

                VStack(spacing: 12) {
                    if case .failed(let message) = store.generationStatus {
                        Text(message)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.spooniePurpleDeep)
                    }

                    PrimaryButton(
                        title: "生成今日声明",
                        isEnabled: !store.selectedTags.isEmpty,
                        isLoading: store.generationStatus == .loading
                    ) {
                        Task { await store.generateTodayDeclaration() }
                    }
                    .frame(width: 316)
                }
                .frame(width: 375)
                .offset(y: max(652, topInset + 592))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $isShowingCustomInput) {
                CustomTagSheet(text: $customText) {
                    store.addCustomTag(customText)
                    isShowingCustomInput = false
                }
                .presentationDetents([.height(238)])
            }
        }
    }

    private var topWeather: some View {
        HStack {
            WeatherPill(text: store.weatherStatus.displayText) {
                Task { await store.requestWeatherPermissionAndLoad() }
            }
            Spacer()
        }
        .padding(.horizontal, 22)
        .frame(height: 44)
    }
}

struct TagCloudExperimentView: View {
    let variant: String
    let tags: [MoodTag]
    let onCustom: () -> Void

    var body: some View {
        if variant == "ribbon" {
            RibbonTagCloudView(tags: tags, onCustom: onCustom)
        } else {
            TagNebulaView(tags: tags, onCustom: onCustom)
        }
    }
}

private struct TagCloudItem: Identifiable {
    let id: String
    let title: String
    let rotation: Double
    let width: CGFloat
    let tag: MoodTag?
    let isCustom: Bool
}

private func makeTagCloudItems(from tags: [MoodTag]) -> [TagCloudItem] {
    let source = Array(tags.prefix(25))
    let spotlightTitles = ["不想回消息", "睡得很碎", "胸口闷", "觉得委屈", "天气闷闷的"]
    var orderedTags: [MoodTag] = []
    var usedTitles = Set<String>()

    func append(_ candidates: [MoodTag]) {
        for tag in candidates where !usedTitles.contains(tag.title) {
            orderedTags.append(tag)
            usedTitles.insert(tag.title)
        }
    }

    append(spotlightTitles.compactMap { title in source.first { $0.title == title } })
    append(source)

    var result = orderedTags.map { tag in
        TagCloudItem(
            id: tag.id.uuidString,
            title: tag.title,
            rotation: tag.rotation,
            width: tag.width,
            tag: tag,
            isCustom: false
        )
    }
    let custom = TagCloudItem(
        id: "custom-entry",
        title: "写点其他",
        rotation: -1,
        width: 104,
        tag: nil,
        isCustom: true
    )
    result.append(custom)
    return result
}

struct RibbonTagCloudView: View {
    @EnvironmentObject private var store: SpoonieStore
    let tags: [MoodTag]
    let onCustom: () -> Void

    private let rowYs: [CGFloat] = [72, 156, 240]
    private let columnWidth: CGFloat = 176

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                    let position = ribbonPosition(for: index)
                    let depth = ribbonDepth(for: index)
                    let selected = item.tag.map { store.selectedTags.contains($0.title) } ?? false

                    RibbonTagButton(
                        item: item,
                        index: index,
                        depth: depth,
                        isSelected: selected,
                        isCustom: item.isCustom,
                        action: {
                            if item.isCustom {
                                onCustom()
                            } else if let tag = item.tag {
                                store.toggle(tag)
                            }
                        }
                    )
                    .position(position)
                    .zIndex(selected ? 20 : Double(10 - row(for: index)))
                }
            }
            .frame(width: contentWidth, height: 306)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.08),
                    .init(color: .black, location: 0.92),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    private var displayItems: [TagCloudItem] {
        makeTagCloudItems(from: tags)
    }

    private var contentWidth: CGFloat {
        CGFloat(max(1, Int(ceil(Double(displayItems.count) / 3.0)))) * columnWidth + 132
    }

    private func row(for index: Int) -> Int {
        index % 3
    }

    private func ribbonPosition(for index: Int) -> CGPoint {
        let row = row(for: index)
        let column = index / 3
        let rowOffset: CGFloat = [0, 76, 28][row]
        let smallDrift = CGFloat((index % 4) - 1) * 5
        return CGPoint(
            x: 88 + CGFloat(column) * columnWidth + rowOffset,
            y: rowYs[row] + smallDrift
        )
    }

    private func ribbonDepth(for index: Int) -> CGFloat {
        switch row(for: index) {
        case 0: return 0.80
        case 1: return 0.92
        default: return 0.84
        }
    }
}

private struct RibbonTagButton: View {
    let item: TagCloudItem
    let index: Int
    let depth: CGFloat
    let isSelected: Bool
    let isCustom: Bool
    let action: () -> Void
    @State private var isBreathing = false

    var body: some View {
        Button(action: action) {
            NebulaTagChip(
                title: item.title,
                isSelected: isSelected,
                isCustom: isCustom,
                depth: depth
            )
            .frame(width: min(item.width + 36, item.isCustom ? 136 : 178))
        }
        .buttonStyle(.plain)
        .scaleEffect((isSelected ? 1.035 : 1) * (isBreathing ? 1 + breathAmount : 1 - breathAmount * 0.35))
        .offset(y: isBreathing ? -breathLift : breathLift * 0.35)
        .rotationEffect(.degrees(rotation))
        .shadow(
            color: Color.spooniePurple.opacity(isSelected ? 0.24 : 0.10),
            radius: isSelected ? 12 : 7,
            x: 0,
            y: isSelected ? 7 : 4
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.16), value: isSelected)
        .animation(
            .easeInOut(duration: 2.35 + Double(index % 4) * 0.28)
                .repeatForever(autoreverses: true)
                .delay(Double(index % 5) * 0.08),
            value: isBreathing
        )
        .onAppear { isBreathing = true }
    }

    private var rotation: Double {
        let stableTilt = Double((index % 5) - 2) * 0.8
        let breathingTilt = isBreathing ? Double((index % 3) - 1) * 0.34 : 0
        return item.rotation * 0.38 + stableTilt + breathingTilt
    }

    private var breathAmount: CGFloat {
        0.012 + CGFloat(index % 3) * 0.003
    }

    private var breathLift: CGFloat {
        1.6 + CGFloat(index % 3) * 0.7
    }
}

struct TagNebulaView: View {
    @EnvironmentObject private var store: SpoonieStore
    let tags: [MoodTag]
    let onCustom: () -> Void
    @State private var camera = CGSize(width: 0, height: 0)
    @State private var dragStart = CGSize(width: 0, height: 0)
    @State private var floatPhase = false
    private let fieldWidth: CGFloat = 1_140
    private let fieldHeight: CGFloat = 610

    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            ZStack {
                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                    let placement = placement(for: index)
                    let point = projectedPoint(placement: placement, center: center, index: index)
                    let depth = depthValue(placement: placement, point: point, center: center)

                    NebulaTagChip(
                        title: item.title,
                        isSelected: item.tag.map { store.selectedTags.contains($0.title) } ?? false,
                        isCustom: item.isCustom,
                        depth: depth
                    )
                    .frame(width: min(item.width + 32 + depth * 14, item.isCustom ? 132 : 174))
                    .position(point)
                    .scaleEffect(0.64 + depth * 0.40)
                    .opacity(0.16 + depth * 0.84)
                    .blur(radius: depth < 0.16 ? 0.35 : 0)
                    .rotationEffect(.degrees(item.rotation * (0.16 + depth * 0.52)))
                    .shadow(
                        color: Color.spooniePurple.opacity(depth > 0.62 ? 0.18 : 0.05),
                        radius: depth > 0.62 ? 9 : 3,
                        x: 0,
                        y: depth > 0.62 ? 6 : 2
                    )
                    .zIndex(Double(depth * 1000) + Double(index % 4))
                    .allowsHitTesting(depth > 0.28)
                    .onTapGesture {
                        if item.isCustom {
                            onCustom()
                        } else if let tag = item.tag {
                            store.toggle(tag)
                        }
                    }
                    .animation(.easeInOut(duration: 0.16), value: item.tag.map { store.selectedTags.contains($0.title) } ?? false)
                }

            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 3)
                    .onChanged { value in
                        camera = CGSize(
                            width: dragStart.width + value.translation.width,
                            height: dragStart.height + value.translation.height
                        )
                    }
                    .onEnded { value in
                        dragStart = CGSize(
                            width: dragStart.width + value.predictedEndTranslation.width * 0.42,
                            height: dragStart.height + value.predictedEndTranslation.height * 0.42
                        )
                        withAnimation(.interactiveSpring(response: 0.58, dampingFraction: 0.86)) {
                            camera = dragStart
                        }
                    }
            )
            .mask(
                RadialGradient(
                    colors: [.black, .black.opacity(0.98), .black.opacity(0.72), .clear],
                    center: .center,
                    startRadius: 56,
                    endRadius: 232
                )
            )
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.18),
                        .init(color: .black, location: 0.82),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.12),
                        .init(color: .black, location: 0.88),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true)) {
                    floatPhase = true
                }
            }
        }
    }

    private struct Placement {
        let x: CGFloat
        let y: CGFloat
    }

    private var displayItems: [TagCloudItem] { makeTagCloudItems(from: tags) }

    private func placement(for index: Int) -> Placement {
        let columns = 5
        let xSpacing: CGFloat = 190
        let ySpacing: CGFloat = 88
        let column = index % columns
        let row = index / columns
        let rowOffset: CGFloat = row.isMultiple(of: 2) ? 0 : xSpacing / 2
        let x = (CGFloat(column) - 2) * xSpacing + rowOffset
        let y = (CGFloat(row) - 2.5) * ySpacing
        return Placement(x: x, y: y)
    }

    private func projectedPoint(placement: Placement, center: CGPoint, index: Int) -> CGPoint {
        let drift = floatPhase ? CGFloat((index % 5) - 2) * 1.4 : 0
        let x = center.x + wrapToField(placement.x + camera.width * 0.92 + drift, span: fieldWidth)
        let y = center.y + wrapToField(placement.y + camera.height * 0.86 - drift * 0.3, span: fieldHeight)
        return CGPoint(x: x, y: y)
    }

    private func depthValue(placement: Placement, point: CGPoint, center: CGPoint) -> CGFloat {
        let dx = abs(point.x - center.x) / 430
        let dy = abs(point.y - center.y) / 270
        let normalized = min(1, sqrt(dx * dx + dy * dy))
        let rawDepth = max(0, 1 - normalized * normalized)
        let depth = pow(rawDepth, 1.18)
        return min(1, max(0.06, depth))
    }

    private func wrapToField(_ value: CGFloat, span: CGFloat) -> CGFloat {
        var result = value
        let halfSpan = span / 2
        while result > halfSpan {
            result -= span
        }
        while result < -halfSpan {
            result += span
        }
        return result
    }
}

struct NebulaTagChip: View {
    let title: String
    let isSelected: Bool
    let isCustom: Bool
    let depth: CGFloat

    var body: some View {
        let fill = bubbleFill
        let bubbleHeight = 27 + depth * 14
        let tailHeight = 7 + depth * 4

        ZStack(alignment: .top) {
            SpeechBubbleShape(tailWidth: 12 + depth * 6, tailHeight: tailHeight)
                .fill(fill)

            HStack(spacing: 5) {
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if isCustom {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 9 + depth * 3.5, weight: .semibold))
                        .foregroundStyle(iconForeground)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 7 + depth * 3.5, weight: .bold))
                        .foregroundStyle(iconForeground)
                        .frame(width: 14 + depth * 4, height: 14 + depth * 4)
                        .background(iconBackground)
                        .clipShape(Circle())
                }
            }
            .font(.system(size: 12 + depth * 7, weight: depth > 0.72 ? .semibold : .regular))
            .foregroundStyle(textColor)
            .padding(.leading, 12 + depth * 7)
            .padding(.trailing, 8 + depth * 4)
            .frame(height: bubbleHeight)
        }
        .frame(height: bubbleHeight + tailHeight)
        .contentShape(Capsule())
    }

    private var bubbleFill: Color {
        if isSelected { return Color.spooniePurple }
        return Color.white.opacity(depth > 0.55 ? 0.96 : 0.32 + depth * 0.58)
    }

    private var textColor: Color {
        if isSelected { return .white }
        return Color(red: 0.13, green: 0.27, blue: 0.50).opacity(0.30 + depth * 0.70)
    }

    private var iconForeground: Color {
        if isSelected { return .white }
        return Color.spoonieMuted.opacity(0.38 + depth * 0.28)
    }

    private var iconBackground: Color {
        if isSelected { return Color.white.opacity(0.28) }
        return Color(red: 0.84, green: 0.87, blue: 0.94).opacity(0.34 + depth * 0.24)
    }
}

struct SpeechBubbleShape: Shape {
    let tailWidth: CGFloat
    let tailHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        let bubbleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: max(0, rect.height - tailHeight)
        )
        let radius = bubbleRect.height / 2
        var path = Path()
        path.addRoundedRect(in: bubbleRect, cornerSize: CGSize(width: radius, height: radius))
        path.move(to: CGPoint(x: rect.midX - tailWidth / 2, y: bubbleRect.maxY - 1))
        path.addLine(to: CGPoint(x: rect.midX + tailWidth / 2, y: bubbleRect.maxY - 1))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CustomTagSheet: View {
    @Binding var text: String
    let onSave: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("写点其他")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.spoonieInk)
            Text("一个短短的词就好，写完会放进今天的词云里。")
                .font(.system(size: 13))
                .foregroundStyle(Color.spoonieMuted)
            TextField("比如：不想说话", text: $text)
                .font(.system(size: 17))
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.spoonieBackground)
                .clipShape(Capsule())
                .focused($focused)
                .onSubmit(onSave)
            PrimaryButton(title: "放进今天") {
                onSave()
            }
        }
        .padding(24)
        .onAppear { focused = true }
    }
}

struct GeneratingDeclarationView: View {
    @EnvironmentObject private var store: SpoonieStore

    var body: some View {
        ZStack(alignment: .top) {
            Color.spoonieBackground.ignoresSafeArea()
            AssetImage(path: "decor/collect/collect_header_square_bg_true_transparent.png")
                .frame(width: 375, height: 375)
                .offset(y: 52)
            VStack(spacing: 16) {
                Spacer().frame(height: 142)
                AnimatedCapybara(state: store.primaryCapybaraState == .idleDefault ? .chestTightHug : store.primaryCapybaraState)
                    .frame(width: 236, height: 236)
                ProgressView()
                    .tint(Color.spooniePurple)
                Text("我在把这些词慢慢放成一句话")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.spoonieInk)
                Text(store.currentWeatherContext.shortText)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spoonieMuted)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct DeclarationView: View {
    @EnvironmentObject private var store: SpoonieStore
    let entry: DailyEntry

    var body: some View {
        ZStack(alignment: .top) {
            Color.spoonieBackground.ignoresSafeArea()

            AssetImage(path: "decor/collect/collect_header_square_bg_true_transparent.png")
                .frame(width: 375, height: 375)
                .offset(y: 52)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                StatusBarShim()

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("今日声明")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(Color.spoonieInk)
                        Text(todaySubtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.spoonieMuted)
                    }
                    Spacer()
                    WeatherPill(text: entry.weatherShort, compact: false)
                        .frame(width: 128)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                AnimatedCapybara(state: entry.capybaraState)
                    .frame(width: 243, height: 243)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 16) {
                    Text("今天的你")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spoonieInk.opacity(0.82))

                    HStack(spacing: 12) {
                        ForEach(entry.tags.prefix(3), id: \.self) { tag in
                            StatementChip(title: tag)
                        }
                    }

                    Text(entry.statement)
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(Color(red: 0.30, green: 0.29, blue: 0.40))
                        .lineSpacing(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .background(Color.white.opacity(0.82))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.spooniePurple.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: Color.spooniePurple.opacity(0.18), radius: 4, x: 0, y: 2)
                }
                .padding(EdgeInsets(top: 20, leading: 26, bottom: 24, trailing: 26))
                .frame(width: 341)
                .spoonieCard(radius: 18)
                .padding(.top, -9)

                Button {
                    store.resetToday()
                } label: {
                    Text("换换今天的状态")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spooniePurple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
            }
        }
    }

    private var todaySubtitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: Date()).replacingOccurrences(of: "星期", with: "星期")
    }
}
