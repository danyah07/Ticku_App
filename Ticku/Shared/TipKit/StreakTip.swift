//
//  StreakTip.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import TipKit

// Create Challenge: الوقت / Duration
struct DurationTip: Tip {
    var title: Text { Text("Choose Your Duration") }
    var message: Text? { Text("Choose how long this challenge lasts.") }
    var image: Image? { Image(systemName: "clock.fill") }
}
