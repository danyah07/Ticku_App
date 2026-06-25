//
//  Untitled.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 27/05/2026.
//

//  SharedComponents.swift
//  firebasetrial

import SwiftUI


// MARK: - StatsSidePanelView
struct StatsSidePanelView: View {
    let tasksCompleted: Int
    let wins: Int

    var body: some View {
        VStack(spacing: 10) {
            statCard(
                icon: "checkmark.circle.fill",
                value: "\(tasksCompleted)",
                label: "Done",
                color: Color(hex: "#6B5CE7")
            )
            statCard(
                icon: "trophy.fill",
                value: "\(wins)",
                label: "Wins",
                color: Color(hex: "#FF6B6B")
            )
        }
    }

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
            .overlay(
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(value)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#1A1A2E"))
                        Text(label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "#8B8B9E"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
            )
            .frame(maxWidth: .infinity)
    }
}


// MARK: - ActiveChallengeCardView
struct ActiveChallengeCardView: View {
    let challenge: Challenge
    var onViewRoom: () -> Void
    var onMyTasks: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 5)
            .overlay(
                VStack(alignment: .leading, spacing: 14) {
                    // Title row
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(challenge.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "#1A1A2E"))
                                .lineLimit(1)
                            Text(challenge.description)
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#8B8B9E"))
                                .lineLimit(1)
                        }
                        Spacer()
                        // Days left badge
                        Text("\(challenge.daysLeft)d left")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#6B5CE7"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#EDE9FF"))
                            .clipShape(Capsule())
                    }

                    // Members count
                    HStack(spacing: 5) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8B8B9E"))
                        Text("\(challenge.memberCount) members · \(challenge.durationLabel)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8B8B9E"))
                    }

                    // Action buttons
                    HStack(spacing: 10) {
                        Button(action: onViewRoom) {
                            Text("View Room")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(Color(hex: "#6B5CE7"))
                                .clipShape(Capsule())
                        }
                        Button(action: onMyTasks) {
                            Text("My Tasks")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B5CE7"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(Color(hex: "#EDE9FF"))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(18)
            )
            .frame(height: 165)
    }
}
