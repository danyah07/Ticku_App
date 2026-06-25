//
//  AuthView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  SignInView.swift
//  firebasetrial

//
//  SignInView.swift
//  firebasetrial

//
//  SignInView.swift
//  firebasetrial

import SwiftUI
import AuthenticationServices
import UIKit

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }
    var onBack: () -> Void = {}
    @State private var appleSignInCoordinator: AppleSignInCoordinator? = nil

    var body: some View {
        ZStack {
            // ── Background ────────────────────────────────
            backgroundView

            VStack(spacing: 0) {

                // ── Back Button ───────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isDark ? .white : Color.ticku.primary)
                            .frame(width: 40, height: 40)
                            .liquidGlassCircle(tint: Color.clear)
                    }
                    Spacer()
                }
                .padding(.horizontal, TickuSpacing.screenH)
                .padding(.top, 16)

                Spacer()

                // ── Hero Text ─────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(isDark ? .white : .black)

                    Text("Ready for today's challenge?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isDark ? .white.opacity(0.7) : Color(hex: "#3A3A3A"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, TickuSpacing.screenH)

                Spacer()

                // ── Apple Sign In Button ──────────────────
                VStack(spacing: 14) {
                    Button(action: handleAppleSignInTap) {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18, weight: .medium))
                            Text("Sign in with Apple")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(appleButtonForeground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .liquidGlassButton(tint: appleButtonForeground == .white ? .black : .white, cornerRadius: 27)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, TickuSpacing.screenH)

                    Text("By continuing, you agree to our Terms & Privacy.")
                        .font(Font.ticku.caption)
                        .foregroundColor(isDark ? .white.opacity(0.5) : Color(hex: "#3A3A3A"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TickuSpacing.screenH)
                }
                .padding(.bottom, 48)
            }

            // ── Error Toast ───────────────────────────────
            if let msg = authVM.errorMessage {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.ticku.errorRed.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
                        .onTapGesture { authVM.errorMessage = nil }
                }
            }

            // ── Loading Overlay ───────────────────────────
            if authVM.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.4)
            }
        }
        .navigationBarHidden(true)
        // ✅ iOS 17+ onChange syntax — auto-dismiss when sign in succeeds
        .onChange(of: authVM.isAuthenticated) {
            print("👀 SignInView onChange fired — isAuthenticated: \(authVM.isAuthenticated)")
            if authVM.isAuthenticated {
                print("👀 Calling onBack()")
                onBack()
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            LinearGradient(
                colors: [Color(hex: "#5B4A8F"), Color(hex: "#1A1530"), Color(hex: "#000000")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [Color(hex: "#5B4DB5"), Color(hex: "#D6D0F0")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var appleButtonForeground: Color {
        isDark ? .white : .black
    }

    // ✅ نفس منطق SignInWithAppleButton الرسمي، بس مستدعى يدوياً
    // عشان نقدر نصمم الزر بأنفسنا (Liquid Glass) بدون فقدان أي وظيفة
    private func handleAppleSignInTap() {
        let hashedNonce = authVM.prepareNonce()
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInCoordinator { result in
            Task {
                await authVM.handleAppleSignIn(result: result)
            }
        }
        appleSignInCoordinator = delegate // نحتفظ بمرجع عشان ما يروح بالـ deinit قبل الرد
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
    }
}

// MARK: - Apple Sign In Coordinator
// يكرر بالضبط سلوك SignInWithAppleButton الجاهز لكن بدون قيود الشكل
private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let onComplete: (Result<ASAuthorization, Error>) -> Void

    init(onComplete: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.onComplete = onComplete
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        onComplete(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onComplete(.failure(error))
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first ?? ASPresentationAnchor()
    }
}

#Preview("Light") {
    SignInView()
        .environmentObject(AuthViewModel())
}

#Preview("Dark") {
    SignInView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
