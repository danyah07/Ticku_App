//
//  PlayerCard.swift
//  firebasetrial
//
//  Created by Jumana on 10/12/1447 AH.
//

import SwiftUI

struct PlayerCard: View {

    let player: Player
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {

        VStack(spacing: 8) {


            // MARK: - Progress Circle
            
            ZStack {

                Circle()
                    .stroke(isDark ? Color.white.opacity(0.15) : Color(hex: "#D9D5F0"), lineWidth: 7)
                    .frame(width: 90, height: 90)

                // الحلقة الداكنة — تتعبأ بقدر النسبة فوق الفاتحة
                if player.progress > 0 {
                    Circle()
                        .trim(from: 0.0, to: player.progress)
                        .stroke(
                            isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71"),
                            style: StrokeStyle(lineWidth: 7, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: player.progress)
                }

                // خلفية دائرة داخلية رمادية
                Circle()
                    .fill(isDark ? Color.white.opacity(0.1) : Color(hex: "#E8E4F0"))
                    .frame(width: 74, height: 74)

                // أيقونة الشخص
                Image(systemName: "person.fill")
                    .font(.system(size: 34))
                    .foregroundColor(isDark ? .white.opacity(0.7) : Color(hex: "#341D71"))
            }
            .frame(width: 100, height: 100)
            .padding(.top, 16)

            // MARK: - Name
            Text(player.isMe ? "ME" : player.name.uppercased())
                .font(.system(size: 14, weight: .black))
                .foregroundColor(isDark ? .white : Color(hex: "#341D71"))

            // MARK: - Progress %
            Text(player.progressText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isDark ? .white.opacity(0.5) : Color(hex: "#9E9E9E"))

            // MARK: - Rank badge
            Text("#\(player.rank)")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
                .background(isDark ? Color.white.opacity(0.9) : Color.white)
                .cornerRadius(30)

            Spacer(minLength: 4)
        }
        .frame(height: 210)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? Color.white.opacity(0.04) : Color.white.opacity(0.30))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(isDark ? Color(hex: "#B296EB").opacity(0.35) : Color(hex: "#8EBAC5").opacity(0.45), lineWidth: 1)
                )
        )
    }
}

#Preview("Light") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#FFFFFF"), Color(hex: "#7B5BC7")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            PlayerCard(player: Player(name: "ME",    rank: 1, isMe: true,  completedTasks: 6, totalTasks: 10))
            PlayerCard(player: Player(name: "NAME1", rank: 2, isMe: false, completedTasks: 4, totalTasks: 10))
            PlayerCard(player: Player(name: "NAME2", rank: 3, isMe: false, completedTasks: 2, totalTasks: 10))
            PlayerCard(player: Player(name: "NAME3", rank: 4, isMe: false, completedTasks: 3, totalTasks: 10))
        }
        .padding(20)
    }
}

#Preview("Dark") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "#0A0814"), Color(hex: "#5B4A8F")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            PlayerCard(player: Player(name: "ME",    rank: 1, isMe: true,  completedTasks: 6, totalTasks: 10))
            PlayerCard(player: Player(name: "NAME1", rank: 2, isMe: false, completedTasks: 4, totalTasks: 10))
            PlayerCard(player: Player(name: "NAME2", rank: 3, isMe: false, completedTasks: 2, totalTasks: 10))
            PlayerCard(player: Player(name: "NAME3", rank: 4, isMe: false, completedTasks: 3, totalTasks: 10))
        }
        .padding(20)
    }
    .preferredColorScheme(.dark)
}
