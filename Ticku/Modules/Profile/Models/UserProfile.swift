//
//  UserProfile.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  ProfileModels.swift
//  firebasetrial

//
//  ProfileModels.swift
//  firebasetrial

//
//  ProfileModels.swift
//  firebasetrial

import Foundation
import FirebaseFirestore

// MARK: - Badge
struct Badge: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String = ""
    var iconName: String = "star.fill"
    var earnedAt: Date? = nil
}

// MARK: - UserProfile
// Mirrors EXACTLY what is stored in Firestore users/{uid}
struct UserProfile: Codable {
    @DocumentID var id: String?

    // ── Exact Firestore field names ───────────────────────
    var uid: String = ""
    var displayName: String = ""
    var profileImageURL: String? = nil
    var email: String = ""
    var appleUserIdentifier: String? = nil
    var totalChallengesCompleted: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActiveDate: Date? = nil
    var createdAt: Date? = nil

    // ── Future fields — optional so decode never fails ────
    var username: String? = nil
    var handle: String? = nil
    var totalWins: Int = 0
    var badges: [Badge] = []
}

// MARK: - ChallengeHistoryEntry
struct ChallengeHistoryEntry: Identifiable {
    var id: String { challenge.id ?? UUID().uuidString }
    let challenge: Challenge
    let rank: Int?
}
