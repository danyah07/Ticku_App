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
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var onBack: () -> Void = {}
    var onSettings: () -> Void = {}
    var onSeeAllChallenges: ([ChallengeHistoryEntry]) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    AvatarView(
                        imageURL: nil,
                        size: 100,
                        base64: vm.profile?.profileImageBase64
                    )
                    .padding(.bottom, 16)

                    HStack(spacing: 4) {
                        Text(vm.profile?.displayName.isEmpty == false ? vm.profile!.displayName : "Ticku User")
                            .font(.system(size: 27, weight: .black, design: .rounded))
                            .foregroundColor(isDark ? .white : .black)

                        Text("×\(vm.profile?.currentStreak ?? 0)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isDark ? .white : .black)

                        Text("🔥")
                            .font(.system(size: 15))
                    }

                    Text(handleText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isDark ? .white.opacity(0.55) : Color.black.opacity(0.45))
                        .padding(.bottom, 25)

                    statsPill
                        .frame(width: 349, height: 65)
                        .padding(.bottom, 22)

                    challengesSection
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                }
                .padding(.top, 85)
            }

            fixedHeader
        }
        .navigationBarHidden(true)
        .task(id: authVM.currentUserId) {
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

    private var fixedHeader: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isDark ? .white : .black)
            }
            Spacer()

            Text("Profile")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isDark ? .white : Color.black.opacity(0.65))

            Spacer()

            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(isDark ? .white : Color(hex: "#341D71"))
            }
        }
        .padding(.horizontal, 21)
        .padding(.top, 1)
        .padding(.bottom, 20)
        .background(isDark ? Color.black : Color.white)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            Color.black.ignoresSafeArea()
        } else {
            Color.white.ignoresSafeArea()
        }
    }

    private var handleText: String {
        let raw = vm.profile?.handle ?? vm.profile?.displayName ?? ""
        let stripped = raw.hasPrefix("@") ? String(raw.dropFirst()) : raw
        return "@\(stripped)"
    }

    private var statsPill: some View {
        HStack(spacing: 0) {
            statCell(value: "\(vm.profile?.totalChallengesCompleted ?? 0)", label: "Challenges")

            Rectangle()
                .fill(isDark ? Color.white.opacity(0.15) : Color(hex: "#EBEBEB"))
                .frame(width: 1, height: 75)

            statCell(value: "\(vm.winRate)%", label: "Win Rate")
        }
        .background(isDark ? Color.white.opacity(0.05) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(isDark ? Color.white.opacity(0.12) : Color(hex: "#EBEBEB"), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isDark ? 0 : 0.15), radius: 9, x: 0, y: 4)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(isDark ? .white : .black)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isDark ? .white.opacity(0.5) : Color.black.opacity(0.35))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("All Challenges")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDark ? .white : Color.black.opacity(0.47))
                    .padding(.top, 37)

                Spacer()

                Button(action: { onSeeAllChallenges(vm.challenges) }) {
                    Text("See all")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#4FA2FF"))
                        .padding(.top, 37)
                }
            }

            if vm.challenges.isEmpty {
                Text("No challenges yet.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isDark ? .white.opacity(0.45) : Color.black.opacity(0.25))
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(vm.challenges.prefix(3).enumerated()), id: \.element.id) { index, entry in
                        if index > 0 {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                        ChallengeHistoryRow(entry: entry)
                    }
                }
                .background(isDark ? Color.white.opacity(0.05) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isDark ? Color.white.opacity(0.12) : Color(hex: "#E5E5EA"), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(isDark ? 0 : 0.12), radius: 9, x: 0, y: 2)
            }
        }
    }
}

private struct ChallengeHistoryRow: View {
    let entry: ChallengeHistoryEntry
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

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
                    .foregroundColor(isDark ? .white : .black)

                Text(entry.challenge.startDate.monthYear)
                    .font(.system(size: 13))
                    .foregroundColor(isDark ? .white.opacity(0.5) : Color.black.opacity(0.35))
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
                Text(rankEmoji(rank))
                    .font(.system(size: 14))

                Text(rankLabel(rank))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(rankColor(rank))
            }
        }
    }

    private func rankEmoji(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏅"
        }
    }

    private func rankLabel(_ rank: Int) -> String {
        switch rank {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(rank)th"
        }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color.ticku.winsOrange
        case 2: return Color(hex: "#8E8E93")
        case 3: return Color(hex: "#CD7F32")
        default: return isDark ? .white.opacity(0.5) : Color.black.opacity(0.35)
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

#Preview("Light") {
    ProfileView()
        .environmentObject(AuthViewModel())
}

#Preview("Dark") {
    ProfileView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
