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
        VStack(spacing: 10) {

            TextField("e.g.GRA829", text: $vm.inviteCode)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .foregroundColor(isDark ? .white : Color.black.opacity(0.75))
                .frame(width: 318, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(isDark ? Color(hex: "#8D8C8C").opacity(0.25) : Color(hex: "#DDDDDD").opacity(0.48))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(isDark ? Color(hex: "#535353") : Color.clear, lineWidth: 1)
                )
                // ✅ Liquid Glass
                .liquidGlass(tint: isDark ? Color(hex: "#8D8C8C").opacity(0.25) : Color(hex: "#DDDDDD").opacity(0.48), cornerRadius: 50)
                .onChange(of: vm.inviteCode) { newValue in
                    vm.inviteCode = String(
                        newValue
                            .uppercased()
                            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
                            .prefix(8)
                    )
                }

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
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Join")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 165, height: 52)
                .background(joinButtonBackground)
                .clipShape(Capsule())
                // ✅ Liquid Glass
                .liquidGlassButton(tint: joinButtonBackground, cornerRadius: 26)
            }
            .disabled(!vm.isCodeValid || vm.isLoading)

            if let error = vm.errorMessage {
                Text(error)
                    .font(Font.ticku.caption)
                    .foregroundColor(Color.ticku.errorRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
        }
    }

    private var joinButtonBackground: Color {
        let base = isDark ? Color(hex: "#2A1B53") : Color(hex: "#341D71")
        return vm.isCodeValid ? base : base.opacity(0.83)
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
