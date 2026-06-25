//
//  SettingsView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 04/06/2026.
//

import SwiftUI
import PhotosUI

@MainActor

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = SettingsViewModel()
    @State private var photosItem: PhotosPickerItem? = nil
    @State private var showSignOutAlert = false
    @AppStorage("isDarkMode") private var appIsDarkMode = false
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }
    private var avatarBorderColor: Color {
        isDark ? Color(hex: "#7F71A6") : Color(hex: "#341D71")
    }
    private var toggleSelectedColor: Color {
        isDark ? Color(hex: "#093769") : Color(hex: "#4BA1FF")
    }
    private let actionColor = Color(hex: "#341D71")

    var onBack: () -> Void = {}

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── Nav Bar ───────────────────────
                        HStack {
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
                            }
                            Spacer()
                            Text("Settings")
                                .font(Font.ticku.sectionHeader)
                                .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
                            Spacer()
                            Color.clear.frame(width: 24)
                        }
                        .padding(.horizontal, TickuSpacing.screenH)
                        .padding(.top, 16)
                        .padding(.bottom, 82)

                        // ── Avatar Picker ─────────────────
                        PhotosPicker(selection: $photosItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                Group {
                                    if let selected = vm.selectedImage {
                                        Image(uiImage: selected)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 104, height: 104)
                                            .clipShape(Circle())
                                    } else {
                                        AvatarView(
                                            imageURL: nil,
                                            size: 104,
                                            base64: vm.profileImageBase64
                                        )
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(avatarBorderColor, lineWidth: 8)
                                )

                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle()
                                                .stroke(isDark ? Color(hex: "#0A0814") : Color(hex: "#F5F4FA"), lineWidth: 2)
                                        )
                                    Image(systemName: "plus")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isDark ? Color(hex: "#B296EB") : Color.ticku.primary)
                                }
                            }
                        }
                        .onChange(of: photosItem) {
                            Task {
                                if let data = try? await photosItem?
                                    .loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    await MainActor.run {
                                        vm.selectedImage = image
                                        vm.profileImageBase64 = nil
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 12)

                        // ── Name (inline editable, underlined) + Handle ─
                        HStack(spacing: 6) {
                            TextField("Your Name", text: $vm.displayName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
                                .multilineTextAlignment(.center)
                                .autocorrectionDisabled()
                                .fixedSize()
                            Image(systemName: "pencil")
                                .font(.system(size: 18))
                                .foregroundColor(isDark ? .white.opacity(0.5) : Color.ticku.textSecondary)
                        }

                        Text(vm.handle.isEmpty ? "@handle" : vm.handle)
                            .font(.system(size: 15))
                            .foregroundColor(isDark ? .white.opacity(0.5) : Color.ticku.textSecondary)
                            .padding(.top, 4)
                            .padding(.bottom, 76)

                        // ── System Settings ───────────────
                        VStack(alignment: .leading, spacing: 20) {
                            Text("System settings")
                                .font(Font.ticku.caption)
                                .foregroundColor(isDark ? .white.opacity(0.5) : Color.ticku.textSecondary)
                                .padding(.horizontal, TickuSpacing.screenH)

                            VStack(spacing: 0) {
                                settingsRow(icon: "globe", title: "Language") {
                                    HStack(spacing: 0) {
                                        toggleOption("EN", isSelected: vm.language == "EN") { vm.language = "EN" }
                                        toggleOption("AR", isSelected: vm.language == "AR") { vm.language = "AR" }
                                    }
                                    .padding(2)
                                    .background(isDark ? Color.black.opacity(0.3) : Color(hex: "#E5E5EA"))
                                    .clipShape(Capsule())
                                }

                                Divider().padding(.horizontal, 16)

                                settingsRow(icon: "circle.lefthalf.filled", title: "Mode") {
                                    HStack(spacing: 2) {
                                        toggleIconOption("sun.max.fill", isSelected: !appIsDarkMode) {
                                            appIsDarkMode = false
                                            vm.isDarkMode = false
                                        }
                                        toggleIconOption("moon.fill", isSelected: appIsDarkMode) {
                                            appIsDarkMode = true
                                            vm.isDarkMode = true
                                        }
                                    }
                                    .padding(2)
                                    .background(isDark ? Color.black.opacity(0.3) : Color(hex: "#E5E5EA"))
                                    .clipShape(Capsule())
                                }
                            }
                            .background(isDark ? Color.white.opacity(0.04) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(isDark ? Color(hex: "#B296EB").opacity(0.15) : Color.clear, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.horizontal, TickuSpacing.screenH)
                        }
                    }
                }

                // ── Save Button (pinned near bottom, content-sized) ─
                Button {
                    Task {
                        if let uid = authVM.currentUserId {
                            await vm.save(uid: uid)
                        }
                    }
                } label: {
                    ZStack {
                        if vm.isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Save")
                                .font(Font.ticku.button)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 32)
                    .background(saveButtonBackground)
                    .clipShape(Capsule())
                }
                .disabled(vm.isSaving)
                .padding(.bottom, 30)
            }

            if let success = vm.successMessage {
                VStack {
                    Spacer()
                    Text(success)
                        .font(Font.ticku.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Color.ticku.doneGreen.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 90)
                        .onTapGesture { vm.successMessage = nil }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                vm.successMessage = nil
                            }
                        }
                }
            }

            if let error = vm.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .font(Font.ticku.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Color.ticku.errorRed.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 90)
                        .onTapGesture { vm.errorMessage = nil }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) { authVM.signOut() }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .task {
            if let uid = authVM.currentUserId {
                await vm.load(uid: uid)
                appIsDarkMode = vm.isDarkMode
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            Color(hex: "#0A0814").ignoresSafeArea()
        } else {
            Color(hex: "#F5F4FA").ignoresSafeArea()
        }
    }

    private var saveButtonBackground: Color {
        let base = actionColor
        return vm.isSaving ? base.opacity(0.6) : base
    }

    private func settingsRow<T: View>(icon: String, title: String, @ViewBuilder trailing: () -> T) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(actionColor).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(.white)
            }
            Text(title).font(Font.ticku.bodyMedium).foregroundColor(isDark ? .white : Color.ticku.textPrimary)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func toggleOption(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : (isDark ? .white.opacity(0.5) : Color.ticku.textSecondary))
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(isSelected ? toggleSelectedColor : Color.clear)
                .clipShape(Capsule())
        }
    }

    private func toggleIconOption(_ icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : (isDark ? .white.opacity(0.5) : Color.ticku.textSecondary))
                .frame(width: 24, height: 24)
                .background(isSelected ? toggleSelectedColor : Color.clear)
                .clipShape(Circle())
        }
    }
}

#Preview("Light") {
    SettingsView()
        .environmentObject(AuthViewModel())
}

#Preview("Dark") {
    SettingsView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
