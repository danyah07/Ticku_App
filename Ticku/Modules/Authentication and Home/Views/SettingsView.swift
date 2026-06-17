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

    var onBack: () -> Void = {}

    var body: some View {
        ZStack {
            Color(hex: "#F5F4FA").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Nav Bar ───────────────────────────
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.ticku.textPrimary)
                        }
                        Spacer()
                        Text("Settings")
                            .font(Font.ticku.sectionHeader)
                            .foregroundColor(Color.ticku.textPrimary)
                        Spacer()
                        Color.clear.frame(width: 24)
                    }
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.top, 16)
                    .padding(.bottom, 28)

                    // ── Avatar Picker ─────────────────────
                    PhotosPicker(selection: $photosItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            if let selected = vm.selectedImage {
                                Image(uiImage: selected)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.ticku.primary, lineWidth: 3)
                                    )
                            } else {
                                AvatarView(
                                    imageURL: nil,
                                    size: 100,
                                    base64: vm.profileImageBase64
                                )
                            }

                            ZStack {
                                Circle()
                                    .fill(Color.ticku.primary)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 2, y: 2)
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

                    // ── Name + Handle preview ─────────────
                    HStack(spacing: 6) {
                        Text(vm.displayName.isEmpty ? "Your Name" : vm.displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.ticku.textPrimary)
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(Color.ticku.textSecondary)
                    }

                    Text(vm.handle.isEmpty ? "@handle" : vm.handle)
                        .font(.system(size: 15))
                        .foregroundColor(Color.ticku.textSecondary)
                        .padding(.top, 4)
                        .padding(.bottom, 32)

                    // ── Edit Fields ───────────────────────
                    VStack(spacing: 12) {
                        editField(icon: "person.fill", placeholder: "Display Name", text: $vm.displayName)
                        editField(icon: "at", placeholder: "Handle", text: $vm.handle)
                    }
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.bottom, 28)

                    // ── System Settings ───────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        Text("System settings")
                            .font(Font.ticku.caption)
                            .foregroundColor(Color.ticku.textSecondary)
                            .padding(.horizontal, TickuSpacing.screenH)

                        VStack(spacing: 0) {
                            settingsRow(icon: "globe", title: "Language") {
                                HStack(spacing: 0) {
                                    toggleOption("EN", isSelected: vm.language == "EN") { vm.language = "EN" }
                                    toggleOption("AR", isSelected: vm.language == "AR") { vm.language = "AR" }
                                }
                                .background(Color(hex: "#E5E5EA"))
                                .clipShape(Capsule())
                            }

                            Divider().padding(.horizontal, 16)

                            settingsRow(icon: "circle.lefthalf.filled", title: "Mode") {
                                HStack(spacing: 0) {
                                    toggleOption("☀️", isSelected: !vm.isDarkMode) { vm.isDarkMode = false }
                                    toggleOption("🌙", isSelected: vm.isDarkMode) { vm.isDarkMode = true }
                                }
                                .background(Color(hex: "#E5E5EA"))
                                .clipShape(Capsule())
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, TickuSpacing.screenH)
                    }
                    .padding(.bottom, 28)

                    // ── Save Button ───────────────────────
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
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(vm.isSaving ? Color.ticku.primary.opacity(0.6) : Color.ticku.primary)
                        .clipShape(Capsule())
                    }
                    .disabled(vm.isSaving)
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.bottom, 16)

                    // ── Sign Out ──────────────────────────
                    Button { showSignOutAlert = true } label: {
                        Text("Sign Out")
                            .font(Font.ticku.bodyMedium)
                            .foregroundColor(Color.ticku.errorRed)
                    }
                    .padding(.bottom, 40)
                }
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
                        .padding(.bottom, 32)
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
                        .padding(.bottom, 32)
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
            }
        }
    }

    private func editField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.ticku.accent)
                .frame(width: 24)
            TextField(placeholder, text: text)
                .font(Font.ticku.body)
                .foregroundColor(Color.ticku.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func settingsRow<T: View>(icon: String, title: String, @ViewBuilder trailing: () -> T) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.ticku.primary).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(.white)
            }
            Text(title).font(Font.ticku.bodyMedium).foregroundColor(Color.ticku.textPrimary)
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
                .foregroundColor(isSelected ? .white : Color.ticku.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(isSelected ? Color.ticku.primary : Color.clear)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
