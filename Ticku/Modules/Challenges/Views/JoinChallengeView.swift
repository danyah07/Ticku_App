//
//  JoinChallengeView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/06/2026.
//


import SwiftUI

struct JoinChallengeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = JoinChallengeViewModel()
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var onDismiss: () -> Void = {}
    var onJoined: (Challenge) -> Void = { _ in }
    var displayName: String = ""

    var body: some View {
        VStack(spacing: 16) {

            // Code Input
            TextField("e.g. ABC123", text: $vm.inviteCode)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .foregroundColor(isDark ? Color(hex: "#B296EB") : Color.ticku.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(isDark ? Color.white.opacity(0.05) : Color(hex: "#F5F4FB"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isDark ? Color(hex: "#B296EB").opacity(0.2) : Color.clear, lineWidth: 1)
                )
                .onChange(of: vm.inviteCode) {
                    vm.inviteCode = String(
                        vm.inviteCode
                            .uppercased()
                            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
                            .prefix(8)
                    )
                }

            // Join Button
            Button {
                Task {
                    guard let uid = authVM.currentUserId else { return }
                    if let challenge = await vm.joinChallenge(
                        userId: uid,
                        displayName: displayName
                    ) {
                        onJoined(challenge)
                    }
                }
            } label: {
                ZStack {
                    if vm.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Join")
                            .font(Font.ticku.button)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(joinButtonBackground)
                .clipShape(Capsule())
            }
            .disabled(!vm.isCodeValid || vm.isLoading)

            if let error = vm.errorMessage {
                Text(error)
                    .font(Font.ticku.caption)
                    .foregroundColor(Color.ticku.errorRed)
            }
        }
    }

    private var joinButtonBackground: Color {
        let base = isDark ? Color(hex: "#B296EB") : Color.ticku.primary
        return vm.isCodeValid ? base : base.opacity(0.4)
    }
}

#Preview("Light") {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        VStack(spacing: 16) {
            Text("Enter invite code")
                .font(.system(size: 18, weight: .bold))
            JoinChallengeView()
                .environmentObject(AuthViewModel())
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal, 24)
    }
}

#Preview("Dark") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 16) {
            Text("Enter invite code")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            JoinChallengeView()
                .environmentObject(AuthViewModel())
        }
        .padding(24)
        .background(Color(hex: "#1A1530"))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "#B296EB").opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
    .preferredColorScheme(.dark)
}
