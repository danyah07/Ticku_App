//
//  NotificationConstants.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import Foundation

enum NotificationIdentifier {
    static let timeWarning1h  = "time_1h_"
    static let timeWarning30m = "time_30m_"
    static let timeWarning5m  = "time_5m_"
    static let challengeComplete = "complete_"
    static let ruleChange = "rule_change_"
    static let playerLeft = "player_left_"
}

enum NotificationTitle {
    static let lastHour     = "⏰ Last Hour!"
    static let thirtyMin    = "🔥 30 Minutes Left!"
    static let fiveMin      = "🚨 5 Minutes Left!"
    static let complete     = "🏆 Challenge Complete!"
    static let ruleChange   = "📋 Rule Change Requested"
}

enum NotificationBody {
    static func lastHour(challenge: String) -> String {
        "Only 1 hour left in \"\(challenge)\"! Push through and finish your tasks 💪"
    }
    static func thirtyMin(challenge: String) -> String {
        "Final sprint! Complete your tasks in \"\(challenge)\" before time runs out 🏃"
    }
    static func fiveMin(challenge: String) -> String {
        "\"\(challenge)\" is almost over! Last chance to complete your tasks ⚡"
    }
    static func complete(winner: String, challenge: String, progress: Int) -> String {
        "\(winner) won \"\(challenge)\" with \(progress)% completion. Check the final results!"
    }
    static func ruleChange(requester: String, challenge: String, newRule: String) -> String {
        "\(requester) wants to change the rule in \"\(challenge)\" to: \"\(newRule)\". Tap to approve or reject."
    }
}
