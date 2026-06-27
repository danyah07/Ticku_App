//
//  CreateChallengeViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  CreateChallengeViewModel.swift
//  firebasetrial

//
//  CreateChallengeViewModel.swift
//  firebasetrial

import Foundation
import FirebaseFirestore
import Combine

// MARK: - DurationOption
enum DurationOption: String, CaseIterable, Identifiable, Codable {
    case today  = "Today"
    case days3  = "3 Days"
    case days7  = "7 Days"
    case days14 = "14 Days"

    var id: String { rawValue }
    var requiresTime: Bool { self == .today }

    func endDate(from start: Date, hour: Int, minute: Int) -> Date {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        switch self {
        case .today:
            // ✅ hour/minute هنا تمثل "مدة" (كم ساعة ودقيقة من الآن) 
            let seconds = TimeInterval(hour * 3600 + minute * 60)
            return start.addingTimeInterval(max(seconds, 60)) // حد أدنى دقيقة عشان ما يطلع وقت فات
        case .days3:
            return cal.date(byAdding: .day, value: 3,  to: start) ?? start
        case .days7:
            return cal.date(byAdding: .day, value: 7,  to: start) ?? start
        case .days14:
            return cal.date(byAdding: .day, value: 14, to: start) ?? start
        }
    }
}

// MARK: - ChallengeType
enum ChallengeType: String, CaseIterable, Identifiable {
    case solo  = "solo"
    case group = "group"

    var id: String { rawValue }
    var label: String { self == .solo ? "solo" : "Group" }
    var icon: String { self == .solo ? "person.fill" : "person.2.fill" }
}

// MARK: - CreateChallengeViewModel
@MainActor
final class CreateChallengeViewModel: ObservableObject {

    @Published var challengeName: String = ""
    @Published var selectedDuration: DurationOption = .days7
    @Published var selectedType: ChallengeType = .group
    @Published var challengeRule: String = ""
    @Published var hourText: String = ""
    @Published var minuteText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    var showTimePicker: Bool { selectedDuration.requiresTime }

    var isFormValid: Bool {
        !challengeName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private let db = Firestore.firestore()

    func createChallenge(
        creatorId: String,
        creatorName: String
    ) async -> Challenge? {
        guard isFormValid else { return nil }
        isLoading = true
        defer { isLoading = false }

        let now    = Date()
        let hour   = Int(hourText) ?? 0
        let minute = Int(minuteText) ?? 0
        let end    = selectedDuration.endDate(from: now, hour: hour, minute: minute)
        let code   = Self.generateCode()

        var data: [String: Any] = [
            "title":         challengeName.trimmingCharacters(in: .whitespaces),
            "description":   challengeRule.trimmingCharacters(in: .whitespaces),
            "createdBy":     creatorId,
            "startDate":     NSNull(),  // ← null حتى يضغط START
            "endDate":       Timestamp(date: end),
            "status":        "active",
            "memberCount":   1,
            "memberIds":     [creatorId],
            "createdAt":     Timestamp(date: now),
            "challengeType": selectedType.rawValue
        ]

        // لو Solo ما نضيف inviteCode أصلاً — ما يقدر أحد ينضم
        if selectedType == .group {
            data["inviteCode"] = code
        }

        do {
            let ref = try await db.collection("challenges").addDocument(data: data)

            let memberData: [String: Any] = [
                "userId":          creatorId,
                "displayName":     creatorName,
                "profileImageURL": NSNull(),
                "progressPercent": 0.0,
                "tasksTotal":      0,
                "tasksCompleted":  0,
                "joinedAt":        Timestamp(date: now),
                "role":            "creator"
            ]
            try await ref
                .collection("members")
                .document(creatorId)
                .setData(memberData)

            return Challenge(
                id: ref.documentID,
                title: challengeName.trimmingCharacters(in: .whitespaces),
                description: challengeRule.trimmingCharacters(in: .whitespaces),
                createdBy: creatorId,
                startDate: Date.distantFuture,  // ← عشان timerDisplay يعرض START
                endDate: end,
                status: "active",
                memberCount: 1,
                createdAt: now,
                memberIds: [creatorId],
                challengeType: selectedType.rawValue
            )
        } catch {
            errorMessage = error.localizedDescription
            ErrorHandler.shared.report(error, context: "creating challenge")
            return nil
        }
    }

    static func generateCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
