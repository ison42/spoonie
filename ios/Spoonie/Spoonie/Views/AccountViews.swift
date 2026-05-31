import SwiftUI
import PhotosUI
import UIKit

struct UserAvatar: View {
    let preset: Int
    var imageBase64: String? = nil
    var size: CGFloat = 42

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                let palette = UserProfile.avatarPalette[abs(preset) % UserProfile.avatarPalette.count]
                ZStack {
                    LinearGradient(
                        colors: palette.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: palette.symbol)
                        .font(.system(size: size * 0.42, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.9), lineWidth: 2))
        .shadow(color: Color.spooniePurple.opacity(0.18), radius: 5, x: 0, y: 3)
    }

    private var uiImage: UIImage? {
        guard let imageBase64,
              let data = Data(base64Encoded: imageBase64) else {
            return nil
        }
        return UIImage(data: data)
    }
}

private struct EditableAvatar: View {
    let preset: Int
    let imageBase64: String?
    var size: CGFloat = 54
    let onRandom: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            UserAvatar(preset: preset, imageBase64: imageBase64, size: size)
            Button(action: onRandom) {
                Image(systemName: "shuffle")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.spooniePurple)
                    .frame(width: 21, height: 21)
                    .background(Color.white.opacity(0.94))
                    .clipShape(Circle())
                    .shadow(color: Color.spooniePurple.opacity(0.12), radius: 3, x: 0, y: 1)
            }
            .buttonStyle(.plain)
            .offset(x: 3, y: 3)
        }
    }
}

private struct AvatarPickerButton: View {
    @Binding var pickerItem: PhotosPickerItem?
    let preset: Int
    let imageBase64: String?

    var body: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                UserAvatar(preset: preset, imageBase64: imageBase64, size: 84)
                Image(systemName: "camera.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.spooniePurple)
                    .frame(width: 26, height: 26)
                    .background(Color.white.opacity(0.96))
                    .clipShape(Circle())
                    .shadow(color: Color.spooniePurple.opacity(0.14), radius: 4, x: 0, y: 2)
                    .offset(x: 2, y: 2)
            }
        }
        .buttonStyle(.plain)
    }

}

private func normalizedProfileImageData(_ data: Data) -> Data {
    guard let image = UIImage(data: data) else { return data }
    let maxSide: CGFloat = 512
    let largestSide = max(image.size.width, image.size.height)
    guard largestSide > maxSide else {
        return image.jpegData(compressionQuality: 0.78) ?? data
    }
    let scale = maxSide / largestSide
    let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let resized = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
    return resized.jpegData(compressionQuality: 0.78) ?? data
}

struct LoginSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: SpoonieStore
    let reason: String
    var onSuccess: (() -> Void)?
    @State private var phoneNumber = ""
    @State private var code = ""
    @State private var codeSent = false
    @State private var errorText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("轻轻登录一下")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.spoonieInk)
                Text(reason)
                    .font(.system(size: 13))
                    .lineSpacing(4)
                    .foregroundStyle(Color.spoonieMuted)
            }

            HStack(spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    EditableAvatar(
                        preset: store.userProfile.avatarPreset,
                        imageBase64: store.userProfile.avatarImageBase64,
                        size: 54,
                        onRandom: { store.randomizeAvatar() }
                    )
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(store.userProfile.displayName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.spoonieInk)
                        Button {
                            store.randomizeName()
                        } label: {
                            Image(systemName: "shuffle")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.spooniePurple)
                                .frame(width: 22, height: 22)
                                .background(Color.white.opacity(0.72))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    Text("默认就可以这样用")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.spoonieMuted)
                }

                Spacer()
            }
            .padding(.vertical, 2)

            VStack(spacing: 10) {
                TextField("手机号", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .font(.system(size: 16))
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color.white.opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                HStack(spacing: 10) {
                    TextField("验证码", text: $code)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16))
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(Color.white.opacity(0.72))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Button {
                        codeSent = true
                        code = "1234"
                        errorText = nil
                    } label: {
                        Text(codeSent ? "已发送" : "获取验证码")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.spooniePurple)
                            .frame(width: 96, height: 48)
                            .background(Color.white.opacity(0.72))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("开发版验证码会自动填入 1234。正式版再接短信服务。")
                .font(.system(size: 11))
                .lineSpacing(3)
                .foregroundStyle(Color.spoonieMuted)

            if let errorText {
                Text(errorText)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.70, green: 0.32, blue: 0.40))
            }

            Spacer(minLength: 0)

            PrimaryButton(title: "登录并继续", isEnabled: !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                guard phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count >= 6 else {
                    errorText = "手机号看起来还没填完整"
                    return
                }
                store.login(phoneNumber: phoneNumber)
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    onSuccess?()
                }
            }
        }
        .padding(24)
        .background(Color.spoonieBackground.ignoresSafeArea())
    }
}

struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: SpoonieStore
    @State private var displayName: String = ""
    @State private var avatarPreset: Int = 0
    @State private var avatarImageBase64: String?
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("头像昵称")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.spoonieInk)

            HStack(spacing: 14) {
                AvatarPickerButton(
                    pickerItem: $pickerItem,
                    preset: avatarPreset,
                    imageBase64: avatarImageBase64
                )
                VStack(alignment: .leading, spacing: 8) {
                    TextField("昵称", text: $displayName)
                        .font(.system(size: 17, weight: .medium))
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(Color.white.opacity(0.72))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    Button {
                        displayName = UserProfile.randomName()
                        avatarPreset = Int.random(in: 0..<UserProfile.avatarPalette.count)
                        avatarImageBase64 = nil
                    } label: {
                        Text("随机换一个")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.spooniePurple)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 12) {
                ForEach(UserProfile.avatarPalette.indices, id: \.self) { index in
                    Button {
                        avatarPreset = index
                    } label: {
                        UserAvatar(preset: index, size: 44)
                            .overlay(
                                Circle()
                                    .stroke(avatarPreset == index ? Color.spooniePurple : Color.clear, lineWidth: 3)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)

            PrimaryButton(title: "保存") {
                store.updateProfile(
                    displayName: displayName,
                    avatarPreset: avatarPreset,
                    avatarImageBase64: avatarImageBase64
                )
                dismiss()
            }
        }
        .padding(24)
        .background(Color.spoonieBackground.ignoresSafeArea())
        .onChange(of: pickerItem) { _, newItem in
            loadAvatar(newItem)
        }
        .onAppear {
            displayName = store.userProfile.displayName
            avatarPreset = store.userProfile.avatarPreset
            avatarImageBase64 = store.userProfile.avatarImageBase64
        }
    }

    private func loadAvatar(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            let encoded = normalizedProfileImageData(data).base64EncodedString()
            await MainActor.run {
                avatarImageBase64 = encoded
                pickerItem = nil
            }
        }
    }
}
