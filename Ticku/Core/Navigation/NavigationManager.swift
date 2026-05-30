//
//  NavigationManager.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  NavigationManager.swift
//  firebasetrial

import SwiftUI
import Combine

enum AppRoute: Hashable {
    case signIn
    case home
    case profile
    case allChallenges
    case createChallenge
    case joinChallenge
    case challengeRoom(Challenge)
    case myTasks(Challenge)
}

@MainActor
final class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func goHome() {
        path = NavigationPath()
    }
}
