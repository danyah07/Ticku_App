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

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var onBack: () -> Void = {}

    var body: some View {
        ZStack {
            // ── Background ────────────────────────────────
            LinearGradient(
                colors: [Color(hex: "#5B4DB5"), Color(hex: "#D6D0F0")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Back Button ───────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.ticku.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, TickuSpacing.screenH)
                .padding(.top, 16)

                Spacer()

                // ── Hero Text ─────────────────────────────
                VStack(spacing: 10) {
                    Text("Welcome")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(Color.ticku.primary)

                    Text("Ready for today's challenge?")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color.ticku.primary.opacity(0.75))
                }

                Spacer()

                // ── Apple Sign In Button ──────────────────
                VStack(spacing: 14) {
                    SignInWithAppleButton(.signIn) { request in
                        let hashedNonce = authVM.prepareNonce()
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = hashedNonce
                    } onCompletion: { result in
                        Task {
                            await authVM.handleAppleSignIn(result: result)
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 54)
                    .clipShape(Capsule())
                    .padding(.horizontal, TickuSpacing.screenH)

                    Text("By continuing, you agree to our Terms & Privacy.")
                        .font(Font.ticku.caption)
                        .foregroundColor(Color.ticku.primary.opacity(0.6))
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
    }

