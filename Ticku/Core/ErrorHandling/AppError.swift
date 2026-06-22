//
//  AppError.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import Foundation

// MARK: - AppError
// نوع موحّد للأخطاء بكل التطبيق — يحدد رسالة واضحة للمستخدم بدل رسائل Firebase التقنية
enum AppError: LocalizedError, Identifiable {

    case noInternet
    case saveFailed(String)        // فشل حفظ بيانات (تشالنج، تاسك...)
    case loadFailed(String)        // فشل تحميل بيانات
    case notFound(String)          // مستند/تشالنج غير موجود
    case permissionDenied
    case invalidInput(String)      // مدخلات غلط من المستخدم
    case unknown(String)

    var id: String { errorDescription ?? UUID().uuidString }

    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection. Please check your connection and try again."
        case .saveFailed(let what):
            return "Couldn't save \(what). Please try again."
        case .loadFailed(let what):
            return "Couldn't load \(what). Please try again."
        case .notFound(let what):
            return "\(what) not found. It may have been deleted."
        case .permissionDenied:
            return "You don't have permission to do this."
        case .invalidInput(let message):
            return message
        case .unknown(let message):
            return message.isEmpty ? "Something went wrong. Please try again." : message
        }
    }

    /// يحول أي Error عام (مثل Firebase NSError) إلى AppError واضح
    static func from(_ error: Error) -> AppError {
        let nsError = error as NSError

        // أكواد شبكة شائعة (URLError / Firestore network errors)
        if nsError.domain == NSURLErrorDomain || nsError.code == -1009 || nsError.code == -1001 {
            return .noInternet
        }

        // Firestore permission denied (code 7)
        if nsError.domain.contains("FIRFirestoreErrorDomain") && nsError.code == 7 {
            return .permissionDenied
        }

        return .unknown(error.localizedDescription)
    }
}
