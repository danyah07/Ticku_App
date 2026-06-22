//
//  StreakTip.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI
import TipKit

// يطلع على صورة البروفايل (ME) في صفحة التحدي بعد ما يضغط START
// يشرح إنه يقدر يضغط صورته عشان يضيف مهامه ويبدأ يتابع تقدمه
struct StreakTip: Tip {

    var title: Text {
        Text("Tap your profile icon to add your tasks and start tracking your progress")
    }

    var message: Text? {
        nil
    }

    var image: Image? {
        nil
    }

    var rules: [Rule] {
        #Rule(Self.$hasStartedChallengeBefore) { $0 == false }
    }

    @Parameter
    static var hasStartedChallengeBefore: Bool = false
}
