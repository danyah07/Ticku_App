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
        isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71")
    }

    private var toggleSelectedColor: Color {
        isDark ? Color(hex: "#4C3882") : Color(hex: "#4BA1FF")
    }

    private var primaryPurple: Color {
        isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71")
    }

    var onBack: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

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
                                    .stroke(avatarBorderColor, lineWidth: 7)
                            )

                            ZStack {
                                Circle()
                                    .fill(isDark ? Color(hex: "#2A2A2A") : .white)
                                    .frame(width: 28, height: 38)

                                Image(systemName: "plus")
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundColor(primaryPurple)
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
                    .padding(.bottom, 16)

                    HStack(spacing: 6) {
                        TextField("Your Name", text: $vm.displayName)
                            .font(.system(size: 27, weight: .black, design: .rounded))
                            .foregroundColor(isDark ? .white : .black)
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled()
                            .fixedSize()

                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isDark ? .white.opacity(0.55) : Color.black.opacity(0.45))
                    }

                    Text(vm.handle.isEmpty ? "@handle" : vm.handle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isDark ? .white.opacity(0.55) : Color.black.opacity(0.45))
                        .padding(.top, 0)
                        .padding(.bottom, 76)

                    VStack(alignment: .leading, spacing: 13) {
                        Text("System settings")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(isDark ? .white.opacity(0.5) : Color.black.opacity(0.35))
                            .padding(.horizontal, 1)

                        VStack(spacing: 0) {
                            settingsRow(icon: "globe", title: "Language") {
                                HStack(spacing: 0) {
                                    toggleOption("EN", isSelected: vm.language == "EN") {
                                        vm.language = "EN"
                                    }

                                    toggleOption("AR", isSelected: vm.language == "AR") {
                                        vm.language = "AR"
                                    }
                                }
                                .padding(2)
                                .background(isDark ? Color.black.opacity(0.30) : Color(hex: "#E5E5EA"))
                                .clipShape(Capsule())
                            }

                            Divider()
                                .padding(.horizontal, 16)

                            settingsRow(icon: "circle.lefthalf.filled", title: "Mode") {
                                HStack(spacing: 0) {
                                    toggleIconOption("sun.max.fill", isSelected: !appIsDarkMode) {
                                        appIsDarkMode = false
                                    }

                                    toggleIconOption("moon.fill", isSelected: appIsDarkMode) {
                                        appIsDarkMode = true
                                    }
                                }
                                .padding(2)
                                .background(isDark ? Color.black.opacity(0.30) : Color(hex: "#E5E5EA"))
                                .clipShape(Capsule())
                            }
                        }
                        .frame(width: 349)
                        .background(isDark ? Color.white.opacity(0.05) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(isDark ? Color.white.opacity(0.12) : Color(hex: "#EBEBEB"), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(isDark ? 0 : 0.15), radius: 4, x: 0, y: 4)
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.top, 80)
            }

            fixedHeader

            VStack {
                Spacer()

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
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 146, height: 60)
                    .background(saveButtonBackground)
                    .clipShape(Capsule())
                }
                .disabled(vm.isSaving)
                .padding(.bottom, 35)
            }

            if let success = vm.successMessage {
                VStack {
                    Spacer()
                    Text(success)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.ticku.doneGreen.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
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
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.ticku.errorRed.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
                        .onTapGesture { vm.errorMessage = nil }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authVM.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .task {
            if let uid = authVM.currentUserId {
                await vm.load(uid: uid)
            }
        }
    }

    private var fixedHeader: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isDark ? .white : .black)
            }

            Spacer()

            Text("Settings")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isDark ? .white : Color.black.opacity(0.65))

            Spacer()

            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal, 21)
        .padding(.top, 1)
        .padding(.bottom, 20)
        .background(isDark ? Color.black : Color.white)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            Color.black.ignoresSafeArea()
        } else {
            Color.white.ignoresSafeArea()
        }
    }

    private var saveButtonBackground: Color {
        if vm.isSaving {
            return Color(hex: "#4C3882").opacity(0.6)
        }
        return Color(hex: "#4C3882")
    }

    private func settingsRow<T: View>(
        icon: String,
        title: String,
        @ViewBuilder trailing: () -> T
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isDark ? Color(hex: "#4C3882") : Color(hex: "#341D71"))
                    .frame(width: 45, height: 45)

                Image(systemName: icon)
                    .font(.system(size: 29, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isDark ? .white : .black)

            Spacer()

            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 65)
    }

    private func toggleOption(
        _ label: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(
                    isSelected
                    ? .white
                    : (isDark ? .white.opacity(0.5) : Color.black.opacity(0.35))
                )
                .frame(width: 36, height: 28)
                .background(isSelected ? toggleSelectedColor : Color.clear)
                .clipShape(Capsule())
        }
    }

    private func toggleIconOption(
        _ icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(
                    isSelected
                    ? .white
                    : (isDark ? .white.opacity(0.5) : Color.black.opacity(0.35))
                )
                .frame(width: 36, height: 28)
                .background(isSelected ? toggleSelectedColor : Color.clear)
                .clipShape(Capsule())
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
