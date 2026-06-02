//
//  CreateChallengeTip.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import TipKit

// Home: زر + Create
struct CreateChallengeTip: Tip {
    var title: Text { Text("Start a Challenge") }
    var message: Text? { Text("Tap here to create your first challenge.") }
    var image: Image? { Image(systemName: "plus.circle.fill") }
}
