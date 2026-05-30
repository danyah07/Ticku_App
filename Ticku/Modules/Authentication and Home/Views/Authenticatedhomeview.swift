//
//  Authenticatedhomeview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

//
//  Authenticatedhomeview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

import SwiftUI

struct AuthenticatedHomeView: View {
    @ObservedObject var vm: HomeViewModel

    var onSeeAllChallenges: () -> Void
    var onCreateChallenge: () -> Void
    var onJoinChallenge: () -> Void
    var onViewRoom: (Challenge) -> Void
    var onMyTasks: (Challenge) -> Void
    var onProfile: () -> Void

    var body: some View {
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
                        AvatarView(
                            imageURL: vm.currentUser?.profileImageURL,
                            size: 50
                        )
                    }
                }
                .padding(.horizontal, TickuSpacing.screenH)
                .padding(.top, TickuSpacing.lg)
                .padding(.bottom, TickuSpacing.xl)

                // ── Today's Tasks ─────────────────────────
                Text("Today's Tasks")
                    .font(Font.ticku.sectionHeader)
                    .foregroundColor(Color.ticku.textPrimary)
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.bottom, TickuSpacing.md)

                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: TickuRadius.lg)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        .overlay(
                            ProgressRingView(
                                // progressPercent is 0–100 from Firestore;
                                // ProgressRingView expects 0.0–1.0
                                percentage: vm.progressPercent / 100
                            )
                        )
                        .frame(height: 160)

                    StatsSidePanelView(
                        tasksCompleted: vm.tasksCompleted,
                        // currentStreak lives in users/{uid}.currentStreak
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
                .padding(.top, TickuSpacing.xl)
                .padding(.bottom, TickuSpacing.md)

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
                    PrimaryButtonView(
                        title: "+ Create",
                        style: .solid,
                        action: onCreateChallenge
                    )
                    PrimaryButtonView(
                        title: "Join",
                        style: .muted,
                        action: onJoinChallenge
                    )
                }
                .padding(.horizontal, TickuSpacing.screenH)
                .padding(.top, TickuSpacing.lg)
                .padding(.bottom, TickuSpacing.xxl)
            }
        }
        // ✅ FIX: was `$vm.currentUser?.uid` — $vm gives a Binding<HomeViewModel>,
        // you cannot optional-chain into a Binding. Read directly from vm instead.
        .refreshable {
            if let uid = vm.currentUser?.uid {
                await vm.loadHome(for: uid)
            }
        }
    }
}
