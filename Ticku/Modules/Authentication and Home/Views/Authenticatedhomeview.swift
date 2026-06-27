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

                    // ── Header ────────────────────────────────
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 5) {
                                Text("Hello")
                                    .font(Font.ticku.bodyMedium)
                                    .foregroundColor(isDark ? .white.opacity(0.6) : Color.ticku.textSecondary)
                                Text("👋")
                            }
                            Text(vm.currentUser?.displayName ?? "")
                                .font(Font.ticku.largeTitle)
                                .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
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
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    // ── Today's Tasks ─────────────────────────
                    Text("Today's Tasks")
                        .font(Font.ticku.sectionHeader)
                        .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
                        .padding(.horizontal, TickuSpacing.screenH)
                        .padding(.bottom, 12)

                    HStack(spacing: 12) {
                        Button(action: onTodayTasks) {
                            RoundedRectangle(cornerRadius: TickuRadius.lg)
                                .fill(isDark ? Color.white.opacity(0.04) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: TickuRadius.lg)
                                        .stroke(isDark ? Color(hex: "#B296EB").opacity(0.2) : Color.clear, lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(isDark ? 0 : 0.05), radius: 10, x: 0, y: 4)
                                .overlay(ProgressRingView(percentage: vm.progressPercent / 100))
                                .frame(height: 160)
                        }
                        .buttonStyle(.plain)
                        .popoverTip(addTaskTip, arrowEdge: .top)

                        StatsSidePanelView(
                            tasksCompleted: vm.tasksCompleted,
                            wins: vm.currentUser?.totalWins ?? 0
                        )
                        .frame(height: 160)
                    }
                    .padding(.horizontal, TickuSpacing.screenH)

                    // ── Active Challenge ──────────────────────
                    HStack {
                        Text("Active Challenge")
                            .font(Font.ticku.sectionHeader)
                            .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
                        Spacer()
                        Button(action: onSeeAllChallenges) {
                            Text("See all")
                                .font(Font.ticku.smallButton)
                                .foregroundColor(isDark ? Color(hex: "#B296EB") : Color.ticku.accent)
                        }
                    }
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                    if vm.activeChallenges.isEmpty {
                        EmptyStateView()
                            .padding(.horizontal, TickuSpacing.screenH)
                    } else if let first = vm.activeChallenges.first {
                        ActiveChallengeCardView(
                            challenge: first,
                            onViewRoom: { onViewRoom(first) },
                            onMyTasks:  { onMyTasks(first) }
                        )
                        .padding(.horizontal, TickuSpacing.screenH)
                    }

                    // ── CTA Buttons ───────────────────────────
                    HStack(spacing: 12) {
                        PrimaryButtonView(title: "+ Create", style: .solid, action: onCreateChallenge)
                            .popoverTip(createChallengeTip, arrowEdge: .top)
                        PrimaryButtonView(title: "Join", style: .muted, action: { showJoin = true })
                    }
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
            }
            .refreshable {
                if let uid = vm.currentUser?.uid {
                    await vm.loadHome(for: uid)
                }
            }
            .onAppear {
                // ✅ نأخر التسجيل قليلاً عشان TipKit يقدر يعرض الـ tip أول مرة قبل ما نقفله
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    AddTaskTip.hasOpenedHomeBefore = true
                }
                CreateChallengeTip.hasNoActiveChallenges = vm.activeChallenges.isEmpty
            }
            .onChange(of: vm.activeChallenges) {
                CreateChallengeTip.hasNoActiveChallenges = vm.activeChallenges.isEmpty
            }

            // ── Join Popup ────────────────────────────────
            if showJoin {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showJoin = false }

                VStack(spacing: 16) {
                    Text("Enter invite code")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isDark ? .white : Color.ticku.textPrimary)

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
                .padding(24)
                .background(isDark ? Color(hex: "#1A1530") : Color.white)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isDark ? Color(hex: "#B296EB").opacity(0.25) : Color.clear, lineWidth: 1)
                )
                .shadow(color: .black.opacity(isDark ? 0 : 0.15), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 24)
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
                    Color(hex: "#0A0814"),
                    Color(hex: "#0A0814"),
                    Color(hex: "#1A1530")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            Color.clear
        }
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
