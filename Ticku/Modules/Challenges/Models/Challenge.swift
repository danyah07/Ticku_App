//
//  Challenge.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import Foundation

enum DurationOption: String, CaseIterable, Identifiable {
    case today  = "today"
    case days3  = "3 Days"
    case days7  = "7 Days"
    case days14 = "14 Days"
    case days30 = "30 Days"

    var id: String { rawValue }
    var requiresTime: Bool { self == .today }
}

struct Challenge: Identifiable, Hashable {
    let id: UUID
    var name: String
    var duration: DurationOption
    var rule: String
    var scheduledHour: Int
    var scheduledMinute: Int

    init(
        id: UUID = UUID(),
        name: String = "",
        duration: DurationOption = .today,
        rule: String = "",
        scheduledHour: Int = 0,
        scheduledMinute: Int = 0
    ) {
        self.id              = id
        self.name            = name
        self.duration        = duration
        self.rule            = rule
        self.scheduledHour   = scheduledHour
        self.scheduledMinute = scheduledMinute
    }
}
