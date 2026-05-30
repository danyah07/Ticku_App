//
//  Homemodels.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

import Foundation

// MARK: - TodayStats
// Derived/cached struct — not a Firestore document.
// Computed from users/{uid}/dailyStats/{date} + UserProfile.totalWins
struct TodayStats {
    var completionPercentage: Double    // 0.0 – 1.0
    var tasksDone: Int
    var wins: Int

    static let empty = TodayStats(completionPercentage: 0, tasksDone: 0, wins: 0)
}
