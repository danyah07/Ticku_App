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

    @Environment(\.dismiss) private var dismiss

    var sortedPlayers: [Player] {
        players.sorted { $0.progress > $1.progress }
    }

    var lastPlayer: Player? { sortedPlayers.last }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 12) {

                Spacer().frame(height: 20)

                // MARK: - Challenge Complete Badge
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("CHALLENGE")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(Color(hex: "#341D71"))
                        Text("COMPLETE")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(Color(hex: "#341D71"))
                    }
                    Spacer()
                    Image(systemName: "trophy")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(Color(hex: "#341D71"))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "#EDE9F8"),
                            Color(hex: "#E0DBF2"),
                            Color(hex: "#F5F3FC")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .padding(.horizontal, 24)

                // MARK: - Players
                VStack(spacing: 10) {
                    ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { index, player in
                        playerRow(player: player, rank: index + 1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // MARK: - Loser Card
                if let loser = lastPlayer {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(loser.isMe ? "You" : loser.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "#341D71"))
                            Text("ranked  last with \(Int(loser.progress * 100))% completion")
                                .font(.system(size: 13))
                                .foregroundColor(.black.opacity(0.6))
                        }
                        Text(challengeRule)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(hex: "#341D71").opacity(0.45))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#F5F3FC"))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#E2DDEF"), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                }

                Spacer()

                // MARK: - Continue
                Button(action: { dismiss() }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color(hex: "#341D71"))
                        .cornerRadius(25)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func playerRow(player: Player, rank: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(player.isMe ? "You" : player.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text("\(Int(player.progress * 100))%")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#E8E4F5"))
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
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E8E4F5"), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func progressColor(for rank: Int) -> Color {
        switch rank {
        case 1: return Color(hex: "#341D71")
        case 2: return Color(hex: "#7B5BC7")
        case 3: return Color(hex: "#A899DC")
        default: return Color(hex: "#C4BCEC")
        }
    }
}

#Preview {
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
