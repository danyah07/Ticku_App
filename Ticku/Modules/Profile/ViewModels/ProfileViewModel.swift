//
//  ProfileViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  ProfileViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  ProfileViewModel.swift
//  firebasetrial

//
//  ProfileViewModel.swift
//  firebasetrial

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var profile: UserProfile? = nil
    @Published var challenges: [ChallengeHistoryEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    // MARK: - Computed
    var winRate: Int {
        let completed = challenges.filter { $0.challenge.status != "active" }
        guard !completed.isEmpty else { return 0 }
        let wins = completed.filter { $0.rank == 1 }.count
        return Int(Double(wins) / Double(completed.count) * 100)
    }

    // MARK: - Load
    func load(uid: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let profileFetch    = fetchProfile(uid: uid)
            async let challengesFetch = fetchChallengeHistory(uid: uid)
            let (p, c) = try await (profileFetch, challengesFetch)
            profile    = p
            challenges = c
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private
    private func fetchProfile(uid: String) async throws -> UserProfile {
        let doc = try await db
            .collection("users")
            .document(uid)
            .getDocument()

        guard doc.exists else {
            print("⚠️ No user document found for uid: \(uid)")
            return UserProfile(uid: uid, displayName: "Ticku User")
        }

        do {
            return try doc.data(as: UserProfile.self)
        } catch {
            print("⚠️ UserProfile decode failed: \(error.localizedDescription)")
            var fallback = UserProfile()
            fallback.uid = uid
            return fallback
        }
    }

    private func fetchChallengeHistory(uid: String) async throws -> [ChallengeHistoryEntry] {
        let snap = try await db
            .collection("challenges")
            .whereField("memberIds", arrayContains: uid)
            .order(by: "endDate", descending: true)
            .limit(to: 20)
            .getDocuments()

        return snap.documents.compactMap { doc -> ChallengeHistoryEntry? in
            guard let challenge = try? doc.data(as: Challenge.self) else { return nil }
            let rank = doc.data()["rank_\(uid)"] as? Int
            return ChallengeHistoryEntry(challenge: challenge, rank: rank)
        }
    }
}
