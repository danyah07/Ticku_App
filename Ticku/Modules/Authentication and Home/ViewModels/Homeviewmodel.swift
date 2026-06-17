//
//  Homeviewmodel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

//
//  Homeviewmodel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

import Foundation
import FirebaseFirestore
import Combine

// ─────────────────────────────────────────────────────────
// TickuUser — defined here because it's only used for home/profile
// All other models (Challenge, ChallengeMember, TickuTask) live in Challenge.swift
// ─────────────────────────────────────────────────────────

struct TickuUser: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String = ""
    var displayName: String = ""
    var profileImageURL: String? = nil
    var email: String = ""
    var appleUserIdentifier: String? = nil
    var totalChallengesCompleted: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActiveDate: Date? = nil
    var createdAt: Date = Date()
}

// ─────────────────────────────────────────────────────────
// HOME VIEW MODEL
// ─────────────────────────────────────────────────────────

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var currentUser: TickuUser? = nil
    @Published var activeChallenges: [Challenge] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    @Published var progressPercent: Double = 0
    @Published var tasksCompleted: Int = 0
    @Published var tasksTotal: Int = 0

    private let db = Firestore.firestore()

    func loadHome(for uid: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            currentUser      = try await fetchUser(uid: uid)
            activeChallenges = try await fetchActiveChallenges(uid: uid)
            if let first = activeChallenges.first, let cid = first.id {
                try await fetchMyProgress(challengeId: cid, uid: uid)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        currentUser      = nil
        activeChallenges = []
        progressPercent  = 0
        tasksCompleted   = 0
        tasksTotal       = 0
    }

    private func fetchUser(uid: String) async throws -> TickuUser {
        let doc = try await db.collection("users").document(uid).getDocument()
        return try doc.data(as: TickuUser.self)
    }

    private func fetchActiveChallenges(uid: String) async throws -> [Challenge] {
        let snap = try await db
            .collection("challenges")
            .whereField("status", isEqualTo: "active")
            .whereField("memberIds", arrayContains: uid)
            .order(by: "endDate")
            .limit(to: 5)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Challenge.self) }
    }

    private func fetchMyProgress(challengeId: String, uid: String) async throws {
        let doc = try await db
            .collection("challenges").document(challengeId)
            .collection("members").document(uid)
            .getDocument()
        let member = try doc.data(as: ChallengeMember.self)
        progressPercent = member.progressPercent
        tasksCompleted  = member.tasksCompleted
        tasksTotal      = member.tasksTotal
    }
}
