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
            backgroundView

            VStack(spacing: 0) {

                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isDark ? .white : .black)
                    }

                    Spacer()
                }
                .padding(.horizontal, 29)
                .padding(.top, 4)

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(isDark ? .white : .black)

                    Text("Ready for today’s challenge?")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(isDark ? .white.opacity(0.56) : Color(hex: "#3A3A3A"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 36)
                .offset(y: -12)

                Spacer()

                VStack(spacing: 48) {
                    Button(action: handleAppleSignInTap) {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 17, weight: .bold))

                            Text("Sign in with Apple")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(isDark ? .white : .black)
                        .frame(width: 330, height: 55)
                        .background(isDark ? Color.black : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(isDark ? Color(hex: "#2A2525") : Color(hex: "#D3D1D1"), lineWidth: 1)
                        )
                        .shadow(
                            color: Color.black.opacity(isDark ? 0.25 : 0.20),
                            radius: 4,
                            x: 0,
                            y: 4
                        )
                    }
                    .buttonStyle(.plain)

                    Text("By continuing, you agree to our Terms & Privacy.")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isDark ? .white.opacity(0.60) : Color.black.opacity(0.60))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 46)
            }

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
                        .onTapGesture {
                            authVM.errorMessage = nil
                        }
                }
            }

            if authVM.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.4)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: authVM.isAuthenticated) {
            if authVM.isAuthenticated {
                onBack()
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            LinearGradient(
                colors: [
                    Color(hex: "#604D93"),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [
                    Color(hex: "#9B84E7"),
                    Color(hex: "#DED8F5"),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

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

        appleSignInCoordinator = delegate
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
    }
}

private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let onComplete: (Result<ASAuthorization, Error>) -> Void

    init(onComplete: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.onComplete = onComplete
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        onComplete(.success(authorization))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
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
