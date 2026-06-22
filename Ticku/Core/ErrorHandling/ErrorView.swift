//
//  ErrorView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

// MARK: - ErrorBannerView
// Banner منبثق أسفل الشاشة — يطلع تلقائياً لما يصير خطأ، يختفي تلقائياً بعد ثواني
struct ErrorBannerView: View {
    let message: String
    var onDismiss: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold))
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(2)
            Spacer(minLength: 0)
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "#E74C3C").opacity(isDark ? 0.95 : 0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

// MARK: - OfflineBannerView
// Banner ثابت فوق لما ما فيه نت (يختلف عن error العادي لأنه يستمر طول فترة قطع النت)
struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 12, weight: .bold))
            Text("No internet connection")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(hex: "#3A3A3C"))
    }
}

// MARK: - View Extension
// يضيف overlay الأخطاء + شريط الأوفلاين لأي صفحة بسطر واحد: .withErrorHandling()
extension View {
    func withErrorHandling() -> some View {
        modifier(ErrorHandlingModifier())
    }
}

private struct ErrorHandlingModifier: ViewModifier {
    @ObservedObject private var errorHandler = ErrorHandler.shared

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if errorHandler.isOffline {
                OfflineBannerView()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            ZStack {
                content

                if let error = errorHandler.currentError {
                    VStack {
                        Spacer()
                        ErrorBannerView(
                            message: error.errorDescription ?? "Something went wrong.",
                            onDismiss: { errorHandler.clear() }
                        )
                        .padding(.bottom, 24)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        // يختفي تلقائياً بعد 4 ثواني لو المستخدم ما قفله بنفسه
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            if errorHandler.currentError?.id == error.id {
                                withAnimation { errorHandler.clear() }
                            }
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: errorHandler.currentError?.id)
        .animation(.easeInOut(duration: 0.25), value: errorHandler.isOffline)
    }
}
