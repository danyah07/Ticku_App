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
    var profileImageBase64: String? = nil
    var email: String = ""
    var appleUserIdentifier: String? = nil
    var totalChallengesCompleted: Int = 0
    var totalWins: Int = 0
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
    private var userListener: ListenerRegistration?

    func loadHome(for uid: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            startUserListener(uid: uid)
            activeChallenges = try await fetchActiveChallenges(uid: uid)
            try await fetchMyOverallProgress(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        userListener?.remove()
        userListener = nil
        currentUser      = nil
        activeChallenges = []
        progressPercent  = 0
        tasksCompleted   = 0
        tasksTotal       = 0
    }

    // ✅ Listener حي — يحدث currentUser تلقائياً فور أي تغيير بـ Firestore
    // نقرأ الحقول يدوياً (مش عبر Codable) عشان أي حقل غير متوقع بالمستند
    // ما يفشّل decode كامل بصمت ويأثر على باقي الحقول (زي الاسم والصورة)
    private func startUserListener(uid: String) {
        userListener?.remove()
        userListener = db
            .collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap, snap.exists, let data = snap.data() else { return }
                Task { @MainActor in
                    var user = TickuUser()
                    user.uid = uid
                    user.displayName = data["displayName"] as? String ?? ""
                    user.profileImageURL = data["profileImageURL"] as? String
                    user.profileImageBase64 = data["profileImageBase64"] as? String
                    user.email = data["email"] as? String ?? ""
                    user.appleUserIdentifier = data["appleUserIdentifier"] as? String
                    user.totalChallengesCompleted = data["totalChallengesCompleted"] as? Int ?? 0
                    user.totalWins = data["totalWins"] as? Int ?? 0
                    user.currentStreak = data["currentStreak"] as? Int ?? 0
                    user.longestStreak = data["longestStreak"] as? Int ?? 0
                    if let ts = data["lastActiveDate"] as? Timestamp {
                        user.lastActiveDate = ts.dateValue()
                    }
                    if let ts = data["createdAt"] as? Timestamp {
                        user.createdAt = ts.dateValue()
                    }
                    self.currentUser = user
                }
            }
    }

    // ✅ نقرأ Challenge يدوياً (مش try? doc.data(as: Challenge.self)) عشان أي حقل
    // غير متوقع بمستند التحدي ما يفشّل decode كامل بصمت ويحذف التحدي من القائمة
    private func fetchActiveChallenges(uid: String) async throws -> [Challenge] {
        let snap = try await db
            .collection("challenges")
            .whereField("status", isEqualTo: "active")
            .whereField("memberIds", arrayContains: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snap.documents.compactMap { doc -> Challenge? in
            let data = doc.data()
            var challenge = Challenge()
            challenge.id = doc.documentID
            challenge.title = data["title"] as? String ?? ""
            challenge.description = data["description"] as? String ?? ""
            challenge.createdBy = data["createdBy"] as? String ?? ""
            challenge.status = data["status"] as? String ?? "active"
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
            return challenge
        }
    }

    // ✅ يجمع تقدمك من كل التحديات النشطة مع بعض — مو بس أول واحد
    // النسبة الكلية = (كل المهام المكتملة عبر كل التحديات) ÷ (كل المهام الكلية عبر كل التحديات)
    private func fetchMyOverallProgress(uid: String) async throws {
        guard !activeChallenges.isEmpty else {
            progressPercent = 0
            tasksCompleted  = 0
            tasksTotal      = 0
            return
        }

        var totalCompleted = 0
        var totalTasks     = 0

        for challenge in activeChallenges {
            guard let cid = challenge.id else { continue }
            let doc = try? await db
                .collection("challenges").document(cid)
                .collection("members").document(uid)
                .getDocument()

            guard let data = doc?.data() else { continue }
            totalCompleted += data["tasksCompleted"] as? Int ?? 0
            totalTasks     += data["tasksTotal"] as? Int ?? 0
        }

        tasksCompleted  = totalCompleted
        tasksTotal      = totalTasks
        progressPercent = totalTasks > 0 ? (Double(totalCompleted) / Double(totalTasks)) * 100 : 0
    }
}
