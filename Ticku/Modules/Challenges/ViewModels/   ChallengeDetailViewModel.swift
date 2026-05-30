//
//     ChallengeDetailViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import Foundation
import Combine

final class ChallengeDetailViewModel: ObservableObject {

    let challenge: Challenge
    let challengeId: String

    @Published private(set) var code: String
    @Published var players: [Player] = [
        Player(name: "ME", rank: 1, isMe: true, completedTasks: 0, totalTasks: 10)
    ]
    @Published private(set) var timeRemaining: TimeInterval = 0
    @Published private(set) var timerStarted: Bool = false
    @Published private(set) var timerFinished: Bool = false
    @Published var tasks: [String] = []

    private var timer: AnyCancellable?

    init(challenge: Challenge, challengeId: String = "", tasks: [String] = []) {
        self.challenge = challenge
        self.challengeId = challengeId
        self.tasks = tasks
        self.code = Self.generateCode()
        self.timeRemaining = Self.totalSeconds(for: challenge)
    }

    static func generateCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    static func totalSeconds(for challenge: Challenge) -> TimeInterval {
        switch challenge.duration {
        case .today:
            return TimeInterval(challenge.scheduledHour * 3600 + challenge.scheduledMinute * 60)
        case .days3:  return 3  * 24 * 3600
        case .days7:  return 7  * 24 * 3600
        case .days14: return 14 * 24 * 3600
        case .days30: return 30 * 24 * 3600
        }
    }

    func joinChallenge(playerName: String) {
        guard players.count < 4 else { return }
        let rank = players.count + 1
        players.append(Player(
            name: playerName,
            rank: rank,
            isMe: false,
            completedTasks: 0,
            totalTasks: 10
        ))
        if players.count == 2 && !timerStarted {
            startTimer()
        }
    }

    private func startTimer() {
        timerStarted = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timerFinished = true
                    self.timer?.cancel()
                }
            }
    }

    var timerDisplay: String {
        if !timerStarted { return "START" }
        let total = Int(timeRemaining)
        switch challenge.duration {
        case .today:
            let h = total / 3600
            let m = (total % 3600) / 60
            let s = total % 60
            return String(format: "%02d : %02d : %02d", h, m, s)
        default:
            let days = total / 86400
            let h = (total % 86400) / 3600
            let m = (total % 3600) / 60
            return String(format: "%d Days  %02d:%02d", days, h, m)
        }
    }

    var shareMessage: String {
        "🔥 \(challenge.name) Challenge!\n🎟 Code: \(code)\nJoin the challenge — think you can beat me? 🏆"
    }
}
