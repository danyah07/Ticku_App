//
//     ChallengeDetailViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  ChallengeDetailViewModel.swift
//  firebasetrial

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class ChallengeDetailViewModel: ObservableObject {

    let challenge: Challenge
    let challengeId: String

    @Published var members: [ChallengeMember] = []
    @Published var inviteCode: String = ""
    @Published var timeRemaining: TimeInterval = 0
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var challengeStartDate: Date? = nil
    @Published var challengeEndDate: Date

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var challengeListener: ListenerRegistration?
    private var timer: AnyCancellable?

    init(challenge: Challenge) {
        self.challenge        = challenge
        self.challengeId      = challenge.id ?? ""
        self.challengeEndDate = challenge.endDate
        self.timeRemaining    = max(0, challenge.endDate.timeIntervalSinceNow)
        startTimer()
    }

    deinit {
        listener?.remove()
        challengeListener?.remove()
        timer?.cancel()
    }

    func startListening(currentUserId: String) {
        guard !challengeId.isEmpty else { return }

        listener = db
            .collection("challenges").document(challengeId)
            .collection("members")
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                Task { @MainActor in
                    self.members = snap.documents.compactMap { doc -> ChallengeMember? in
                        let data = doc.data()
                        var member = ChallengeMember()
                        member.id = doc.documentID
                        member.userId = data["userId"] as? String ?? doc.documentID
                        member.displayName = data["displayName"] as? String ?? ""
                        member.profileImageURL = data["profileImageURL"] as? String
                        member.profileImageBase64 = data["profileImageBase64"] as? String
                        member.progressPercent = data["progressPercent"] as? Double ?? 0
                        member.tasksTotal = data["tasksTotal"] as? Int ?? 0
                        member.tasksCompleted = data["tasksCompleted"] as? Int ?? 0
                        member.role = data["role"] as? String ?? "member"
                        if let ts = data["joinedAt"] as? Timestamp {
                            member.joinedAt = ts.dateValue()
                        }
                        return member
                    }
                    .sorted { $0.progressPercent > $1.progressPercent }
                }
            }

        challengeListener = db
            .collection("challenges").document(challengeId)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                Task { @MainActor in
                    if let endTs = snap.data()?["endDate"] as? Timestamp {
                        self.challengeEndDate = endTs.dateValue()
                        self.timeRemaining = max(0, self.challengeEndDate.timeIntervalSinceNow)
                    }
                    if let startTs = snap.data()?["startDate"] as? Timestamp {
                        let date = startTs.dateValue()
                        if date <= Date() {
                            self.challengeStartDate = date
                        }
                    } else {
                        self.challengeStartDate = nil
                    }
                    if let code = snap.data()?["inviteCode"] as? String {
                        self.inviteCode = code
                    }
                }
            }
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let remaining = self.challengeEndDate.timeIntervalSinceNow
                self.timeRemaining = max(0, remaining)
                if remaining <= 0 { self.timer?.cancel() }
            }
    }

    var timerDisplay: String {
        guard let startDate = challengeStartDate, startDate <= Date() else {
            return "START"
        }

        let total = Int(max(0, timeRemaining))
        if total == 0 { return "00:00:00" }

        let days  = total / 86400
        let hours = (total % 86400) / 3600
        let mins  = (total % 3600) / 60
        let secs  = total % 60

        if days > 1 { return "\(days) days" }
        if days == 1 {
            let totalHours = days * 24 + hours
            return String(format: "%02d:%02d:%02d", totalHours, mins, secs)
        }
        return String(format: "%02d:%02d:%02d", hours, mins, secs)
    }

    // ✅ يرجع false ولا يبدأ التحدي لو فيه عضو بدون تاسكات
    // نقرأ الحقل مباشرة من البيانات الخام (مش عبر Codable) عشان أي حقل ناقص
    // أو نوع غير متوقع بمستند قديم ما يفشّل الـ decode كامل بصمت
    @discardableResult
    func startChallenge() async -> Bool {
        guard !challengeId.isEmpty else { return false }

        do {
            let snap = try await db
                .collection("challenges").document(challengeId)
                .collection("members")
                .getDocuments()

            for doc in snap.documents {
                let data = doc.data()
                let tasksTotal = data["tasksTotal"] as? Int ?? 0
                if tasksTotal == 0 {
                    let name = data["displayName"] as? String ?? "A player"
                    let message = "\(name) hasn't added any tasks yet."
                    errorMessage = message
                    ErrorHandler.shared.report(AppError.invalidInput(message))
                    return false
                }
            }
        } catch {
            ErrorHandler.shared.report(error, context: "checking members before start")
            return false
        }

        let now = Date()
        try? await db
            .collection("challenges")
            .document(challengeId)
            .updateData(["startDate": Timestamp(date: now)])
        self.challengeStartDate = now

        // إشعارات قرب انتهاء الوقت
        let remaining = challengeEndDate.timeIntervalSince(now)
        NotificationManager.shared.scheduleTimeWarnings(
            challengeName: challenge.title,
            secondsRemaining: remaining
        )
        return true
    }

    func completeChallenge() async {
        guard !challengeId.isEmpty else { return }
        try? await db
            .collection("challenges")
            .document(challengeId)
            .updateData(["status": "completed"])

        // إشعار انتهاء التحدي مع الفائز
        if let winner = members.max(by: { $0.progressPercent < $1.progressPercent }) {
            NotificationManager.shared.sendChallengeComplete(
                challengeName: challenge.title,
                winnerName: winner.displayName,
                winnerProgress: Int(winner.progressPercent)
            )

            // ✅ نزيد totalWins للفائز فعلياً بـ Firestore (المركز الأول)
            try? await db.collection("users").document(winner.userId)
                .updateData(["totalWins": FieldValue.increment(Int64(1))])
        }

        // ✅ نزيد totalChallengesCompleted لكل الأعضاء (شاركوا بتحدي خلص)
        for member in members {
            try? await db.collection("users").document(member.userId)
                .updateData(["totalChallengesCompleted": FieldValue.increment(Int64(1))])
        }

        NotificationManager.shared.cancelTimeWarnings(for: challenge.title)
    }

    var shareMessage: String {
        "🔥 Ticku Challenge!\n🎟 Code: \(inviteCode)\nJoin — think you can beat me? 🏆"
    }

    func saveInviteCode() async {
        guard !challengeId.isEmpty else { return }
        let doc = try? await db.collection("challenges").document(challengeId).getDocument()
        if let existing = doc?.data()?["inviteCode"] as? String, !existing.isEmpty {
            self.inviteCode = existing
        } else {
            let newCode = Self.generateCode()
            self.inviteCode = newCode
            try? await db.collection("challenges").document(challengeId).updateData(["inviteCode": newCode])
        }
    }

    static func generateCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
