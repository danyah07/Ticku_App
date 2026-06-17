//
//  AllChallengesView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 13/06/2026.
//

import SwiftUI

struct AllChallengesView: View {

    @ObservedObject var vm: HomeViewModel
    @EnvironmentObject var authVM: AuthViewModel
    var onBack: () -> Void = {}
    var onViewRoom: (Challenge) -> Void = { _ in }
    var onMyTasks: (Challenge) -> Void = { _ in }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // MARK: - Nav Bar
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.ticku.textPrimary)
                    }
                    Spacer()
                    Text("Active Challenges")
                        .font(Font.ticku.sectionHeader)
                        .foregroundColor(Color.ticku.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, TickuSpacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 16)

                if vm.activeChallenges.isEmpty {
                    EmptyStateView()
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 14) {
                        ForEach(vm.activeChallenges) { challenge in
                            ChallengeCard(
                                challenge: challenge,
                                onViewRoom: { onViewRoom(challenge) },
                                onMyTasks:  { onMyTasks(challenge) }
                            )
                        }
                    }
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(hex: "#F5F4FA").ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            if let uid = authVM.currentUserId {
                await vm.loadHome(for: uid)
            }
        }
    }
}

// MARK: - Challenge Card
private struct ChallengeCard: View {
    let challenge: Challenge
    var onViewRoom: () -> Void
    var onMyTasks: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(challenge.durationLabel) left")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: -8) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        )
                }
            }

            HStack(spacing: 10) {
                Button(action: onViewRoom) {
                    Text("View Room")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }

                Button(action: onMyTasks) {
                    Text("My Tasks")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#341D71"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .background(Color(hex: "#341D71"))
        .cornerRadius(20)
    }
}

#Preview {
    AllChallengesView(vm: HomeViewModel())
        .environmentObject(AuthViewModel())
}
