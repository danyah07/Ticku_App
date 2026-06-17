//
//  Authenticatedhomeview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

import SwiftUI

struct AuthenticatedHomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject var vm: HomeViewModel

    var onSeeAllChallenges: () -> Void
    var onCreateChallenge:  () -> Void
    var onJoinChallenge:    () -> Void
    var onViewRoom:  (Challenge) -> Void
    var onMyTasks:   (Challenge) -> Void
    var onProfile:           () -> Void
    var onTodayTasks:        () -> Void

    @State private var showJoin = false

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header ────────────────────────────────
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 5) {
                                Text("Hello")
                                    .font(Font.ticku.bodyMedium)
                                    .foregroundColor(Color.ticku.textSecondary)
                                Text("👋")
                            }
                            Text(vm.currentUser?.displayName ?? "")
                                .font(Font.ticku.largeTitle)
                                .foregroundColor(Color.ticku.textPrimary)
                        }
                        Spacer()
                        Button(action: onProfile) {
                            AvatarView(imageURL: vm.currentUser?.profileImageURL, size: 50)
                        }
                    }
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    // ── Today's Tasks ─────────────────────────
                    Text("Today's Tasks")
                        .font(Font.ticku.sectionHeader)
                        .foregroundColor(Color.ticku.textPrimary)
                        .padding(.horizontal, TickuSpacing.screenH)
                        .padding(.bottom, 12)

                    HStack(spacing: 12) {
                        Button(action: onTodayTasks) {
                            RoundedRectangle(cornerRadius: TickuRadius.lg)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                                .overlay(ProgressRingView(percentage: vm.progressPercent / 100))
                                .frame(height: 160)
                        }
                        .buttonStyle(.plain)

                        StatsSidePanelView(
                            tasksCompleted: vm.tasksCompleted,
                            wins: vm.currentUser?.currentStreak ?? 0
                        )
                        .frame(height: 160)
                    }
                    .padding(.horizontal, TickuSpacing.screenH)

                    // ── Active Challenge ──────────────────────
                    HStack {
                        Text("Active Challenge")
                            .font(Font.ticku.sectionHeader)
                            .foregroundColor(Color.ticku.textPrimary)
                        Spacer()
                        Button(action: onSeeAllChallenges) {
                            Text("See all")
                                .font(Font.ticku.smallButton)
                                .foregroundColor(Color.ticku.accent)
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

            // ── Join Popup ────────────────────────────────
            if showJoin {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showJoin = false }

                VStack(spacing: 16) {
                    Text("Enter invite code")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.ticku.textPrimary)

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
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                .padding(.horizontal, 24)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3), value: showJoin)
            }
        }
    }
}
