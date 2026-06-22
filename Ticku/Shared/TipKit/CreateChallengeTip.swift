//
//  CreateChallengeTip.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI
import TipKit

// يطلع على زر "+ Create" في الهوم
// يشجع المستخدم يسوي أول تحدي له
struct CreateChallengeTip: Tip {

    var title: Text {
        Text("Tap here to create your first challenge")
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
