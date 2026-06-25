//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 10/01/1448 AH.
//

import SwiftUI
import TipKit

// يطلع على صندوق "Enter time" بصفحة Create Challenge
// يظهر فقط لو المستخدم اختار مدة "Today" (يحتاج تحديد ساعة)
struct EnterTimeTip: Tip {

    var title: Text {
        Text("Choose how long this challenge lasts.")
    }

    var message: Text? {
        nil
    }

    var image: Image? {
        nil
    }

    var rules: [Rule] {
        #Rule(Self.$hasSeenTimePickerBefore) { $0 == false }
    }

    @Parameter
    static var hasSeenTimePickerBefore: Bool = false
}
