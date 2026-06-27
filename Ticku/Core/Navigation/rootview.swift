
import SwiftUI
import Combine

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var navManager = NavigationManager()
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        NavigationStack(path: $navManager.path) {
            HomeView(
                onSignIn:           { navManager.navigate(to: .signIn) },
                onSeeAllChallenges: { navManager.navigate(to: .allChallenges) },
                onCreateChallenge:  { navManager.navigate(to: .createChallenge) },
                onJoinChallenge:    { navManager.navigate(to: .joinChallenge) },
                onViewRoom:         { navManager.navigate(to: .challengeRoom($0)) },
                onMyTasks:          { navManager.navigate(to: .myTasks($0)) },
                onProfile:          { navManager.navigate(to: .profile) },
                onTodayTasks:       { navManager.navigate(to: .todayTasks($0)) }
            )
            .environmentObject(homeVM)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {

                case .signIn:
                    SignInView(onBack: { navManager.goBack() })
                        .environmentObject(authVM)
                        .navigationBarHidden(true)
                        .toolbar(.hidden, for: .navigationBar)

                case .profile:
                    ProfileView(
                        onBack:             { navManager.goBack() },
                        onSettings:         { navManager.navigate(to: .settings) },
                        onSeeAllChallenges: { _ in navManager.navigate(to: .completedChallenges) }
                    )
                    .environmentObject(authVM)
                    .navigationBarHidden(true)
                    .toolbar(.hidden, for: .navigationBar)

                // ✅ صفحة "See all" الخاصة بالبروفايل — مستقلة بالكامل عن الهوم
                // تستخدم profileVM.load() (query خاص بيها فقط) — بدون أي ربط بـ homeVM
                case .completedChallenges:
                    CompletedChallengesView(
                        challenges: profileVM.challenges,
                        onBack: { navManager.goBack() }
                    )
                    .navigationBarHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
                    .task {
                        if let uid = authVM.currentUserId {
                            await profileVM.load(uid: uid)
                        }
                    }

                case .settings:
                    SettingsView(onBack: { navManager.goBack() })
                        .environmentObject(authVM)
                        .navigationBarHidden(true)
                        .toolbar(.hidden, for: .navigationBar)

                case .todayTasks(let challenges):
                    TodayTasksDetailView(
                        activeChallenges: challenges,
                        onBack: { navManager.goBack() }
                    )
                    .environmentObject(authVM)
                    .navigationBarHidden(true)
                    .toolbar(.hidden, for: .navigationBar)

                case .createChallenge:
                    if authVM.isAuthenticated {
                        CreateChallengeView(
                            onBack: { navManager.goBack() },
                            onCreated: { challenge in
                                navManager.goHome()
                                navManager.navigate(to: .challengeRoom(challenge))
                            }
                        )
                        .environmentObject(authVM)
                        .navigationBarHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                    } else {
                        SignInView(onBack: { navManager.goBack() })
                            .environmentObject(authVM)
                            .navigationBarHidden(true)
                            .toolbar(.hidden, for: .navigationBar)
                    }

                case .challengeRoom(let challenge):
                    ChallengeDetailView(
                        challenge: challenge,
                        onBack: { navManager.goHome() },
                        onMyTasks: { navManager.navigate(to: .myTasks($0)) }
                    )
                    .environmentObject(authVM)
                    .navigationBarHidden(true)
                    .toolbar(.hidden, for: .navigationBar)

                case .myTasks(let challenge):
                    MyTasksView(
                        challengeId: challenge.id ?? "",
                        userId: authVM.currentUserId ?? "",
                        onComplete: { navManager.navigate(to: .challengeRoom(challenge)) }
                    )
                    .environmentObject(authVM)
                    .navigationBarHidden(true)
                    .toolbar(.hidden, for: .navigationBar)

                case .allChallenges:
                    AllChallengesView(
                        vm: homeVM,
                        onBack: { navManager.goBack() },
                        onViewRoom: { navManager.navigate(to: .challengeRoom($0)) },
                        onMyTasks: { navManager.navigate(to: .myTasks($0)) }
                    )
                    .environmentObject(authVM)
                    .navigationBarHidden(true)
                    .toolbar(.hidden, for: .navigationBar)

                case .joinChallenge:
                    if authVM.isAuthenticated {
                        JoinChallengeView(
                            onDismiss: { navManager.goBack() },
                            onJoined: { challenge in
                                navManager.goBack()
                                navManager.navigate(to: .challengeRoom(challenge))
                            },
                            displayName: ""
                        )
                        .environmentObject(authVM)
                        .navigationBarHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                    } else {
                        SignInView(onBack: { navManager.goBack() })
                            .environmentObject(authVM)
                            .navigationBarHidden(true)
                            .toolbar(.hidden, for: .navigationBar)
                    }

                case .home:
                    EmptyView()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: authVM.isAuthenticated) {
            if !authVM.isAuthenticated {
                navManager.goHome()
            }
        }
    }
}

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
        .toolbar(.hidden, for: .navigationBar)
    }
}
