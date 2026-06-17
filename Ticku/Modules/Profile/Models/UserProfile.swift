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
// Mirrors exactly what is stored in Firestore users/{uid}
struct UserProfile: Codable {
    @DocumentID var id: String?
    var uid: String = ""
    var displayName: String = ""
    var profileImageURL: String? = nil
    var profileImageBase64: String? = nil
    var email: String = ""
    var appleUserIdentifier: String? = nil
    var totalChallengesCompleted: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActiveDate: Date? = nil
    var createdAt: Date? = nil

    // Future fields — optional so decode never fails
    var username: String? = nil
    var handle: String? = nil
    var totalWins: Int = 0
    var badges: [Badge] = []
}

// MARK: - ChallengeHistoryEntry
// Lightweight display model — not a direct Firestore document
struct ChallengeHistoryEntry: Identifiable {
    var id: String { challenge.id ?? UUID().uuidString }
    let challenge: Challenge
    let rank: Int?
}
