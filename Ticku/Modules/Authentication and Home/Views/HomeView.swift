//
//  HomeView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

//
//  HomeView.swift
//  firebasetrial

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var homeVM = HomeViewModel()

    var onSignIn: () -> Void = {}
    var onSeeAllChallenges: () -> Void = {}
    var onCreateChallenge: () -> Void = {}
    var onJoinChallenge: () -> Void = {}
    var onViewRoom: (Challenge) -> Void = { _ in }
    var onMyTasks: (Challenge) -> Void = { _ in }
    var onProfile: () -> Void = {}

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.ticku.backgroundTop, Color.ticku.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // ── Content ───────────────────────────────────
            if homeVM.isLoading {
                loadingView

            } else if authVM.isAuthenticated {
                AuthenticatedHomeView(
                    vm: homeVM,
                    onSeeAllChallenges: onSeeAllChallenges,
                    onCreateChallenge: onCreateChallenge,
                    onJoinChallenge: onJoinChallenge,
                    onViewRoom: onViewRoom,
                    onMyTasks: onMyTasks,
                    onProfile: onProfile
                )
                // ✅ Smooth fade when switching from guest → authenticated
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))

            } else {
                GuestHomeView(
                    onSignIn: onSignIn,
                    onCreateChallenge: onCreateChallenge,
                    onJoinChallenge: onJoinChallenge
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }

            // ── Error Toast ───────────────────────────────
            if let msg = homeVM.errorMessage {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(Font.ticku.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.ticku.errorRed.opacity(0.85))
                        .clipShape(Capsule())
                        .padding(.bottom, 24)
                        .onTapGesture { homeVM.errorMessage = nil }
                }
            }
        }
        // ✅ Fires whenever uid changes (login, logout, app launch)
        .task(id: authVM.currentUserId) {
            if let uid = authVM.currentUserId {
                await homeVM.loadHome(for: uid)
            } else {
                homeVM.reset()
            }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.ticku.primary)
                .scaleEffect(1.3)
            Text("Loading...")
                .font(Font.ticku.caption)
                .foregroundColor(Color.ticku.textSecondary)
        }
    }
}
