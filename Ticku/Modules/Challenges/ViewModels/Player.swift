//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 10/12/1447 AH.
//

import Foundation

struct Player: Identifiable {

    let id: UUID = UUID()

    var name: String
    var rank: Int
    var isMe: Bool

    var completedTasks: Int = 0
    var totalTasks: Int = 0

    var progress: Double {

        guard totalTasks > 0 else {
            return 0
        }

        return Double(completedTasks) / Double(totalTasks)
    }

    var progressText: String {

        "\(Int(progress * 100))%"
    }
}
