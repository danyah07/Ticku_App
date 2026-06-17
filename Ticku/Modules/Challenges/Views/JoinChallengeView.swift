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
                .foregroundColor(Color.ticku.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(hex: "#F5F4FB"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
                .background(
                    vm.isCodeValid
                        ? Color.ticku.primary
                        : Color.ticku.primary.opacity(0.4)
                )
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
}

#Preview {
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
