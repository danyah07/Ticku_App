//
//  ChallengesListView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct ChallengeCompleteView: View {

    let players: [Player]
    let challengeRule: String
    var onDone: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var sortedPlayers: [Player] {
        players.sorted { $0.progress > $1.progress }
    }

    var lastPlayer: Player? { sortedPlayers.last }

    // ✅ من كود صديقتك — يحدد لو التحدي Solo (شخص واحد بس) أو Group
    private var isSolo: Bool { players.count <= 1 }
    private var soloPlayer: Player? { players.first }
    private var soloProgress: Double { soloPlayer?.progress ?? 0 }
    private var isSoloComplete: Bool { soloProgress >= 1 }

    private var unfinishedTasksCount: Int {
        guard let player = soloPlayer else { return 0 }
        return max(player.totalTasks - player.completedTasks, 0)
    }

    var body: some View {
        ZStack {
            backgroundView

            if isSolo {
                // ✅ شاشة خاصة بالتحدي الفردي (من كود صديقتك)
                soloResultView
            } else {
                // ✅ شاشة التحدي الجماعي (منطقك الأساسي — بدون أي تغيير)
                VStack(spacing: 12) {
                    Spacer().frame(height: 20)
                    badgeSection
                    playersSection
                    loserSection
                    Spacer()
                    continueButton
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            LinearGradient(
                colors: [
                    Color(hex: "#000000"),
                    Color(hex: "#0A0814"),
                    Color(hex: "#2A2150"),
                    Color(hex: "#3D3163")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            Color.white.ignoresSafeArea()
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - SOLO (تحدي فردي) — من كود صديقتك
    // ═══════════════════════════════════════════════

    private var soloResultView: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 20)

            soloBadgeSection
            soloProgressSection

            Spacer()

            soloMessageCard
                .padding(.bottom, 28)

            continueButton
        }
        .padding(.horizontal, 24)
    }

    private var soloBadgeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("CHALLENGE")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))

                Text(isSoloComplete ? "COMPLETE" : "FAILED")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                    .padding(.leading, isSoloComplete ? 70 : 95)
            }

            Spacer()

            Image(systemName: isSoloComplete ? "trophy" : "xmark.circle")
                .font(.system(size: 46, weight: .medium))
                .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
        }
        .padding(.horizontal, 24)
        .frame(width: 343, height: 86)
        .background(soloBadgeBackgroundView)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
        .padding(.top, -15)
    }

    private var soloProgressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ME")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))

                Spacer()

                Text("\(Int(soloProgress * 100))%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isDark ? Color.white.opacity(0.85) : Color(hex: "#D9D9D9"))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#774FDF"))
                        .frame(width: geo.size.width * soloProgress, height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 25)
        .frame(width: 350, height: 80)
        .background(isDark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.35) : Color(hex: "#A1A1A1"), lineWidth: 1)
        )
    }

    private var soloMessageCard: some View {
        VStack(spacing: 9) {
            if isSoloComplete {
                HStack(spacing: 4) {
                    Text("YOU win")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(Color(hex: "#2ECC71"))

                    Text("all tasks done on time 🎉")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                }

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "#FF6B6B"))

                    Text("2 day streak")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                }
            } else {
                HStack(spacing: 4) {
                    Text("YOU lose")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.red)

                    Text("\(unfinishedTasksCount) tasks left undone")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                }

                Text(challengeRule)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(isDark ? .white : .gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(isDark ? Color.white.opacity(0.08) : Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.25) : Color.gray.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 3)
    }

    private var soloBadgeBackgroundView: some View {
        Group {
            if isDark {
                Color(hex: "#8E8AC5").opacity(0.15)
            } else {
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "#E8E4F5"), location: 0.0),
                        .init(color: Color(hex: "#F6F4FC"), location: 0.45),
                        .init(color: Color.white, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - GROUP (تحدي جماعي) — منطقك الأساسي، بدون أي تغيير
    // ═══════════════════════════════════════════════

    // MARK: - Challenge Complete Badge
    @ViewBuilder
    private var badgeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("CHALLENGE")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                Text("COMPLETE")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                    .padding(.leading, 70)
            }
            Spacer()
            Image(systemName: "trophy")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(badgeBackgroundView)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isDark ? Color(hex: "#B296EB").opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var badgeBackgroundView: some View {
        if isDark {
            Color(hex: "#3D3163").opacity(0.4)
        } else {
            lightBadgeGradient
        }
    }

    private var lightBadgeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#EDE9F8"),
                Color(hex: "#E0DBF2"),
                Color(hex: "#F5F3FC")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Players
    @ViewBuilder
    private var playersSection: some View {
        VStack(spacing: 10) {
            ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { index, player in
                playerRow(player: player, rank: index + 1)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    // MARK: - Loser Card
    @ViewBuilder
    private var loserSection: some View {
        if let loser = lastPlayer {
            VStack(alignment: .center, spacing: 4) {
                HStack(spacing: 4) {
                    Text(loser.isMe ? "You" : loser.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                    Text("ranked last with \(Int(loser.progress * 100))% completion")
                        .font(.system(size: 13))
                        .foregroundColor(isDark ? Color(hex: "#8E8AC5") : .black.opacity(0.6))
                }
                Text(challengeRule)
                    .font(.system(size: 20, weight: .black))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isDark ? .white : Color(hex: "#341D71").opacity(0.45))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(isDark ? Color(hex: "#1C1C28") : Color(hex: "#F5F3FC"))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.2) : Color(hex: "#E2DDEF"), lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Continue → يرجع للهوم
    @ViewBuilder
    private var continueButton: some View {
        Button(action: { onDone() }) {
            Text("Continue")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color(hex: "#341D71"))
                .cornerRadius(25)
        }
        .padding(.bottom, 40)
    }

    @ViewBuilder
    private func playerRow(player: Player, rank: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(player.isMe ? "You" : player.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isDark ? Color(hex: "#B296EB") : .black)
                Spacer()
                Text("\(Int(player.progress * 100))%")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isDark ? .white : .black)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isDark ? Color.white.opacity(0.15) : Color(hex: "#E8E4F5"))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor(for: rank))
                        .frame(width: geo.size.width * player.progress, height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 22)
        .background(isDark ? Color.white.opacity(0.03) : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDark ? Color(hex: "#B296EB").opacity(0.25) : Color(hex: "#E8E4F5"), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(isDark ? 0 : 0.04), radius: 4, x: 0, y: 2)
    }

    // ترتيب الفوزر (progress bar): #1 غامق → #4 فاتح
    private func progressColor(for rank: Int) -> Color {
        switch rank {
        case 1: return Color(hex: "#341D71")
        case 2: return Color(hex: "#774FDF")
        case 3: return Color(hex: "#A48EE0")
        default: return Color(hex: "#C2BEFF")
        }
    }
}

// MARK: - PREVIEW

#Preview("Group Light") {
    ChallengeCompleteView(
        players: [
            Player(name: "LYAN",    rank: 1, isMe: false, completedTasks: 24, totalTasks: 25),
            Player(name: "Danyah",  rank: 2, isMe: true,  completedTasks: 17, totalTasks: 25),
            Player(name: "Nawarah", rank: 3, isMe: false, completedTasks: 10, totalTasks: 25),
            Player(name: "Aryam",   rank: 4, isMe: false, completedTasks: 7,  totalTasks: 25),
        ],
        challengeRule: "100 push-ups"
    )
}

#Preview("Group Dark") {
    ChallengeCompleteView(
        players: [
            Player(name: "LYAN",    rank: 1, isMe: false, completedTasks: 24, totalTasks: 25),
            Player(name: "Danyah",  rank: 2, isMe: true,  completedTasks: 17, totalTasks: 25),
            Player(name: "Nawarah", rank: 3, isMe: false, completedTasks: 10, totalTasks: 25),
            Player(name: "Aryam",   rank: 4, isMe: false, completedTasks: 7,  totalTasks: 25),
        ],
        challengeRule: "100 push-ups"
    )
    .preferredColorScheme(.dark)
}

#Preview("Solo Complete") {
    ChallengeCompleteView(
        players: [
            Player(name: "Danyah", rank: 1, isMe: true, completedTasks: 4, totalTasks: 4)
        ],
        challengeRule: "100 push-ups"
    )
}

#Preview("Solo Failed") {
    ChallengeCompleteView(
        players: [
            Player(name: "Danyah", rank: 1, isMe: true, completedTasks: 2, totalTasks: 4)
        ],
        challengeRule: "100 push-ups"
    )
}
