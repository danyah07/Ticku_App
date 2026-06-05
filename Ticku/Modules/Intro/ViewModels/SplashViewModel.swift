//
//  SplashViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//
import Foundation
import Combine

final class SplashViewModel: ObservableObject {

    @Published var navigateToNext = false

    /// true  → user has seen intro before → go straight to HomeView
    /// false → first launch → show IntroView first
    var hasSeenIntro: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenIntro")
    }

    func startSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.navigateToNext = true
        }
    }
}
