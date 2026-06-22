//
//  AddTaskTip.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI
import TipKit

// يطلع على دائرة "Today's Tasks" في الهوم
// يشرح للمستخدم إنه يقدر يضغط الدائرة عشان يشوف قائمة مهامه
struct AddTaskTip: Tip {

    var title: Text {
        Text("Tap the progress circle to see your list of tasks")
    }

    var message: Text? {
        nil
    }

    var image: Image? {
        nil
    }

    var rules: [Rule] {
        #Rule(Self.$hasOpenedHomeBefore) { $0 == false }
    }

    @Parameter
    static var hasOpenedHomeBefore: Bool = false
}
