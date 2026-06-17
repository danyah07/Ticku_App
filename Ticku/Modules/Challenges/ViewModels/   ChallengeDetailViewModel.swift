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
                    self.members = snap.documents.compactMap {
                        try? $0.data(as: ChallengeMember.self)
                    }
                    .sorted { $0.progressPercent > $1.progressPercent }
                }
            }

        challengeListener = db
            .collection("challenges").document(challengeId)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                Task { @MainActor in
                    // endDate
                    if let endTs = snap.data()?["endDate"] as? Timestamp {
                        self.challengeEndDate = endTs.dateValue()
                        self.timeRemaining = max(0, self.challengeEndDate.timeIntervalSinceNow)
                    }
                    // startDate
                    if let startTs = snap.data()?["startDate"] as? Timestamp {
                        let date = startTs.dateValue()
                        if date <= Date() {
                            self.challengeStartDate = date
                        }
                    } else {
                        self.challengeStartDate = nil
                    }
                    // inviteCode من Firebase
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

    func startChallenge() async {
        guard !challengeId.isEmpty else { return }
        let now = Date()
        try? await db
            .collection("challenges")
            .document(challengeId)
            .updateData(["startDate": Timestamp(date: now)])
        self.challengeStartDate = now
    }

    var shareMessage: String {
        "🔥 Ticku Challenge!\n🎟 Code: \(inviteCode)\nJoin — think you can beat me? 🏆"
    }

    func saveInviteCode() async {
        guard !challengeId.isEmpty else { return }
        // لو ما فيه code في Firebase نحفظ واحد جديد
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
