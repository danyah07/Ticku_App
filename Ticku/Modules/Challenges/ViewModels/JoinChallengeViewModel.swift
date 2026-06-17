//
//  JoinChallengeViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/06/2026.
//


//
//  JoinChallengeViewModel.swift
//  firebasetrial

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class JoinChallengeViewModel: ObservableObject {

    @Published var inviteCode: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    var isCodeValid: Bool {
        inviteCode.trimmingCharacters(in: .whitespaces).count >= 4
    }

    func joinChallenge(userId: String, displayName: String) async -> Challenge? {
        let code = inviteCode.trimmingCharacters(in: .whitespaces).uppercased()
        guard !code.isEmpty else {
            errorMessage = "Please enter an invite code."
            return nil
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let snap = try await db
                .collection("challenges")
                .whereField("inviteCode", isEqualTo: code)
                .whereField("status", isEqualTo: "active")
                .limit(to: 1)
                .getDocuments()

            guard let doc = snap.documents.first else {
                errorMessage = "No active challenge found with this code."
                return nil
            }

            let data = doc.data()
            let challengeId = doc.documentID

            // Manual parsing عشان نتجاوز مشكلة startDate null
            let title = data["title"] as? String ?? ""
            let description = data["description"] as? String ?? ""
            let createdBy = data["createdBy"] as? String ?? ""
            let status = data["status"] as? String ?? "active"
            let memberCount = data["memberCount"] as? Int ?? 0
            let memberIds = data["memberIds"] as? [String] ?? []
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
            let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date.distantFuture

            var challenge = Challenge(
                id: challengeId,
                title: title,
                description: description,
                createdBy: createdBy,
                startDate: startDate,
                endDate: endDate,
                status: status,
                memberCount: memberCount,
                createdAt: createdAt,
                memberIds: memberIds
            )

            // Already a member
            if memberIds.contains(userId) {
                return challenge
            }

            // Full
            if memberCount >= 4 {
                errorMessage = "This challenge is full (max 4 players)."
                return nil
            }

            // Add member
            let now = Date()
            let memberData: [String: Any] = [
                "userId":          userId,
                "displayName":     displayName,
                "profileImageURL": NSNull(),
                "progressPercent": 0.0,
                "tasksTotal":      0,
                "tasksCompleted":  0,
                "joinedAt":        Timestamp(date: now),
                "role":            "member"
            ]

            let challengeRef = db.collection("challenges").document(challengeId)
            let batch = db.batch()
            let memberRef = challengeRef.collection("members").document(userId)
            batch.setData(memberData, forDocument: memberRef)
            batch.updateData([
                "memberIds":   FieldValue.arrayUnion([userId]),
                "memberCount": FieldValue.increment(Int64(1))
            ], forDocument: challengeRef)
            try await batch.commit()

            challenge.memberIds.append(userId)
            challenge.memberCount += 1
            return challenge

        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
