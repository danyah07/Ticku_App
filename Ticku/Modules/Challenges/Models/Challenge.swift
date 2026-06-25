//
//  Challenge.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  Challenge.swift
//  firebasetrial

import Foundation
import FirebaseFirestore

// MARK: - Challenge
struct Challenge: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String = ""
    var description: String = ""
    var createdBy: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var status: String = "active"
    var memberCount: Int = 0
    var createdAt: Date = Date()
    var memberIds: [String] = []
    var challengeType: String = "group"   // "solo" أو "group"

    var isActive: Bool { status == "active" }
    var isSolo: Bool { challengeType == "solo" }

    var daysLeft: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
    }

    var durationLabel: String {
        let days  = Calendar.current.dateComponents([.day],  from: startDate, to: endDate).day  ?? 0
        let hours = Calendar.current.dateComponents([.hour], from: startDate, to: endDate).hour ?? 0
        return days >= 1 ? "\(days)d" : "\(hours)h"
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Challenge, rhs: Challenge) -> Bool { lhs.id == rhs.id }
}

// MARK: - ChallengeMember
struct ChallengeMember: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userId: String = ""
    var displayName: String = ""
    var profileImageURL: String? = nil
    var progressPercent: Double = 0
    var tasksTotal: Int = 0
    var tasksCompleted: Int = 0
    var joinedAt: Date = Date()
    var role: String = "member"

    static func == (lhs: ChallengeMember, rhs: ChallengeMember) -> Bool {
        lhs.id == rhs.id &&
        lhs.progressPercent == rhs.progressPercent &&
        lhs.tasksCompleted == rhs.tasksCompleted
    }
}

// MARK: - TickuTask
struct TickuTask: Identifiable, Codable {
    @DocumentID var id: String?
    var ownerId: String = ""
    var title: String = ""
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var dueDate: Date? = nil
    var createdAt: Date = Date()
}
