//
//  rootview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 29/05/2026.
//

//
//  RootView.swift
//  firebasetrial

//
//  RootView.swift
//  firebasetrial

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var navManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navManager.path) {
            HomeView(
                onSignIn:           { navManager.navigate(to: .signIn) },
                onSeeAllChallenges: { navManager.navigate(to: .allChallenges) },
                onCreateChallenge:  { navManager.navigate(to: .createChallenge) },
                onJoinChallenge:    { navManager.navigate(to: .joinChallenge) },
                onViewRoom:         { navManager.navigate(to: .challengeRoom($0)) },
                onMyTasks:          { navManager.navigate(to: .myTasks($0)) },
                onProfile:          { navManager.navigate(to: .profile) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .signIn:
                    SignInView(onBack: { navManager.goBack() })
                        .environmentObject(authVM)

                case .profile:
                    ProfileView(
                        onBack:             { navManager.goBack() },
                        onSeeAllChallenges: { navManager.navigate(to: .allChallenges) }
                    )
                    .environmentObject(authVM)

                case .allChallenges:
                    PlaceholderView(title: "All Challenges")

                case .createChallenge:
                    PlaceholderView(title: "Create Challenge")

                case .joinChallenge:
                    PlaceholderView(title: "Join Challenge")

                case .challengeRoom(let challenge):
                    PlaceholderView(title: "Room: \(challenge.title)")

                case .myTasks(let challenge):
                    PlaceholderView(title: "My Tasks: \(challenge.title)")

                case .home:
                    EmptyView()
                }
            }
        }
        // ✅ iOS 17+ onChange syntax — go home on sign out
        .onChange(of: authVM.isAuthenticated) {
            if !authVM.isAuthenticated {
                navManager.goHome()
            }
        }
    }
}

// MARK: - Placeholder
private struct PlaceholderView: View {
    let title: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(hex: "#F5F4FA").ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color.ticku.accent)
                Text(title)
                    .font(Font.ticku.title)
                    .foregroundColor(Color.ticku.textPrimary)
                Text("Coming soon")
                    .font(Font.ticku.caption)
                    .foregroundColor(Color.ticku.textSecondary)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.ticku.textPrimary)
                }
            }
        }
    }
}
