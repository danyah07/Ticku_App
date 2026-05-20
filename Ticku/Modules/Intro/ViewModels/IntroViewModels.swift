//
//  IntroView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI
import Combine

final class IntroViewModels: ObservableObject {
    
    @Published var currentPage: Int = 0
    
    let pages: [IntroPageModel] = [
        IntroPageModel(
            image: "checkmark.circle",
            title: "challenge yourself",
            description: "Set daily tasks, track your progress, and push past your limits — one day at a time.",
            color: Color(hex: "#8E8AC5")
        ),
        IntroPageModel(
            image: "person.2.circle",
            title: "Compete with friends",
            description: "Invite your crew, see who completes the most tasks, and keep each other accountable.",
            color: Color(hex: "#8E8AC5")
        ),
        IntroPageModel(
            image: "bolt.fill",
            title: "Stay consistent",
            description: "Build streaks, earn badges, and prove you have what it takes to finish what you start.",
            color: Color(hex: "#8E8AC5")
        )
    ]
}

struct IntroPageModel {
    let image: String
    let title: String
    let description: String
    let color: Color
}
