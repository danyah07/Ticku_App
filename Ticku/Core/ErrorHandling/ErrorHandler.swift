//
//  ErrorHandler.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import Foundation
import Network
import Combine

// MARK: - ErrorHandler
// Singleton يستخدم في كل ViewModel — يلتقط الأخطاء، يحولها لـ AppError، ويتابع حالة النت
@MainActor
final class ErrorHandler: ObservableObject {

    static let shared = ErrorHandler()

    @Published var currentError: AppError? = nil
    @Published var isOffline: Bool = false

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "ErrorHandler.NetworkMonitor")

    private init() {
        startNetworkMonitoring()
    }

    // MARK: - Network Monitoring
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOffline = path.status != .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }

    // MARK: - Report Error
    /// تُستخدم من أي ViewModel: catch { ErrorHandler.shared.report(error, context: "creating challenge") }
    func report(_ error: Error, context: String = "") {
        let appError = AppError.from(error)
        print("⚠️ Error\(context.isEmpty ? "" : " [\(context)]"): \(error.localizedDescription)")
        currentError = appError
    }

    func report(_ appError: AppError) {
        currentError = appError
    }

    func clear() {
        currentError = nil
    }
}
