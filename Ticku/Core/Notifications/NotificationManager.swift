//
//  NotificationManager.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    // MARK: - Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            print("Notifications permission granted: \(granted)")
        }
    }

    // MARK: - 1. وقت قريب على الانتهاء
    func scheduleTimeWarnings(challengeName: String, secondsRemaining: TimeInterval) {

        // ساعة
        if secondsRemaining > 3600 {
            schedule(
                id: NotificationIdentifier.timeWarning1h + challengeName,
                title: NotificationTitle.lastHour,
                body: NotificationBody.lastHour(challenge: challengeName),
                after: secondsRemaining - 3600
            )
        }

        // 30 دقيقة
        if secondsRemaining > 1800 {
            schedule(
                id: NotificationIdentifier.timeWarning30m + challengeName,
                title: NotificationTitle.thirtyMin,
                body: NotificationBody.thirtyMin(challenge: challengeName),
                after: secondsRemaining - 1800
            )
        }

        // 5 دقائق
        if secondsRemaining > 300 {
            schedule(
                id: NotificationIdentifier.timeWarning5m + challengeName,
                title: NotificationTitle.fiveMin,
                body: NotificationBody.fiveMin(challenge: challengeName),
                after: secondsRemaining - 300
            )
        }
        // ✅ تحديات قصيرة المدى (أقل من 5 دقائق) — تنبيه واحد عند نص الوقت المتبقي
        // عشان حتى التحديات القصيرة جداً تذكّر المستخدم قبل الانتهاء
        else if secondsRemaining > 10 {
            schedule(
                id: NotificationIdentifier.timeWarning5m + challengeName,
                title: NotificationTitle.fiveMin,
                body: NotificationBody.fiveMin(challenge: challengeName),
                after: secondsRemaining / 2
            )
        }
    }

    // MARK: - 2. انتهى التحدي
    func sendChallengeComplete(challengeName: String, winnerName: String, winnerProgress: Int) {
        schedule(
            id: NotificationIdentifier.challengeComplete + challengeName,
            title: NotificationTitle.complete,
            body: NotificationBody.complete(
                winner: winnerName,
                challenge: challengeName,
                progress: winnerProgress
            ),
            after: 1
        )
    }

    // MARK: - 3. طلب تغيير الحكم
    func sendRuleChangeRequest(requesterName: String, newRule: String, challengeName: String) {
        schedule(
            id: NotificationIdentifier.ruleChange + UUID().uuidString,
            title: NotificationTitle.ruleChange,
            body: NotificationBody.ruleChange(
                requester: requesterName,
                challenge: challengeName,
                newRule: newRule
            ),
            after: 1
        )
    }

    // MARK: - 4. شخص طلع من التحدي
    func sendPlayerLeft(playerName: String, challengeName: String) {
        schedule(
            id: "player_left_\(UUID().uuidString)",
            title: "👋 Player Left",
            body: "\(playerName) has left \"\(challengeName)\". The challenge continues!",
            after: 1
        )
    }
    func cancelTimeWarnings(for challengeName: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                NotificationIdentifier.timeWarning1h  + challengeName,
                NotificationIdentifier.timeWarning30m + challengeName,
                NotificationIdentifier.timeWarning5m  + challengeName
            ]
        )
    }

    // MARK: - Private Helper
    private func schedule(id: String, title: String, body: String, after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(seconds, 1),
            repeats: false
        )
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
