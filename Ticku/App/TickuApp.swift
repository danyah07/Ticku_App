//
//  firebasetrialApp.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/04/2026.
//

//
//  TickuApp.swift
//  firebasetrial

//
//  TickuApp.swift
//  firebasetrial

//
//  TickuApp.swift
//  firebasetrial

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TickuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
        }
    }
}
