//
//  SettingsView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 04/06/2026.
//

import SwiftUI
import PhotosUI
import AuthenticationServices

@MainActor
struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = SettingsViewModel()
    @State private var photosItem: PhotosPickerItem? = nil
    @State private var showDeleteAlert = false
    @AppStorage("isDarkMode") private var appIsDarkMode = false
    @Environment(\.colorScheme) private var colorScheme

    // ✅ للـ re-auth قبل حذف الحساب
    @State private var deleteNonce: String? = nil

    private var isDark: Bool { colorScheme == .dark }
    private var avatarBorderColor: Color { isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71") }
    private var toggleSelectedColor: Color { isDark ? Color(hex: "#4C3882") : Color(hex: "#4BA1FF") }
    private var primaryPurple: Color { isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71") }

    var onBack: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView
            scrollContent
            fixedHeader
            saveButton
            toastMessages
        }
        .navigationBarHidden(true)
        .alert(NSLocalizedString("delete_account", comment: ""), isPresented: $showDeleteAlert) {
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                // ✅ نطلب Apple Sign In للـ re-authentication قبل الحذف
                let nonce = CryptoUtils.randomNonceString()
                deleteNonce = nonce
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = []
                request.nonce = CryptoUtils.sha256(nonce)
                let controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = DeleteAccountDelegate(nonce: nonce, authVM: authVM)
                controller.delegate = delegate
                objc_setAssociatedObject(controller, "delegate_key", delegate, .OBJC_ASSOCIATION_RETAIN)
                controller.performRequests()
            }
        } message: {
            Text(NSLocalizedString("delete_account_message", comment: ""))
        }
        .task {
            if let uid = authVM.currentUserId {
                await vm.load(uid: uid)
            }
        }
    }

    // MARK: - Scroll Content
    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                avatarPicker.padding(.bottom, 16)
                nameField
                handleLabel.padding(.bottom, 76)
                settingsCard
                deleteCard
                Spacer().frame(height: 120)
            }
            .padding(.top, 80)
        }
    }

    // MARK: - Avatar Picker
    private var avatarPicker: some View {
        PhotosPicker(selection: $photosItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let selected = vm.selectedImage {
                        Image(uiImage: selected)
                            .resizable().scaledToFill()
                            .frame(width: 104, height: 104).clipShape(Circle())
                    } else {
                        AvatarView(imageURL: nil, size: 104, base64: vm.profileImageBase64)
                    }
                }
                .overlay(Circle().stroke(avatarBorderColor, lineWidth: 7))

                ZStack {
                    Circle().fill(isDark ? Color(hex: "#2A2A2A") : .white).frame(width: 28, height: 38)
                    Image(systemName: "plus").font(.system(size: 19, weight: .bold)).foregroundColor(primaryPurple)
                }
                .offset(x: -2, y: -2)
            }
        }
        .onChange(of: photosItem) {
            Task {
                if let data = try? await photosItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        vm.selectedImage = image
                        vm.profileImageBase64 = nil
                    }
                }
            }
        }
    }

    // MARK: - Name + Handle
    private var nameField: some View {
        HStack(spacing: 6) {
            TextField(NSLocalizedString("your_name", comment: ""), text: $vm.displayName)
                .font(.system(size: 27, weight: .black, design: .rounded))
                .foregroundColor(isDark ? .white : .black)
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
                .fixedSize()
            Image(systemName: "pencil")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isDark ? .white.opacity(0.55) : Color.black.opacity(0.45))
        }
    }

    private var handleLabel: some View {
        HStack(spacing: 6) {
            Text("@")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isDark ? .white.opacity(0.55) : Color.black.opacity(0.45))
            TextField("handle", text: $vm.handle)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isDark ? .white.opacity(0.55) : Color.black.opacity(0.45))
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .fixedSize()
            Image(systemName: "pencil")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isDark ? .white.opacity(0.55) : Color.black.opacity(0.45))
        }
    }

    // MARK: - Settings Card
    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(NSLocalizedString("system_settings", comment: ""))
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(isDark ? .white.opacity(0.5) : Color.black.opacity(0.35))
                .padding(.horizontal, 1)

            VStack(spacing: 0) {
                settingsRow(icon: "globe", title: NSLocalizedString("language", comment: "")) {
                    HStack(spacing: 0) {
                        toggleOption("EN", isSelected: vm.language == "EN") { vm.language = "EN" }
                        toggleOption("AR", isSelected: vm.language == "AR") { vm.language = "AR" }
                    }
                    .padding(2)
                    .background(isDark ? Color.black.opacity(0.30) : Color(hex: "#E5E5EA"))
                    .clipShape(Capsule())
                }

                Divider().padding(.horizontal, 16)

                settingsRow(icon: "circle.lefthalf.filled", title: NSLocalizedString("mode", comment: "")) {
                    HStack(spacing: 0) {
                        toggleIconOption("sun.max.fill", isSelected: !appIsDarkMode) { appIsDarkMode = false }
                        toggleIconOption("moon.fill", isSelected: appIsDarkMode) { appIsDarkMode = true }
                    }
                    .padding(2)
                    .background(isDark ? Color.black.opacity(0.30) : Color(hex: "#E5E5EA"))
                    .clipShape(Capsule())
                }
            }
            .cardStyle(isDark: isDark)
        }
    }

    // MARK: - Delete Account Card
    private var deleteCard: some View {
        Button(action: { showDeleteAlert = true }) {
            HStack {
                Spacer()
                if authVM.isDeleting {
                    ProgressView().tint(.red)
                } else {
                    Text(NSLocalizedString("delete_account", comment: ""))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                }
                Spacer()
            }
            .frame(width: 200, height: 38)
            .background(isDark ? Color.white.opacity(0.05) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(isDark ? Color.white.opacity(0.12) : Color(hex: "#EBEBEB"), lineWidth: 1))
            .shadow(color: Color.black.opacity(isDark ? 0 : 0.1), radius: 4, x: 0, y: 2)
        }
        .disabled(authVM.isDeleting)
        .padding(.top, 40)
    }

    // MARK: - Save Button
    private var saveButton: some View {
        VStack {
            Spacer()
            Button {
                Task {
                    if let uid = authVM.currentUserId { await vm.save(uid: uid) }
                }
            } label: {
                ZStack {
                    if vm.isSaving { ProgressView().tint(.white) }
                    else {
                        Text(NSLocalizedString("save", comment: ""))
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 146, height: 60)
                .background(vm.isSaving ? Color(hex: "#4C3882").opacity(0.6) : Color(hex: "#4C3882"))
                .clipShape(Capsule())
                .glassEffectButtonIfAvailable()
            }
            .disabled(vm.isSaving)
            .padding(.bottom, 35)
        }
    }

    // MARK: - Toast Messages
    private var toastMessages: some View {
        VStack {
            Spacer()
            if let success = vm.successMessage {
                Text(success)
                    .font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.ticku.doneGreen.opacity(0.9)).clipShape(Capsule())
                    .padding(.bottom, 100)
                    .onTapGesture { vm.successMessage = nil }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { vm.successMessage = nil }
                    }
            }
            if let error = vm.errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.ticku.errorRed.opacity(0.9)).clipShape(Capsule())
                    .padding(.bottom, 100)
                    .onTapGesture { vm.errorMessage = nil }
            }
        }
    }

    // MARK: - Fixed Header
    private var fixedHeader: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isDark ? .white : .black)
            }
            Spacer()
            Text(NSLocalizedString("settings", comment: ""))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isDark ? .white : Color.black.opacity(0.65))
            Spacer()
            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal, 21).padding(.top, 1).padding(.bottom, 20)
        .background(isDark ? Color.black : Color.white)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark { Color.black.ignoresSafeArea() }
        else { Color.white.ignoresSafeArea() }
    }

    // MARK: - Helpers
    private func settingsRow<T: View>(icon: String, title: String, @ViewBuilder trailing: () -> T) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(isDark ? Color(hex: "#4C3882") : Color(hex: "#341D71")).frame(width: 45, height: 45)
                Image(systemName: icon).font(.system(size: 29, weight: .semibold)).foregroundColor(.white)
            }
            Text(title).font(.system(size: 16, weight: .semibold)).foregroundColor(isDark ? .white : .black)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16).padding(.vertical, 12).frame(height: 65)
    }

    private func toggleOption(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            let lang = label == "AR" ? "ar" : "en"
            // ✅ يحدّث Bundle (للنصوص) و AppStorage (للـ layout direction) معاً
            Bundle.setLanguage(lang)
            UserDefaults.standard.set(lang, forKey: "app_language")
        }) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : (isDark ? .white.opacity(0.5) : Color.black.opacity(0.35)))
                .frame(width: 36, height: 28)
                .background(isSelected ? toggleSelectedColor : Color.clear)
                .clipShape(Capsule())
                .glassEffectButtonIfAvailable()
        }
    }

    private func toggleIconOption(_ icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : (isDark ? .white.opacity(0.5) : Color.black.opacity(0.35)))
                .frame(width: 36, height: 28)
                .background(isSelected ? toggleSelectedColor : Color.clear)
                .clipShape(Capsule())
                .glassEffectButtonIfAvailable()
        }
    }
}

// MARK: - Card Style
private extension View {
    func cardStyle(isDark: Bool) -> some View {
        self
            .frame(width: 349)
            .background(isDark ? Color.white.opacity(0.05) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(RoundedRectangle(cornerRadius: 25).stroke(isDark ? Color.white.opacity(0.12) : Color(hex: "#EBEBEB"), lineWidth: 1))
            .shadow(color: Color.black.opacity(isDark ? 0 : 0.15), radius: 4, x: 0, y: 4)
            .glassEffectIfAvailable(cornerRadius: 25)
    }
}

// ✅ glassEffect فقط على iOS 26+ — صفر تغيير بالألوان
private extension View {
    @ViewBuilder
    func glassEffectIfAvailable(cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self
        }
    }

    @ViewBuilder
    func glassEffectButtonIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            self
        }
    }
}

#Preview("Light") { SettingsView().environmentObject(AuthViewModel()) }
#Preview("Dark") { SettingsView().environmentObject(AuthViewModel()).preferredColorScheme(.dark) }

// ✅ Delegate خاص بحذف الحساب — منفصل تماماً عن delegate تسجيل الدخول
// يستقبل نتيجة Apple Sign In ويمررها لـ reauthAndDelete
import AuthenticationServices
private final class DeleteAccountDelegate: NSObject, ASAuthorizationControllerDelegate {
    let nonce: String
    let authVM: AuthViewModel

    init(nonce: String, authVM: AuthViewModel) {
        self.nonce = nonce
        self.authVM = authVM
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else { return }

        Task { @MainActor in
            await authVM.reauthAndDelete(idToken: idToken, rawNonce: nonce)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Re-auth cancelled or failed: \(error.localizedDescription)")
    }
}
