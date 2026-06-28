//
//  Authenticatedhomeview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

import SwiftUI
import TipKit

struct AuthenticatedHomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject var vm: HomeViewModel
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var onSeeAllChallenges: () -> Void
    var onCreateChallenge:  () -> Void
    var onJoinChallenge:    () -> Void
    var onViewRoom:  (Challenge) -> Void
    var onMyTasks:   (Challenge) -> Void
    var onProfile:           () -> Void
    var onTodayTasks:        () -> Void

    @State private var showJoin = false

    private let addTaskTip = AddTaskTip()
    private let createChallengeTip = CreateChallengeTip()

    var body: some View {
        ZStack {
            backgroundView

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome!")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(isDark ? .white.opacity(0.45) : Color.black.opacity(0.39))

                            Text("Get started")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(isDark ? .white : .black)
                        }

                        Spacer()

                        Button(action: onProfile) {
                            AvatarView(
                                imageURL: vm.currentUser?.profileImageURL,
                                size: 50,
                                base64: vm.currentUser?.profileImageBase64
                            )
                        }
                    }
                    .padding(.horizontal, 34)
                    .padding(.top, 5)
                    .padding(.bottom, 50)

                    Text("Today's Tasks")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(isDark ? .white : Color.black.opacity(0.65))
                        .padding(.horizontal, 34)
                        .padding(.bottom, 8)

                    HStack(spacing: 14) {
                        Button(action: onTodayTasks) {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(isDark ? Color.black.opacity(0.18) : Color(hex: "#F6F6F6"))
                                .frame(width: 188, height: 214)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.35) : Color.clear, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(isDark ? 0 : 0.25), radius: 4, x: 0, y: 4)
                                .overlay(
                                    ProgressRingView(
                                        percentage: vm.progressPercent / 100,
                                        ringSize: 120,
                                        lineWidth: 10
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                        .popoverTip(addTaskTip, arrowEdge: .top)

                        FigmaStatsSidePanelView(
                            tasksCompleted: vm.tasksCompleted,
                            wins: vm.currentUser?.totalWins ?? 0,
                            isDark: isDark
                        )
                        .frame(width: 147, height: 217)
                    }
                    .padding(.horizontal, 23)

                    HStack {
                        Text("Active Challenge")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(isDark ? .white : Color.black.opacity(0.65))

                        Spacer()

                        Button(action: onSeeAllChallenges) {
                            Text("See all")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#4FA2FF"))
                        }
                    }
                    .padding(.horizontal, 34)
                    .padding(.top, 30)
                    .padding(.bottom, -5)

                    if vm.activeChallenges.isEmpty {
                        EmptyStateView()
                            .padding(.top, 49)
                            .frame(height: 190)
                            .padding(.horizontal, 20)
                    } else if let first = vm.activeChallenges.first {
                        HomeActiveChallengeCardView(
                            challenge: first,
                            isDark: isDark,
                            onViewRoom: { onViewRoom(first) },
                            onMyTasks: { onMyTasks(first) }
                        )
                        .padding(.top, 49)
                        .frame(height: 190)
                        .padding(.horizontal, 20)
                    }

                    HStack(spacing: 13) {
                        PrimaryButtonView(title: "+ Create", style: .solid, action: onCreateChallenge)
                            .popoverTip(createChallengeTip, arrowEdge: .top)

                        PrimaryButtonView(title: "Join", style: .muted, action: { showJoin = true })
                    }
                    .padding(.horizontal, 23)
                    .padding(.top, 59)
                    .padding(.bottom, 40)
                }
            }
            .refreshable {
                if let uid = vm.currentUser?.uid {
                    await vm.loadHome(for: uid)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    AddTaskTip.hasOpenedHomeBefore = true
                }
                CreateChallengeTip.hasNoActiveChallenges = vm.activeChallenges.isEmpty
            }
            .onChange(of: vm.activeChallenges) {
                CreateChallengeTip.hasNoActiveChallenges = vm.activeChallenges.isEmpty
            }

            if showJoin {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { showJoin = false }

                VStack(spacing: 10) {
                    Text("Enter invite code")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isDark ? .white.opacity(0.88) : Color.black.opacity(0.75))

                    JoinChallengeView(
                        onDismiss: { showJoin = false },
                        onJoined: { challenge in
                            showJoin = false
                            onViewRoom(challenge)
                        },
                        displayName: vm.currentUser?.displayName ?? ""
                    )
                    .environmentObject(authVM)
                }
                .frame(width: 348, height: 199)
                .background(
                    isDark
                    ? Color(hex: "#2A2A2A").opacity(0.84)
                    : Color.white.opacity(0.88)
                )
                .clipShape(RoundedRectangle(cornerRadius: 35))
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(
                            isDark ? Color(hex: "#303030") : Color(hex: "#D1D1D1"),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(isDark ? 0.18 : 0.12), radius: 12, x: 0, y: 6)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3), value: showJoin)
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            LinearGradient(
                colors: [
                    Color(hex: "#000000"),
                    Color(hex: "#3E3C5E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [
                    Color.white,
                    Color.white,
                    Color(hex: "#341D71").opacity(0.69)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

private struct HomeActiveChallengeCardView: View {
    let challenge: Challenge
    let isDark: Bool
    var onViewRoom: () -> Void
    var onMyTasks: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text("\(challenge.memberCount) Participants | \(challenge.durationLabel) left")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.62))
                }

                Spacer()

                Text("ACTIVE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }

            HStack(spacing: -8) {
                ForEach(0..<max(challenge.memberCount, 0), id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: "#F2F2F7"))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#341D71"))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#341D71"), lineWidth: 2)
                        )
                }
            }

            HStack(spacing: 18) {
                Button(action: onViewRoom) {
                    Text("View Room")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 151, height: 57)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                }

                Button(action: onMyTasks) {
                    Text("My Tasks")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 151, height: 57)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(isDark ? Color(hex: "#341D71").opacity(0.20) : Color(hex: "#341D71"))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .shadow(color: .black.opacity(isDark ? 0 : 0.25), radius: 4, x: 0, y: 4)
    }
}

private struct FigmaStatsSidePanelView: View {
    let tasksCompleted: Int
    let wins: Int
    let isDark: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack(spacing: 3) {
                    Text("\(tasksCompleted)")
                    Text("✓")
                }
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#377329"))

                Text("Done")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isDark ? .white.opacity(0.65) : Color.black.opacity(0.45))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Rectangle()
                .fill(isDark ? Color.white.opacity(0.18) : Color(hex: "#D5D5D5"))
                .frame(height: 1)

            VStack(spacing: 12) {
                HStack(spacing: 3) {
                    Text("\(wins)")
                    Image(systemName: "trophy")
                }
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#C57723"))

                Text("Wins")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isDark ? .white.opacity(0.65) : Color.black.opacity(0.45))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(isDark ? Color.black.opacity(0.18) : Color(hex: "#F8F8F8"))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(isDark ? Color.white.opacity(0.18) : Color(hex: "#D5D5D5"), lineWidth: 1)
        )
    }
}

#Preview("Light") {
    AuthenticatedHomeView(
        vm: HomeViewModel(),
        onSeeAllChallenges: {},
        onCreateChallenge: {},
        onJoinChallenge: {},
        onViewRoom: { _ in },
        onMyTasks: { _ in },
        onProfile: {},
        onTodayTasks: {}
    )
    .environmentObject(AuthViewModel())
}

#Preview("Dark") {
    AuthenticatedHomeView(
        vm: HomeViewModel(),
        onSeeAllChallenges: {},
        onCreateChallenge: {},
        onJoinChallenge: {},
        onViewRoom: { _ in },
        onMyTasks: { _ in },
        onProfile: {},
        onTodayTasks: {}
    )
    .environmentObject(AuthViewModel())
    .preferredColorScheme(.dark)
}
