import SwiftUI
import PhotosUI
import UIKit

struct CollectionView: View {
    @EnvironmentObject private var store: SpoonieStore
    @AppStorage("tagCloudVariant") private var tagCloudVariant = "ribbon"
    @State private var isShowingCustomInput = false
    @State private var isShowingSupplementalInput = false
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

                    HStack(spacing: 10) {
                        SupplementalActionButton(draft: store.supplementalDraft) {
                            isShowingSupplementalInput = true
                        }
                        .frame(width: 92)

                        PrimaryButton(
                            title: "生成今日声明",
                            isEnabled: !store.selectedTags.isEmpty,
                            isLoading: store.generationStatus == .loading
                        ) {
                            Task { await store.generateTodayDeclaration() }
                        }
                        .frame(width: 214)
                    }
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
            .sheet(isPresented: $isShowingSupplementalInput) {
                SupplementalDraftSheet(draft: $store.supplementalDraft)
                    .presentationDetents([.height(514), .large])
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

private struct SupplementalActionButton: View {
    let draft: SupplementalDraft
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: draft.hasContent ? "text.bubble.fill" : "text.bubble")
                        .font(.system(size: 13, weight: .semibold))
                    Text("说多点")
                        .font(.system(size: 14, weight: .semibold))
                }
                if draft.hasContent {
                    Text(draft.summaryText)
                        .font(.system(size: 9, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundStyle(draft.hasContent ? Color.spooniePurpleDeep : Color.spoonieMuted)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.white.opacity(draft.hasContent ? 0.84 : 0.62))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.spooniePurple.opacity(draft.hasContent ? 0.24 : 0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SupplementalDraftSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var draft: SupplementalDraft
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var isEditorFocused = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("说多点")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.spoonieInk)
                    Text("那些标签放不下的，可以慢慢写在这里。")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spoonieMuted)
                }
                Spacer()
                Button("完成") {
                    dismiss()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.spooniePurple)
            }

            ZStack(alignment: .topLeading) {
                MultilineNoteEditor(
                    text: $draft.note,
                    isFocused: $isEditorFocused,
                    textColor: UIColor(Color.spoonieInk),
                    font: .systemFont(ofSize: 16),
                    inset: UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14)
                )
                .frame(height: 158)
                .background(Color.spoonieBackground.opacity(0.88))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.spooniePurple.opacity(0.12), lineWidth: 1)
                )

                if draft.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("比如：今天卡住的那一下、让你不舒服的场景、或者只是想留给明天的几句话。")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.spoonieMuted.opacity(0.62))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("图片")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.spoonieInk.opacity(0.82))
                    Text("最多4张")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.spoonieMuted)
                    Spacer()
                    PhotosPicker(selection: $pickerItems, maxSelectionCount: 4, matching: .images) {
                        HStack(spacing: 5) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 13, weight: .semibold))
                            Text("上传图片")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(draft.images.count >= 4 ? Color.spoonieMuted.opacity(0.48) : Color.spooniePurple)
                    }
                    .disabled(draft.images.count >= 4)
                }

                if draft.images.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 17))
                        Text("可以放截图、现场照片，或者任何你想给今天留的东西。")
                            .font(.system(size: 12))
                            .lineLimit(2)
                    }
                    .foregroundStyle(Color.spoonieMuted)
                    .padding(.horizontal, 14)
                    .frame(height: 58)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.54))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(draft.images) { attachment in
                                ZStack(alignment: .topTrailing) {
                                    SupplementalThumbnail(attachment: attachment, size: 72)
                                    Button {
                                        draft.images.removeAll { $0.id == attachment.id }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(Color.spoonieInk)
                                            .frame(width: 20, height: 20)
                                            .background(Color.white.opacity(0.88))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                    .offset(x: 6, y: -6)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.trailing, 8)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .background(Color.spoonieBackground.ignoresSafeArea())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                isEditorFocused = true
            }
        }
        .onChange(of: pickerItems) { _, newItems in
            loadImages(newItems)
        }
    }

    private func loadImages(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        Task {
            var additions: [DailyAttachment] = []
            let remainingSlots = max(0, 4 - draft.images.count)
            for item in items.prefix(remainingSlots) {
                guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
                additions.append(DailyAttachment(dataBase64: normalizedImageData(data).base64EncodedString()))
            }
            await MainActor.run {
                draft.images.append(contentsOf: additions)
                pickerItems = []
            }
        }
    }

    private func normalizedImageData(_ data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let maxSide: CGFloat = 1_080
        let largestSide = max(image.size.width, image.size.height)
        guard largestSide > maxSide else {
            return image.jpegData(compressionQuality: 0.74) ?? data
        }
        let scale = maxSide / largestSide
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized.jpegData(compressionQuality: 0.74) ?? data
    }
}

private struct MultilineNoteEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    let textColor: UIColor
    let font: UIFont
    let inset: UIEdgeInsets

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.font = font
        textView.textContainerInset = inset
        textView.textContainer.lineFragmentPadding = 0
        textView.keyboardDismissMode = .interactive
        textView.returnKeyType = .default
        textView.autocorrectionType = .default
        textView.spellCheckingType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.adjustsFontForContentSizeCategory = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.parent = self
        textView.textColor = textColor
        textView.font = font
        textView.textContainerInset = inset

        if textView.markedTextRange == nil, textView.text != text {
            textView.text = text
        }

        if isFocused, !textView.isFirstResponder {
            DispatchQueue.main.async {
                textView.becomeFirstResponder()
            }
        } else if !isFocused, textView.isFirstResponder {
            DispatchQueue.main.async {
                textView.resignFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineNoteEditor

        init(parent: MultilineNoteEditor) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
            parent.text = textView.text
        }

        func textViewDidChange(_ textView: UITextView) {
            guard textView.markedTextRange == nil else { return }
            parent.text = textView.text
        }
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
                } else if isSelected {
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
            .padding(.trailing, isSelected || isCustom ? 8 + depth * 4 : 12 + depth * 7)
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
    @State private var wordsSettled = false
    @State private var textVisible = false
    @State private var pulse = false
    @State private var hintIndex = 0
    @State private var isLongWait = false

    private let hints = [
        "今天不用解释得很完整",
        "我会把它说得轻一点",
        "先把这些感受放稳"
    ]

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 375, 1.12)
            let topInset = geometry.safeAreaInsets.top

            ZStack(alignment: .top) {
                Color.spoonieBackground.ignoresSafeArea()

                AssetImage(path: "decor/collect/collect_header_square_bg_true_transparent.png")
                    .frame(width: 365 * scale, height: 365 * scale)
                    .offset(y: max(26, topInset + 8))
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    StatusBarShim()
                    HStack {
                        WeatherPill(text: store.currentWeatherContext.shortText)
                        Spacer()
                    }
                    .padding(.horizontal, 22)
                    .frame(height: 44)
                    Spacer(minLength: 0)
                }

                VStack(spacing: 0) {
                    Spacer().frame(height: max(92, topInset + 66))

                    ZStack {
                        ForEach(Array(displayTags.enumerated()), id: \.offset) { index, tag in
                            LoadingWordPaper(title: tag, index: index, isSettled: wordsSettled)
                        }

                        AnimatedCapybara(state: loadingCapybaraState)
                            .frame(width: 232 * scale, height: 232 * scale)
                            .scaleEffect(pulse ? 1.012 : 1)
                            .offset(y: 12)
                    }
                    .frame(width: 375, height: 312)

                    VStack(spacing: 12) {
                        Text("我来帮你整理一下今天的心情")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.spoonieInk)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .fill(Color.spooniePurple.opacity(dotOpacity(for: index)))
                                    .frame(width: 6, height: 6)
                                    .scaleEffect(pulse && hintIndex == index ? 1.28 : 1)
                            }
                        }
                        .frame(height: 12)

                        Text(isLongWait ? "还在慢慢整理，别急" : hints[hintIndex])
                            .font(.system(size: 13))
                            .foregroundStyle(Color.spoonieMuted)
                            .multilineTextAlignment(.center)
                            .id(isLongWait ? "long-wait" : "hint-\(hintIndex)")
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    .frame(width: 316)
                    .opacity(textVisible ? 1 : 0)
                    .offset(y: textVisible ? 0 : 8)

                    Spacer(minLength: 18)

                    VStack(spacing: 12) {
                        if isLongWait {
                            Button {
                                store.finishGenerationWithLocalStatement()
                            } label: {
                                Text("直接先看")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 190, height: 42)
                                    .background(Color.spooniePurple)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            store.cancelGeneration()
                        } label: {
                            Text("先不生成了")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.spoonieMuted)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 9)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, max(22, geometry.safeAreaInsets.bottom + 14))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear(perform: startLoadingAnimation)
            .task {
                await runHintTimeline()
            }
        }
    }

    private var displayTags: [String] {
        let tags = store.selectedMoodTags.map(\.title)
        return Array((tags.isEmpty ? ["正在发呆"] : tags).prefix(5))
    }

    private var loadingCapybaraState: CapybaraState {
        .idleDefault
    }

    private func dotOpacity(for index: Int) -> Double {
        pulse && hintIndex == index ? 0.95 : 0.34
    }

    private func startLoadingAnimation() {
        wordsSettled = false
        textVisible = false
        pulse = false
        hintIndex = 0
        isLongWait = false

        withAnimation(.easeInOut(duration: 1.6).delay(0.35)) {
            wordsSettled = true
        }
        withAnimation(.easeInOut(duration: 0.36).delay(0.45)) {
            textVisible = true
        }
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }

    private func runHintTimeline() async {
        for index in 1..<hints.count {
            try? await Task.sleep(nanoseconds: 1_450_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.24)) {
                    hintIndex = index
                }
            }
        }

        try? await Task.sleep(nanoseconds: 2_100_000_000)
        guard !Task.isCancelled else { return }
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.24)) {
                isLongWait = true
            }
        }
    }
}

private struct LoadingWordPaper: View {
    let title: String
    let index: Int
    let isSettled: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.spooniePurpleDeep)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 13)
            .frame(height: 34)
            .background(Color.white.opacity(isSettled ? 0.84 : 0.68))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
            )
            .shadow(color: Color.spooniePurple.opacity(0.12), radius: 8, x: 0, y: 5)
            .rotationEffect(.degrees(isSettled ? settledRotation : startingRotation))
            .offset(isSettled ? settledOffset : startingOffset)
            .opacity(isSettled ? 0.96 : 0.78)
    }

    private var startingOffset: CGSize {
        let points = [
            CGSize(width: -118, height: 116),
            CGSize(width: 92, height: 132),
            CGSize(width: -38, height: 154),
            CGSize(width: 126, height: 78),
            CGSize(width: -128, height: 54)
        ]
        return points[index % points.count]
    }

    private var settledOffset: CGSize {
        let points = [
            CGSize(width: -108, height: -40),
            CGSize(width: 98, height: -32),
            CGSize(width: -82, height: 44),
            CGSize(width: 96, height: 54),
            CGSize(width: 0, height: 92)
        ]
        return points[index % points.count]
    }

    private var startingRotation: Double {
        [-6, 5, -2, 4, -4][index % 5]
    }

    private var settledRotation: Double {
        [-3, 3, -1, 2, 0][index % 5]
    }
}

struct DeclarationView: View {
    @EnvironmentObject private var store: SpoonieStore
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

                        DeclarationContentCard(title: "今天的你", entry: entry)
                            .padding(.top, -9)

                        if entry.hasSupplementalContext {
                            SupplementalContextPanel(entry: entry)
                                .frame(width: 341)
                                .padding(.top, 12)
                        }

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
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, max(36, geometry.safeAreaInsets.bottom + 28))
                }
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

struct DeclarationContentCard: View {
    let title: String
    let entry: DailyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(Color.spoonieInk.opacity(0.82))
                .padding(.horizontal, 24)

            StatementTagFlow(tags: entry.tags)
            .padding(.horizontal, 24)

            StatementBodyCard(text: entry.statement)
                .padding(.horizontal, 2)
        }
        .padding(.top, 20)
        .padding(.bottom, 2)
        .frame(width: 341)
        .spoonieCard(radius: 18)
    }
}

struct StatementTagFlow: View {
    let tags: [String]

    var body: some View {
        ChipFlowLayout(horizontalSpacing: 10, verticalSpacing: 10) {
            ForEach(tags, id: \.self) { tag in
                StatementChip(title: tag)
            }
        }
    }
}

struct ChipFlowLayout: Layout {
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        let rows = rows(in: maxWidth, subviews: subviews)
        let height = rows.reduce(CGFloat.zero) { partial, row in
            partial + row.height
        } + CGFloat(max(0, rows.count - 1)) * verticalSpacing
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rows(in: bounds.width, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + horizontalSpacing
            }
            y += row.height + verticalSpacing
        }
    }

    private func rows(in maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        guard maxWidth > 0 else { return [] }
        var rows: [Row] = []
        var current = Row()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let nextWidth = current.items.isEmpty ? size.width : current.width + horizontalSpacing + size.width

            if nextWidth > maxWidth, !current.items.isEmpty {
                rows.append(current)
                current = Row()
            }

            current.items.append(RowItem(index: index, size: size))
            current.width = current.items.count == 1 ? size.width : current.width + horizontalSpacing + size.width
            current.height = max(current.height, size.height)
        }

        if !current.items.isEmpty {
            rows.append(current)
        }
        return rows
    }

    private struct Row {
        var items: [RowItem] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private struct RowItem {
        let index: Int
        let size: CGSize
    }
}

struct StatementBodyCard: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(Color(red: 0.30, green: 0.29, blue: 0.40))
            .lineSpacing(8)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 22)
            .background(Color.white.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.spooniePurple.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.spooniePurple.opacity(0.18), radius: 4, x: 0, y: 2)
    }
}

struct SupplementalContextPanel: View {
    let entry: DailyEntry
    @State private var isExpanded = false
    @State private var previewAttachment: DailyAttachment?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 13, weight: .medium))
                    Text("多说的那些")
                        .font(.system(size: 14, weight: .medium))
                    Text(summary)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.spoonieMuted)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .foregroundStyle(Color.spooniePurpleDeep)
                .frame(height: 34)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    let trimmedNote = entry.supplementalNote.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedNote.isEmpty {
                        Text(trimmedNote)
                            .font(.system(size: 14))
                            .lineSpacing(5)
                            .foregroundStyle(Color(red: 0.32, green: 0.31, blue: 0.42))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !entry.supplementalImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(entry.supplementalImages) { attachment in
                                    Button {
                                        previewAttachment = attachment
                                    } label: {
                                        SupplementalThumbnail(attachment: attachment, size: 84)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(.top, 10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .spoonieCard(radius: 18)
        .sheet(item: $previewAttachment) { attachment in
            SupplementalImagePreview(attachment: attachment)
        }
    }

    private var summary: String {
        var parts: [String] = []
        if !entry.supplementalNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("文字")
        }
        if !entry.supplementalImages.isEmpty {
            parts.append("\(entry.supplementalImages.count)张图")
        }
        return parts.isEmpty ? "" : parts.joined(separator: " · ")
    }
}

struct SupplementalImagePreview: View {
    @Environment(\.dismiss) private var dismiss
    let attachment: DailyAttachment

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(18)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo")
                        .font(.system(size: 38))
                    Text("图片暂时打不开")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.8))
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
            .padding(.trailing, 18)
        }
    }

    private var uiImage: UIImage? {
        guard let data = attachment.data else { return nil }
        return UIImage(data: data)
    }
}

struct SupplementalThumbnail: View {
    let attachment: DailyAttachment
    let size: CGFloat

    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color.white.opacity(0.62)
                    Image(systemName: "photo")
                        .foregroundStyle(Color.spoonieMuted)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.88), lineWidth: 1)
        )
    }

    private var uiImage: UIImage? {
        guard let data = attachment.data else { return nil }
        return UIImage(data: data)
    }
}
