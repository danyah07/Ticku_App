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

    private var isDark: Bool {
        colorScheme == .dark
    }

    var onBack: () -> Void = {}

    @State private var appleSignInCoordinator: AppleSignInCoordinator? = nil
    @State private var showPrivacySheet = false

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isDark ? .white : .black)
                    }

                    Spacer()
                }
                .padding(.horizontal, 29)
                .padding(.top, 4)

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text(NSLocalizedString("welcome", comment: ""))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(isDark ? .white : .black)

                    Text(NSLocalizedString("ready_for_today_challenge", comment: ""))
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(
                            isDark
                            ? .white.opacity(0.56)
                            : Color(hex: "#3A3A3A")
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 36)
                .offset(y: -12)

                Spacer()

                VStack(spacing: 22) {
                    Button(action: handleAppleSignInTap) {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 17, weight: .bold))

                            Text(NSLocalizedString("sign_in_with_apple", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(isDark ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(isDark ? Color.black : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    isDark
                                    ? Color(hex: "#2A2525")
                                    : Color(hex: "#D3D1D1"),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: Color.black.opacity(isDark ? 0.25 : 0.20),
                            radius: 4,
                            x: 0,
                            y: 4
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)

                    VStack(spacing: 8) {
                        Text(NSLocalizedString("terms_privacy_note", comment: ""))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(
                                isDark
                                ? .white.opacity(0.60)
                                : Color.black.opacity(0.60)
                            )
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        Button {
                            showPrivacySheet = true
                        } label: {
                            Text(NSLocalizedString("privacy_policy", comment: ""))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(
                                    isDark
                                    ? Color(hex: "#D8CCFF")
                                    : Color(hex: "#341D71")
                                )
                                .underline()
                        }
                    }
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
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyPolicySheet()
        }
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

        let controller = ASAuthorizationController(
            authorizationRequests: [request]
        )

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

// MARK: - Privacy Policy

struct PrivacyPolicySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("app_language") private var appLanguage = "en"

    private var isDark: Bool {
        colorScheme == .dark
    }

    private var isArabic: Bool {
        appLanguage.lowercased() == "ar"
    }

    private var currentLayoutDirection: LayoutDirection {
        isArabic ? .rightToLeft : .leftToRight
    }

    private var sheetBackground: Color {
        isDark ? Color.black : Color.white
    }

    private var mainTitleColor: Color {
        isDark ? .white : .black
    }

    private var dateColor: Color {
        isDark
        ? Color.white.opacity(0.55)
        : Color.black.opacity(0.45)
    }

    private var sectionTitleColor: Color {
        isDark
        ? Color(hex: "#C8B8FF")
        : Color(hex: "#341D71")
    }

    private var bodyTextColor: Color {
        isDark
        ? Color.white.opacity(0.82)
        : Color.black.opacity(0.78)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("privacy_policy", comment: ""))
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(mainTitleColor)
                            .multilineTextAlignment(.leading)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )

                        Text(NSLocalizedString("privacy_last_updated", comment: ""))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(dateColor)
                            .multilineTextAlignment(.leading)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                    }

                    privacySection(
                        titleKey: "privacy_intro_title",
                        textKey: "privacy_intro_text"
                    )

                    privacySection(
                        titleKey: "privacy_collect_title",
                        textKey: "privacy_collect_text"
                    )

                    privacySection(
                        titleKey: "privacy_use_title",
                        textKey: "privacy_use_text"
                    )

                    privacySection(
                        titleKey: "privacy_share_title",
                        textKey: "privacy_share_text"
                    )

                    privacySection(
                        titleKey: "privacy_security_title",
                        textKey: "privacy_security_text"
                    )

                    privacySection(
                        titleKey: "privacy_delete_title",
                        textKey: "privacy_delete_text"
                    )

                    privacySection(
                        titleKey: "privacy_rights_title",
                        textKey: "privacy_rights_text"
                    )

                    privacySection(
                        titleKey: "privacy_changes_title",
                        textKey: "privacy_changes_text"
                    )

                    privacySection(
                        titleKey: "privacy_contact_title",
                        textKey: "privacy_contact_text"
                    )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 50)
            }
            .background(sheetBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#9A86D0"))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(
                                        isDark
                                        ? Color.white.opacity(0.10)
                                        : Color.black.opacity(0.06)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        NSLocalizedString("close", comment: "")
                    )
                }
            }
            .toolbarBackground(
                sheetBackground,
                for: .navigationBar
            )
            .toolbarBackground(
                .visible,
                for: .navigationBar
            )
        }
        .environment(
            \.layoutDirection,
            currentLayoutDirection
        )
    }

    private func privacySection(
        titleKey: String,
        textKey: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString(titleKey, comment: ""))
                .font(.system(size: 19, weight: .black))
                .foregroundColor(sectionTitleColor)
                .multilineTextAlignment(.leading)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Text(NSLocalizedString(textKey, comment: ""))
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(bodyTextColor)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
}

// MARK: - Apple Sign In Coordinator

private final class AppleSignInCoordinator:
    NSObject,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {

    private let onComplete: (Result<ASAuthorization, Error>) -> Void

    init(
        onComplete: @escaping (Result<ASAuthorization, Error>) -> Void
    ) {
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

    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first ?? ASPresentationAnchor()
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
