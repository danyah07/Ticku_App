//
//  firebasetrialApp.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/04/2026.
//

import SwiftUI
import FirebaseCore
import TipKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct firebasetrialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            CreateChallengeView()
                .task {
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
