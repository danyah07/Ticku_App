//
//  AddTaskTip.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import TipKit

// Home: دائرة النسبة المئوية
struct ProgressCircleTip: Tip {
    var title: Text { Text("Track Your Progress") }
    var message: Text? { Text("Tap the progress circle to see your list of tasks.") }
    var image: Image? { Image(systemName: "circle.dashed") }
}

// Challenge Room: دائرة ME
struct PlayerTaskTip: Tip {
    var title: Text { Text("Add Your Tasks") }
    var message: Text? { Text("Tap your profile icon to add your tasks and start tracking your progress.") }
    var image: Image? { Image(systemName: "person.fill.checkmark") }
}
