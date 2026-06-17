//
//  ProfileView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ProfileViewModel()

    var onBack: () -> Void = {}
    var onSettings: () -> Void = {}
    var onSeeAllChallenges: () -> Void = {}

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Nav Bar ───────────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.ticku.textPrimary)
                    }
                    Spacer()
                    Text("Profile")
                        .font(Font.ticku.sectionHeader)
                        .foregroundColor(Color.ticku.textPrimary)
                    Spacer()
                    Button(action: onSettings) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.ticku.accent)
                    }
                }
                .padding(.horizontal, TickuSpacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // ── Avatar ────────────────────────────────
                AvatarView(
                    imageURL: nil,
                    size: 100,
                    base64: vm.profile?.profileImageBase64
                )
                .padding(.bottom, 12)

                // ── Name + Streak ─────────────────────────
                HStack(spacing: 6) {
                    Text(vm.profile?.displayName ?? "")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color.ticku.textPrimary)
                    Text("×\(vm.profile?.currentStreak ?? 0)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.ticku.textPrimary)
                    Text("🔥")
                        .font(.system(size: 15))
                }

                // ── Handle ── fixed: no double @ ─────────
                // handle field already has @ prefix from SettingsVM
                // displayName fallback should NOT add @
                Text(handleText)
                    .font(.system(size: 15))
                    .foregroundColor(Color.ticku.textSecondary)
                    .padding(.top, 4)
                    .padding(.bottom, 24)

                // ── Stats Pill ────────────────────────────
                statsPill
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.bottom, 24)

                // ── Badges ────────────────────────────────
                badgesSection
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.bottom, 24)

                // ── All Challenges ────────────────────────
                challengesSection
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.bottom, 32)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            if let uid = authVM.currentUserId {
                await vm.load(uid: uid)
            }
        }
        .onAppear {
            Task {
                if let uid = authVM.currentUserId {
                    await vm.load(uid: uid)
                }
            }
        }
    }

    // ── Handle display: strip leading @ then re-add once ──
    private var handleText: String {
        let raw = vm.profile?.handle ?? vm.profile?.displayName ?? ""
        let stripped = raw.hasPrefix("@") ? String(raw.dropFirst()) : raw
        return "@\(stripped)"
    }

    // MARK: - Stats Pill
    private var statsPill: some View {
        HStack(spacing: 0) {
            statCell(value: "\(vm.profile?.totalChallengesCompleted ?? 0)", label: "Challenges")
            Divider().frame(height: 40)
            statCell(value: "\(vm.winRate)%", label: "Win Rate")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#E5E5EA"), lineWidth: 1)
        )
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.ticku.textPrimary)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color.ticku.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Badges
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Badges")
                .font(Font.ticku.sectionHeader)
                .foregroundColor(Color.ticku.textPrimary)

            if let badges = vm.profile?.badges, !badges.isEmpty {
                HStack(spacing: 16) {
                    ForEach(Array(badges.enumerated()), id: \.element.id) { index, badge in
                        BadgeTileView(
                            badge: badge,
                            isFeatured: index == badges.count - 1
                        )
                    }
                    Spacer()
                }
            } else {
                Text("Complete challenges to earn badges!")
                    .font(Font.ticku.caption)
                    .foregroundColor(Color.ticku.textSecondary)
            }
        }
    }

    // MARK: - Challenges
    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Challenges")
                    .font(Font.ticku.sectionHeader)
                    .foregroundColor(Color.ticku.textPrimary)
                Spacer()
                Button(action: onSeeAllChallenges) {
                    Text("See all")
                        .font(Font.ticku.smallButton)
                        .foregroundColor(Color.ticku.accent)
                }
            }

            if vm.challenges.isEmpty {
                Text("No challenges yet.")
                    .font(Font.ticku.caption)
                    .foregroundColor(Color.ticku.textSecondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    ForEach(
                        Array(vm.challenges.prefix(3).enumerated()),
                        id: \.element.id
                    ) { index, entry in
                        if index > 0 { Divider().padding(.horizontal, 16) }
                        ChallengeHistoryRow(entry: entry)
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "#E5E5EA"), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - BadgeTileView
private struct BadgeTileView: View {
    let badge: Badge
    var isFeatured: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isFeatured ? Color.ticku.primary : Color(hex: "#F0EEF8"))
                    .frame(width: 70, height: 70)
                Image(systemName: badge.iconName)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(isFeatured ? .white : Color.ticku.primary)
            }
            Text(badge.name)
                .font(Font.ticku.captionBold)
                .foregroundColor(Color.ticku.textSecondary)
        }
    }
}

// MARK: - ChallengeHistoryRow
private struct ChallengeHistoryRow: View {
    let entry: ChallengeHistoryEntry

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#3A3A3C"))
                    .frame(width: 44, height: 44)
                Text(entry.challenge.durationLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.challenge.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.ticku.textPrimary)
                Text(entry.challenge.startDate.monthYear)
                    .font(.system(size: 13))
                    .foregroundColor(Color.ticku.textSecondary)
            }

            Spacer()
            rankView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private var rankView: some View {
        if entry.challenge.status == "active" {
            Text("Active")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.ticku.doneGreen)
        } else if let rank = entry.rank {
            HStack(spacing: 4) {
                Text(rankEmoji(rank)).font(.system(size: 14))
                Text(rankLabel(rank))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(rankColor(rank))
            }
        }
    }

    private func rankEmoji(_ rank: Int) -> String {
        switch rank { case 1: return "🥇"; case 2: return "🥈"; case 3: return "🥉"; default: return "🏅" }
    }
    private func rankLabel(_ rank: Int) -> String {
        switch rank { case 1: return "1st"; case 2: return "2nd"; case 3: return "3rd"; default: return "\(rank)th" }
    }
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color.ticku.winsOrange
        case 2: return Color(hex: "#8E8E93")
        case 3: return Color(hex: "#CD7F32")
        default: return Color.ticku.textSecondary
        }
    }
}

private extension Date {
    var monthYear: String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: self)
    }
}

#Preview {
    ProfileView().environmentObject(AuthViewModel())
}
