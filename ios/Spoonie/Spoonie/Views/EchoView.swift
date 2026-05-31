import SwiftUI

struct EchoView: View {
    @EnvironmentObject private var store: SpoonieStore
    @State private var showBox = false
    @State private var showLogin = false
    @State private var activeThread: ActiveEchoThread?

    var body: some View {
        ZStack(alignment: .top) {
            EchoPoolBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    StatusBarShim()

                    EchoHeader(unreadCount: store.unreadEchoCount) {
                        if store.userProfile.isLoggedIn {
                            showBox = true
                        } else {
                            showLogin = true
                        }
                    }
                    .padding(.top, 18)

                    if store.visibleEchoPosts.isEmpty {
                        EchoEmptyState()
                    } else {
                        ForEach(Array(store.visibleEchoPosts.enumerated()), id: \.element.id) { index, post in
                            EchoPostCard(
                                post: post,
                                variant: EchoCardVariant.allCases[index % EchoCardVariant.allCases.count],
                                onReply: { openThread(for: post) }
                            )
                            .rotationEffect(.degrees(index.isMultiple(of: 2) ? -0.5 : 0.45))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showBox) {
            MyEchoBoxSheet()
                .environmentObject(store)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showLogin) {
            LoginSheet(reason: "登录后才能回应、留一句和查看你的回声匣。你仍然可以选择匿名出现。")
                .environmentObject(store)
                .presentationDetents([.height(560), .large])
        }
        .sheet(item: $activeThread) { thread in
            EchoThreadSheet(threadID: thread.id)
                .environmentObject(store)
                .presentationDetents([.large])
        }
    }

    private func openThread(for post: EchoPost) {
        guard store.userProfile.isLoggedIn else {
            showLogin = true
            return
        }
        if let thread = store.startOrOpenThread(postID: post.id) {
            activeThread = ActiveEchoThread(id: thread.id)
        }
    }
}

private struct ActiveEchoThread: Identifiable {
    let id: UUID
}

private struct EchoHeader: View {
    let unreadCount: Int
    let onBox: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("回声")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(Color.spoonieInk)
                    Text("相似的日子，会轻轻碰到一起")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.spoonieMuted)
                }

                Spacer()

                Button(action: onBox) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "tray.and.arrow.down")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.spooniePurple)
                            .frame(width: 46, height: 46)
                            .background(.white.opacity(0.76))
                            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                            .shadow(color: Color.spooniePurple.opacity(0.12), radius: 10, x: 0, y: 5)

                        if unreadCount > 0 {
                            Text(unreadCount > 9 ? "9+" : "\(unreadCount)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(minWidth: 17, minHeight: 17)
                                .background(Color.spooniePurple)
                                .clipShape(Capsule())
                                .offset(x: 5, y: -4)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                Image(systemName: "water.waves")
                    .font(.system(size: 12, weight: .semibold))
                Text("只看得到公开计数，文字回复只在彼此之间")
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(Color.spooniePurpleDeep.opacity(0.72))
            .padding(.horizontal, 11)
            .frame(height: 30)
            .background(Color.white.opacity(0.58))
            .clipShape(Capsule())
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.78),
                            Color(red: 0.91, green: 0.90, blue: 1.0).opacity(0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        )
    }
}

private struct EchoPoolBackground: View {
    var body: some View {
        ZStack {
            Color.spoonieBackground.ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.80, green: 0.83, blue: 1.0).opacity(0.24))
                .frame(width: 210, height: 210)
                .blur(radius: 10)
                .offset(x: 120, y: 110)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.38))
                .frame(width: 118, height: 58)
                .rotationEffect(.degrees(-8))
                .offset(x: -128, y: 228)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.93, green: 0.86, blue: 1.0).opacity(0.38))
                .frame(width: 156, height: 72)
                .rotationEffect(.degrees(8))
                .offset(x: 132, y: 370)

            Circle()
                .stroke(Color.white.opacity(0.28), lineWidth: 1)
                .frame(width: 270, height: 270)
                .offset(x: 0, y: 320)
        }
        .allowsHitTesting(false)
    }
}

private enum EchoCardVariant: CaseIterable {
    case lavender
    case blue
    case pink
    case warm

    var fill: LinearGradient {
        switch self {
        case .lavender:
            return LinearGradient(colors: [Color.white.opacity(0.86), Color(red: 0.93, green: 0.91, blue: 1.0).opacity(0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .blue:
            return LinearGradient(colors: [Color.white.opacity(0.88), Color(red: 0.88, green: 0.94, blue: 1.0).opacity(0.76)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pink:
            return LinearGradient(colors: [Color.white.opacity(0.9), Color(red: 1.0, green: 0.91, blue: 0.96).opacity(0.70)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .warm:
            return LinearGradient(colors: [Color.white.opacity(0.9), Color(red: 1.0, green: 0.95, blue: 0.84).opacity(0.64)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

private struct EchoPostCard: View {
    @EnvironmentObject private var store: SpoonieStore
    let post: EchoPost
    let variant: EchoCardVariant
    let onReply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader

            Text(post.text)
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 0.25, green: 0.24, blue: 0.38))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            ChipFlowLayout(horizontalSpacing: 7, verticalSpacing: 7) {
                ForEach(post.tags.prefix(4), id: \.self) { tag in
                    StatementChip(title: tag)
                }
            }

            if store.isEchoMine(post) {
                EchoReactionSummary(post: post)
                EchoOwnerThreadPreview(post: post)
            } else {
                EchoReactionTotalLine(total: post.visibleReactionTotal)
                HStack(alignment: .top, spacing: 8) {
                    EchoReactionRow(post: post)
                    Button(action: onReply) {
                        Label("留一句", systemImage: "bubble.left")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.spooniePurpleDeep.opacity(0.78))
                            .padding(.horizontal, 11)
                            .frame(height: 34)
                            .background(Color.white.opacity(0.62))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(variant.fill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.92), lineWidth: 1)
        )
        .shadow(color: Color.spooniePurple.opacity(0.14), radius: 13, x: 0, y: 7)
    }

    private var cardHeader: some View {
        HStack(alignment: .top, spacing: 10) {
            if post.identityMode == .named, let preset = post.authorAvatarPreset {
                UserAvatar(preset: preset, size: 34)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(authorTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.spoonieInk)
                HStack(spacing: 6) {
                    Text(post.fuzzyTime)
                    if let weather = post.weatherShort, !weather.isEmpty {
                        Text("·")
                        Text(weather)
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(Color.spoonieMuted)
            }

            Spacer()

            EchoCardMenu(post: post)
        }
    }

    private var authorTitle: String {
        if store.isEchoMine(post) {
            return post.identityMode == .named ? "你用昵称放下的纸条" : "你匿名放下的纸条"
        }
        if post.identityMode == .named, let name = post.authorDisplayName {
            return name
        }
        return "匿名纸条"
    }
}

private struct EchoReactionTotalLine: View {
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "waveform")
                .font(.system(size: 11, weight: .semibold))
            Text("共 \(total) 个回声落下")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(Color.spooniePurpleDeep.opacity(0.72))
    }
}

private struct EchoReactionSummary: View {
    let post: EchoPost

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Image(systemName: "waveform")
                    .font(.system(size: 11, weight: .semibold))
                Text("共 \(post.visibleReactionTotal) 个回声落下")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(Color.spooniePurpleDeep.opacity(0.72))

            ChipFlowLayout(horizontalSpacing: 7, verticalSpacing: 7) {
                ForEach(EchoReactionType.allCases) { reaction in
                    EchoReactionStamp(
                        reaction: reaction,
                        count: post.reactionCounts[reaction] ?? 0,
                        isSelected: post.myReactions.contains(reaction),
                        isInteractive: false,
                        action: {}
                    )
                }
            }
        }
    }
}

private struct EchoReactionRow: View {
    @EnvironmentObject private var store: SpoonieStore
    let post: EchoPost
    @State private var showLogin = false
    @State private var pulse: EchoReactionType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EchoReactionType.allCases) { reaction in
                    EchoReactionStamp(
                        reaction: reaction,
                        count: post.reactionCounts[reaction] ?? 0,
                        isSelected: post.myReactions.contains(reaction),
                        isInteractive: true
                    ) {
                        if store.userProfile.isLoggedIn {
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.72)) {
                                pulse = reaction
                                store.toggleReaction(on: post.id, with: reaction)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                pulse = nil
                            }
                        } else {
                            showLogin = true
                        }
                    }
                    .scaleEffect(pulse == reaction ? 1.08 : 1.0)
                }
            }
            .padding(.vertical, 2)
        }
        .sheet(isPresented: $showLogin) {
            LoginSheet(reason: "回应别人时需要登录。你可以继续匿名回应，不会暴露手机号。")
                .environmentObject(store)
                .presentationDetents([.height(560), .large])
        }
    }
}

private struct EchoReactionStamp: View {
    let reaction: EchoReactionType
    let count: Int
    let isSelected: Bool
    let isInteractive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: reaction.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text("\(reaction.title) \(count)")
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : Color.spooniePurpleDeep.opacity(0.82))
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(
                Capsule()
                    .fill(isSelected ? Color.spooniePurple : Color.white.opacity(isInteractive ? 0.66 : 0.46))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.white.opacity(0.42) : Color.spooniePurple.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.spooniePurple.opacity(0.28) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(!isInteractive)
    }
}

private struct EchoOwnerThreadPreview: View {
    @EnvironmentObject private var store: SpoonieStore
    let post: EchoPost
    @State private var activeThread: ActiveEchoThread?

    var body: some View {
        let threads = store.visibleThreads(for: post)
        VStack(alignment: .leading, spacing: 8) {
            if threads.isEmpty {
                Text("还没有人给这张纸条留一句")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.spoonieMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(Color.white.opacity(0.52))
                    .clipShape(Capsule())
            } else {
                ForEach(threads.prefix(2)) { thread in
                    Button {
                        activeThread = ActiveEchoThread(id: thread.id)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 12, weight: .semibold))
                            Text(thread.messages.last?.text ?? "有人轻轻留了一句")
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(Color.spooniePurpleDeep.opacity(0.82))
                        .padding(.horizontal, 12)
                        .frame(height: 34)
                        .background(Color.white.opacity(0.60))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(item: $activeThread) { thread in
            EchoThreadSheet(threadID: thread.id)
                .environmentObject(store)
                .presentationDetents([.large])
        }
    }
}

private struct EchoCardMenu: View {
    @EnvironmentObject private var store: SpoonieStore
    let post: EchoPost

    var body: some View {
        Menu {
            if store.isEchoMine(post) {
                Button(role: .destructive) {
                    store.retractEcho(post.id)
                } label: {
                    Label("收回这张纸条", systemImage: "trash")
                }
            } else {
                Button {
                    store.hideEcho(post.id)
                } label: {
                    Label("不想看到", systemImage: "eye.slash")
                }
                Button(role: .destructive) {
                    store.reportEcho(post.id)
                } label: {
                    Label("举报", systemImage: "exclamationmark.bubble")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.spoonieMuted)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.62))
                .clipShape(Circle())
        }
    }
}

private struct EchoEmptyState: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "quote.bubble")
                .font(.system(size: 28))
                .foregroundStyle(Color.spooniePurple)
            Text("暂时没有新的回声")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.spoonieInk)
            Text("等有人轻轻放下一张纸条，它会飘到这里。")
                .font(.system(size: 12))
                .foregroundStyle(Color.spoonieMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .spoonieCard(radius: 18)
    }
}

private enum EchoBoxSection: String, CaseIterable, Identifiable {
    case mine
    case interacted
    case received

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mine: return "我发出的"
        case .interacted: return "我回应过"
        case .received: return "收到的"
        }
    }
}

private struct MyEchoBoxSheet: View {
    @EnvironmentObject private var store: SpoonieStore
    @State private var section: EchoBoxSection = .mine
    @State private var activeThread: ActiveEchoThread?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("我的回声匣")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.spoonieInk)
                Text("这里收好你发出的、回应过的和收到的轻对话。")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spoonieMuted)
            }

            Picker("", selection: $section) {
                ForEach(EchoBoxSection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    switch section {
                    case .mine:
                        if store.myEchoPosts.isEmpty {
                            EchoBoxEmpty(text: "还没有发出的纸条")
                        } else {
                            ForEach(Array(store.myEchoPosts.enumerated()), id: \.element.id) { index, post in
                                EchoPostCard(
                                    post: post,
                                    variant: EchoCardVariant.allCases[index % EchoCardVariant.allCases.count],
                                    onReply: {}
                                )
                            }
                        }
                    case .interacted:
                        if store.myInteractedEchoPosts.isEmpty {
                            EchoBoxEmpty(text: "还没有回应过的纸条")
                        } else {
                            ForEach(store.myInteractedEchoPosts) { post in
                                EchoInteractedRow(post: post) { threadID in
                                    activeThread = ActiveEchoThread(id: threadID)
                                }
                            }
                        }
                    case .received:
                        if store.threadsForMyPosts.isEmpty {
                            EchoBoxEmpty(text: "还没有收到文字回复")
                        } else {
                            ForEach(store.threadsForMyPosts) { thread in
                                EchoThreadInboxRow(thread: thread) {
                                    activeThread = ActiveEchoThread(id: thread.id)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .padding(24)
        .background(Color.spoonieBackground.ignoresSafeArea())
        .sheet(item: $activeThread) { thread in
            EchoThreadSheet(threadID: thread.id)
                .environmentObject(store)
                .presentationDetents([.large])
        }
    }
}

private struct EchoBoxEmpty: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.spoonieMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(Color.white.opacity(0.60))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct EchoInteractedRow: View {
    @EnvironmentObject private var store: SpoonieStore
    let post: EchoPost
    let openThread: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.text)
                .font(.system(size: 14))
                .lineSpacing(4)
                .foregroundStyle(Color.spoonieInk)
                .lineLimit(3)

            EchoReactionSummary(post: post)

            ForEach(store.visibleThreads(for: post)) { thread in
                Button {
                    openThread(thread.id)
                } label: {
                    EchoThreadPreviewLine(thread: thread)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct EchoThreadInboxRow: View {
    @EnvironmentObject private var store: SpoonieStore
    let thread: EchoThread
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 9) {
                if let post = store.post(for: thread) {
                    Text(post.text)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.spoonieMuted)
                        .lineLimit(2)
                }
                EchoThreadPreviewLine(thread: thread)
            }
            .padding(16)
            .background(Color.white.opacity(0.74))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct EchoThreadPreviewLine: View {
    @EnvironmentObject private var store: SpoonieStore
    let thread: EchoThread

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.spooniePurple)
            Text(thread.messages.last?.text ?? "打开这条轻对话")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.spoonieInk)
                .lineLimit(1)
            Spacer()
            if thread.messages.contains(where: { !$0.isRead && $0.senderHash != store.userProfile.id.uuidString }) {
                Circle()
                    .fill(Color.spooniePurple)
                    .frame(width: 8, height: 8)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.spoonieMuted.opacity(0.72))
        }
    }
}

private struct EchoThreadSheet: View {
    @EnvironmentObject private var store: SpoonieStore
    let threadID: UUID
    @State private var text = ""
    @State private var isFocused = false
    @State private var identityMode: EchoIdentityMode = .anonymous
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("轻轻留一句")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.spoonieInk)
                Text("这段对话只在你和纸条主人之间。")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.spoonieMuted)
            }

            if let post {
                Text(post.text)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.spoonieMuted)
                    .lineSpacing(4)
                    .lineLimit(3)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.58))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(thread?.messages.filter { !$0.isHidden && !$0.isReported } ?? []) { message in
                            EchoMessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 270)
                .onChange(of: thread?.messages.count ?? 0) { _, _ in
                    if let last = thread?.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            EchoReplyIdentityPicker(selection: $identityMode)
                .environmentObject(store)

            ZStack(alignment: .topLeading) {
                MultilineNoteEditor(
                    text: $text,
                    isFocused: $isFocused,
                    textColor: UIColor(Color.spoonieInk),
                    font: .systemFont(ofSize: 15),
                    inset: UIEdgeInsets(top: 13, left: 12, bottom: 13, right: 12)
                )
                .frame(height: 104)
                .background(Color.white.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.spooniePurple.opacity(0.14), lineWidth: 1)
                )

                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("写一句想轻轻递过去的话。")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spoonieMuted.opacity(0.62))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.70, green: 0.32, blue: 0.40))
            }

            PrimaryButton(title: "送过去", isEnabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                send()
            }
        }
        .padding(24)
        .background(Color.spoonieBackground.ignoresSafeArea())
        .onAppear {
            store.markEchoThreadRead(threadID)
        }
    }

    private var thread: EchoThread? {
        store.echoThreads.first { $0.id == threadID }
    }

    private var post: EchoPost? {
        thread.flatMap { store.post(for: $0) }
    }

    private func send() {
        do {
            try store.sendEchoMessage(threadID: threadID, text: text, identityMode: identityMode)
            text = ""
            isFocused = false
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "这句话暂时没送过去。"
        }
    }
}

private struct EchoMessageBubble: View {
    @EnvironmentObject private var store: SpoonieStore
    let message: EchoMessage

    var body: some View {
        let isMine = message.senderHash == store.userProfile.id.uuidString
        HStack {
            if isMine { Spacer(minLength: 42) }
            VStack(alignment: isMine ? .trailing : .leading, spacing: 5) {
                Text(senderTitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.spoonieMuted)
                Text(message.text)
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .foregroundStyle(isMine ? .white : Color.spoonieInk)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(isMine ? Color.spooniePurple : Color.white.opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            if !isMine { Spacer(minLength: 42) }
        }
    }

    private var senderTitle: String {
        if message.senderHash == store.userProfile.id.uuidString {
            return "你"
        }
        if message.identityMode == .named, let name = message.senderDisplayName {
            return name
        }
        return "匿名回声"
    }
}

private struct EchoReplyIdentityPicker: View {
    @EnvironmentObject private var store: SpoonieStore
    @Binding var selection: EchoIdentityMode

    var body: some View {
        HStack(spacing: 8) {
            ForEach(EchoIdentityMode.allCases) { mode in
                Button {
                    selection = mode
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: mode == .anonymous ? "eye.slash" : "person.crop.circle")
                            .font(.system(size: 12, weight: .semibold))
                        Text(mode == .named ? store.userProfile.displayName : "匿名")
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(selection == mode ? .white : Color.spooniePurpleDeep)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(selection == mode ? Color.spooniePurple : Color.white.opacity(0.62))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
