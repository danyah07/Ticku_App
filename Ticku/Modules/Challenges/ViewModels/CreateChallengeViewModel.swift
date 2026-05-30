//
//  CreateChallengeViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import Foundation
import Combine

final class CreateChallengeViewModel: ObservableObject {

    @Published var challengeName: String = ""
    @Published var selectedDuration: DurationOption = .today
    @Published var challengeRule: String = ""
    @Published var hourText: String = ""
    @Published var minuteText: String = ""
    @Published var tasks: [String] = []  // ← المهام

    @Published private(set) var isFormValid: Bool = false
    @Published private(set) var showTimePicker: Bool = true

    private var cancellables = Set<AnyCancellable>()

    init() {
        $selectedDuration
            .map(\.requiresTime)
            .assign(to: &$showTimePicker)

        $challengeName
            .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .assign(to: &$isFormValid)
    }

    func createChallenge() -> Challenge? {
        guard isFormValid else { return nil }
        return Challenge(
            name:            challengeName.trimmingCharacters(in: .whitespaces),
            duration:        selectedDuration,
            rule:            challengeRule.trimmingCharacters(in: .whitespaces),
            scheduledHour:   Int(hourText) ?? 0,
            scheduledMinute: Int(minuteText) ?? 0
        )
    }
}
