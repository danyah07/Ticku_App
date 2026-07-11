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
    var tasks: [ChallengeTask] = []  // ✅ التاسكات الحقيقية للسولو
    var onDone: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var sortedPlayers: [Player] {
        players.sorted { $0.progress > $1.progress }
    }

    var lastPlayer: Player? { sortedPlayers.last }

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
                soloResultView
            } else {
                VStack(spacing: 29) {
                    Spacer().frame(height: 2)
                    badgeSection
                    playersSection
                    loserSection
                    Spacer(minLength: 28)
                    continueButton
                }
                .padding(.horizontal, 23)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            LinearGradient(
                colors: [Color.black, Color(hex: "#120C24"), Color(hex: "#261A45")],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
        } else {
            Color.white.ignoresSafeArea()
        }
    }

    private var soloResultView: some View {
        VStack(spacing: 29) {
            Spacer().frame(height: 2)
            soloBadgeSection
            soloProgressSection

            // ✅ قائمة المهام الحقيقية — الي خلصها تشيك، الي ما خلصها لا
            if let player = soloPlayer, player.totalTasks > 0 {
                soloTasksList(player: player)
            }

            Spacer()
            soloMessageCard
            continueButton
        }
        .padding(.horizontal, 23)
    }

    private var soloBadgeSection: some View {
        badgeView(
            statusText: isSoloComplete ? NSLocalizedString("complete", comment: "") : NSLocalizedString("failed", comment: ""),
            iconName: isSoloComplete ? "trophy" : "xmark.circle"
        )
    }

    private var badgeSection: some View {
        badgeView(statusText: NSLocalizedString("complete", comment: ""), iconName: "trophy")
    }

    private func badgeView(statusText: String, iconName: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: -2) {
                Text(NSLocalizedString("challenge", comment: ""))
                    .font(.system(size: 24, weight: .black))
                Text(statusText)
                    .font(.system(size: 24, weight: .black))
                    .padding(.leading, statusText == NSLocalizedString("failed", comment: "") ? 95 : 56)
            }
            .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
            Spacer()
            Image(systemName: iconName)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
        }
        .padding(.horizontal, 24)
        .frame(width: 343, height: 86)
        .background(badgeBackgroundView)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
    }

    private var badgeBackgroundView: some View {
        LinearGradient(
            stops: isDark
            ? [
                .init(color: Color(hex: "#8E8AC5").opacity(0.15), location: 0),
                .init(color: Color(hex: "#341D71").opacity(0.57), location: 1)
            ]
            : [
                .init(color: Color(hex: "#8E8AC5"), location: -15),
                .init(color: Color(hex: "#E9E4F8"), location: 0.30),
                .init(color: .white, location: 1)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var soloProgressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(NSLocalizedString("me", comment: ""))
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                Spacer()
                Text("\(Int(soloProgress * 100))%")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                    .environment(\.locale, Locale(identifier: "en_US"))
            }
            progressBar(progress: soloProgress, color: Color(hex: "#341D71"))
        }
        .padding(.horizontal, 18)
        .frame(width: 350, height: 80)
        .liquidGlass(tint: isDark ? Color.black.opacity(0.25) : Color.white, cornerRadius: 15, intensity: 1)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.25) : Color(hex: "#A1A1A1"), lineWidth: 1))
    }

    // ✅ مهام حقيقية من الـ tasks — اسم كل تاسك الي كتبه اليوزر
    private func soloTasksList(player: Player) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if tasks.isEmpty {
                // لو ما في تاسكات ممررة، نعرض أرقام فقط
                ForEach(0..<player.totalTasks, id: \.self) { index in
                    soloTaskRow(title: "Task \(index + 1)", done: index < player.completedTasks)
                }
            } else {
                // ✅ نعرض الأسماء الحقيقية — المكتملة تشيك، الباقي لا
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    soloTaskRow(title: task.title, done: task.isCompleted)
                }
            }
        }
        .padding(.top, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func soloTaskRow(title: String, done: Bool) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.clear)
                .frame(width: 30, height: 30)
                .liquidGlass(
                    tint: done ? Color(hex: "#341D71") : Color(hex: "#C9C9C9"),
                    cornerRadius: 6, intensity: 1
                )
                .overlay {
                    if done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isDark ? .white : .black)
                .strikethrough(done)
        }
        .padding(.leading, 8)
    }

    private var soloMessageCard: some View {
        VStack(spacing: 6) {
            if isSoloComplete {
                // ✅ شلنا Streak — بس رسالة فوز بدون ذكر streak
                Text(NSLocalizedString("you_win_all_tasks", comment: ""))
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(Color(hex: "#2ECC71"))
            } else {
                Text("\(NSLocalizedString("you_lose", comment: "")) \(unfinishedTasksCount) \(NSLocalizedString("tasks_left_undone", comment: ""))")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.red)
                    .environment(\.locale, Locale(identifier: "en_US"))
                Text(challengeRule)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(isDark ? .white : .gray)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 89)
        .liquidGlass(tint: isDark ? Color.black.opacity(0.25) : Color.white, cornerRadius: 15, intensity: 1)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.25) : Color(hex: "#CBCBCB"), lineWidth: 2))
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
    }

    private var playersSection: some View {
        VStack(spacing: 13) {
            ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { index, player in
                playerRow(player: player, rank: index + 1)
            }
        }
    }

    private func playerRow(player: Player, rank: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(player.isMe ? NSLocalizedString("you", comment: "") : player.name)
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                Spacer()
                Text("\(Int(player.progress * 100))%")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                    .environment(\.locale, Locale(identifier: "en_US"))
            }
            progressBar(progress: player.progress, color: progressColor(for: rank))
        }
        .padding(.horizontal, 18)
        .frame(width: 350, height: 80)
        .liquidGlass(tint: isDark ? Color.black.opacity(0.25) : Color.white, cornerRadius: 15, intensity: 1)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.25) : Color(hex: "#A1A1A1"), lineWidth: 1))
    }

    private var loserSection: some View {
        Group {
            if let loser = lastPlayer {
                VStack(spacing: 4) {
                    Text("\(loser.isMe ? NSLocalizedString("you", comment: "") : loser.name) \(NSLocalizedString("ranked_last_with", comment: "")) \(Int(loser.progress * 100))% \(NSLocalizedString("completion", comment: ""))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                        .environment(\.locale, Locale(identifier: "en_US"))
                    Text(challengeRule)
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(isDark ? .white : Color(hex: "#341D71").opacity(0.55))
                }
                .frame(width: 350, height: 89)
                .liquidGlass(tint: isDark ? Color.black.opacity(0.25) : Color.white, cornerRadius: 15, intensity: 1)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.25) : Color(hex: "#CBCBCB"), lineWidth: 2))
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
            }
        }
    }

    private var continueButton: some View {
        Button(action: { onDone() }) {
            Text(NSLocalizedString("continue", comment: ""))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 166, height: 60)
                .liquidGlass(tint: isDark ? Color(hex: "#341D71").opacity(0.57) : Color(hex: "#341D71").opacity(0.88), cornerRadius: 30, intensity: 1)
                .overlay(Capsule().stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.25) : Color(hex: "#CBCBCB"), lineWidth: 1))
        }
        .padding(.bottom, 10)
    }

    private func progressBar(progress: Double, color: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6).fill(isDark ? Color.white.opacity(0.85) : Color(hex: "#D9D9D9")).frame(height: 12)
                RoundedRectangle(cornerRadius: 6).fill(color).frame(width: geo.size.width * progress, height: 12)
            }
        }
        .frame(height: 12)
    }

    private func progressColor(for rank: Int) -> Color {
        switch rank {
        case 1: return Color(hex: "#341D71")
        case 2: return Color(hex: "#774FDF")
        case 3: return Color(hex: "#A48EE0")
        default: return Color(hex: "#C2BEFF")
        }
    }
}

#Preview("Group Light") {
    ChallengeCompleteView(
        players: [
            Player(name: "LYAN", rank: 1, isMe: false, completedTasks: 24, totalTasks: 25),
            Player(name: "Danyah", rank: 2, isMe: true, completedTasks: 17, totalTasks: 25),
            Player(name: "Nawarah", rank: 3, isMe: false, completedTasks: 10, totalTasks: 25),
            Player(name: "Aryam", rank: 4, isMe: false, completedTasks: 7, totalTasks: 25)
        ],
        challengeRule: "100 push-ups"
    )
}

#Preview("Group Dark") {
    ChallengeCompleteView(
        players: [
            Player(name: "LYAN", rank: 1, isMe: false, completedTasks: 24, totalTasks: 25),
            Player(name: "Danyah", rank: 2, isMe: true, completedTasks: 17, totalTasks: 25),
            Player(name: "Nawarah", rank: 3, isMe: false, completedTasks: 10, totalTasks: 25),
            Player(name: "Aryam", rank: 4, isMe: false, completedTasks: 7, totalTasks: 25)
        ],
        challengeRule: "100 push-ups"
    )
    .preferredColorScheme(.dark)
}

#Preview("Solo Complete") {
    ChallengeCompleteView(
        players: [Player(name: "Danyah", rank: 1, isMe: true, completedTasks: 4, totalTasks: 4)],
        challengeRule: "100 push-ups"
    )
}

#Preview("Solo Failed") {
    ChallengeCompleteView(
        players: [Player(name: "Danyah", rank: 1, isMe: true, completedTasks: 2, totalTasks: 4)],
        challengeRule: "100 push-ups"
    )
}
