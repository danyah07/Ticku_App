//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 12/01/1448 AH.
//

import SwiftUI

// صفحة منفصلة تعرض كل التحديات المكتملة بالكامل (مش بس أول 3)
// يفتحها زر "See all" بصفحة البروفايل
struct CompletedChallengesView: View {

    let challenges: [ChallengeHistoryEntry]
    var onBack: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Nav Bar ───────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
                    }
                    Spacer()
                    Text("All Challenges")
                        .font(Font.ticku.sectionHeader)
                        .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, TickuSpacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 20)

                if challenges.isEmpty {
                    Text("No completed challenges yet.")
                        .font(Font.ticku.caption)
                        .foregroundColor(isDark ? .white.opacity(0.5) : Color.ticku.textSecondary)
                        .padding(.top, 60)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(challenges.enumerated()), id: \.element.id) { index, entry in
                            if index > 0 {
                                Divider().padding(.horizontal, 16)
                            }
                            ChallengeHistoryRowFull(entry: entry)
                        }
                    }
                    .background(isDark ? Color.white.opacity(0.04) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isDark ? Color(hex: "#B296EB").opacity(0.15) : Color(hex: "#E5E5EA"), lineWidth: 1)
                    )
                    .padding(.horizontal, TickuSpacing.screenH)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(isDark ? Color(hex: "#0A0814").ignoresSafeArea() : Color(hex: "#F5F4FA").ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// نفس تصميم ChallengeHistoryRow الموجود بصفحة البروفايل (مستخرج كـ View مستقل قابل لإعادة الاستخدام)
struct ChallengeHistoryRowFull: View {
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
                    .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
                Text(entry.challenge.startDate.monthYearShort)
                    .font(.system(size: 13))
                    .foregroundColor(isDark ? .white.opacity(0.5) : Color.ticku.textSecondary)
            }

            Spacer()

            if let rank = entry.rank {
                HStack(spacing: 4) {
                    Text(rankEmoji(rank)).font(.system(size: 14))
                    Text(rankLabel(rank))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(rankColor(rank))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
        default: return isDark ? .white.opacity(0.5) : Color.ticku.textSecondary
        }
    }
}

private extension Date {
    var monthYearShort: String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: self)
    }
}

#Preview("Light") {
    CompletedChallengesView(challenges: [])
}

#Preview("Dark") {
    CompletedChallengesView(challenges: [])
        .preferredColorScheme(.dark)
}
