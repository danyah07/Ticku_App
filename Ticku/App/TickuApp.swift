//
//  firebasetrialApp.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/04/2026.
//

//
//  TickuApp.swift
//  firebasetrial

import SwiftUI
import FirebaseCore
import TipKit

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

    // ✅ يقرأ نفس المفتاح اللي يحفظه زر الدارك مود بصفحة Settings
    @AppStorage("isDarkMode") private var isDarkMode = false

    // ✅ يقرأ اللغة المختارة من Settings (EN/AR)
    @AppStorage("app_language") private var appLanguage = "en"

    init() {
        // ✅ يطبّق اللغة المحفوظة فور تشغيل التطبيق
        Bundle.applyStoredLanguage()
        try? Tips.configure([
            .displayFrequency(.weekly),
            .datastoreLocation(.applicationDefault)
        ])
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(authVM)
                // ✅ يطبّق الوضع على كل التطبيق فوراً لحظة الضغط على الزر
                .preferredColorScheme(isDarkMode ? .dark : .light)
                // ✅ يطبّق اللغة على كل التطبيق فوراً لحظة الضغط على EN/AR
                .environment(\.locale, Locale(identifier: appLanguage))
                // ✅ يبدّل اتجاه الـ layout تلقائياً (RTL للعربية، LTR للإنجليزية)
                .environment(\.layoutDirection, appLanguage == "ar" ? .rightToLeft : .leftToRight)
        }
    }
}
