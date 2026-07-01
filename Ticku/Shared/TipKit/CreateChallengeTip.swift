//
//  CreateChallengeTip.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI
import TipKit

struct CreateChallengeTip: Tip {

    var title: Text {
        Text(NSLocalizedString("create_challenge_tip", comment: ""))
    }

    var message: Text? {
        nil
    }

    var image: Image? {
        nil
    }

    var rules: [Rule] {
        #Rule(Self.$hasNoActiveChallenges) { $0 == true }
    }

    @Parameter
    static var hasNoActiveChallenges: Bool = false
}
