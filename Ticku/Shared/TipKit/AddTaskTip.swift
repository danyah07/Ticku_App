//
//  AddTaskTip.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI
import TipKit

struct AddTaskTip: Tip {

    var title: Text {
        Text(NSLocalizedString("add_task_tip", comment: ""))
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
