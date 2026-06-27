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
    @Published var challenges: [ChallengeHistoryEntry] = []   // فقط المكتملة — تُعرض بـ "All Challenges" و"Challenges" و Win Rate
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    // MARK: - Computed
    // ✅ Win Rate من المكتملة بس (النشطة مالها فوز/خسارة بعد)
    var winRate: Int {
        guard !challenges.isEmpty else { return 0 }
        let wins = challenges.filter { $0.rank == 1 }.count
        return Int(Double(wins) / Double(challenges.count) * 100)
    }

    // MARK: - Load
    func load(uid: String) async {
        isLoading = true
        defer { isLoading = false }

        // ✅ كل عملية مستقلة — لو وحدة فشلت ما توقف الباقي
        async let profileFetch   = fetchProfile(uid: uid)
        async let completedFetch = fetchCompletedChallenges(uid: uid)

        let p = (try? await profileFetch) ?? UserProfile(uid: uid, displayName: "Ticku User")
        let completed = (try? await completedFetch) ?? []

        profile    = p
        challenges = completed
    }

    // MARK: - Private
    // ✅ نقرأ الحقول يدوياً (مش عبر Codable) عشان أي حقل غير متوقع
    // بالمستند ما يفشّل الـ decode كامل بصمت ويمسح كل البيانات
    private func fetchProfile(uid: String) async throws -> UserProfile {
        let doc = try await db
            .collection("users")
            .document(uid)
            .getDocument()

        guard doc.exists, let data = doc.data() else {
            print("⚠️ No user document found for uid: \(uid)")
            return UserProfile(uid: uid, displayName: "Ticku User")
        }

        var profile = UserProfile()
        profile.uid = uid
        profile.displayName = data["displayName"] as? String ?? ""
        profile.profileImageURL = data["profileImageURL"] as? String
        profile.profileImageBase64 = data["profileImageBase64"] as? String
        profile.email = data["email"] as? String ?? ""
        profile.appleUserIdentifier = data["appleUserIdentifier"] as? String
        profile.totalChallengesCompleted = data["totalChallengesCompleted"] as? Int ?? 0
        profile.currentStreak = data["currentStreak"] as? Int ?? 0
        profile.longestStreak = data["longestStreak"] as? Int ?? 0
        profile.username = data["username"] as? String
        profile.handle = data["handle"] as? String
        profile.totalWins = data["totalWins"] as? Int ?? 0
        if let ts = data["lastActiveDate"] as? Timestamp {
            profile.lastActiveDate = ts.dateValue()
        }
        if let ts = data["createdAt"] as? Timestamp {
            profile.createdAt = ts.dateValue()
        }
        return profile
    }

    // ✅ فقط المكتملة (status == "completed")
    // النشطة تطلع بالهوم بس، مش بالبروفايل
    // ✅ نقرأ Challenge يدوياً (مش try? doc.data(as: Challenge.self)) عشان أي حقل
    // غير متوقع بمستند التحدي ما يفشّل decode كامل بصمت ويحذف التحدي من القائمة
    private func fetchCompletedChallenges(uid: String) async throws -> [ChallengeHistoryEntry] {
        let snap = try await db
            .collection("challenges")
            .whereField("memberIds", arrayContains: uid)
            .whereField("status", isEqualTo: "completed")
            .order(by: "endDate", descending: true)
            .getDocuments()

        return snap.documents.compactMap { doc -> ChallengeHistoryEntry? in
            let data = doc.data()

            var challenge = Challenge()
            challenge.id = doc.documentID
            challenge.title = data["title"] as? String ?? ""
            challenge.description = data["description"] as? String ?? ""
            challenge.createdBy = data["createdBy"] as? String ?? ""
            challenge.status = data["status"] as? String ?? "completed"
            challenge.memberCount = data["memberCount"] as? Int ?? 0
            challenge.memberIds = data["memberIds"] as? [String] ?? []
            challenge.challengeType = data["challengeType"] as? String ?? "group"
            if let ts = data["startDate"] as? Timestamp {
                challenge.startDate = ts.dateValue()
            }
            if let ts = data["endDate"] as? Timestamp {
                challenge.endDate = ts.dateValue()
            }
            if let ts = data["createdAt"] as? Timestamp {
                challenge.createdAt = ts.dateValue()
            }

            let rank = data["rank_\(uid)"] as? Int
            return ChallengeHistoryEntry(challenge: challenge, rank: rank)
        }
    }
}
