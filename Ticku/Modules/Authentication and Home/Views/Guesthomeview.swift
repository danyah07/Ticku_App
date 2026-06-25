//
//  Guesthomeview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

import SwiftUI

struct GuestHomeView: View {
    var onSignIn: () -> Void
    var onCreateChallenge: () -> Void
    var onJoinChallenge: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Header ────────────────────────────────
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isDark ? .white.opacity(0.5) : Color(hex: "#8B8B9E"))
                        Text("Get started")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(isDark ? .white : Color(hex: "#1A1A2E"))
                    }
                    Spacer()
                    Button(action: onSignIn) {
                        Text("Sign in")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isDark ? Color(hex: "#B296EB") : Color(hex: "#6B5CE7"))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 26)

                // ── Today's Tasks ──────────────────────────
                Text("Today's Tasks")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isDark ? .white : Color(hex: "#1A1A2E"))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isDark ? Color.white.opacity(0.04) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isDark ? Color(hex: "#B296EB").opacity(0.2) : Color.clear, lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(isDark ? 0 : 0.05), radius: 10, x: 0, y: 4)
                        .overlay(ProgressRingView(percentage: 0))
                        .frame(height: 160)

                    StatsSidePanelView(tasksCompleted: 0, wins: 0)
                        .frame(height: 160)
                }
                .padding(.horizontal, 20)

                // ── Active Challenge ───────────────────────
                HStack {
                    Text("Active Challenge")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(isDark ? .white : Color(hex: "#1A1A2E"))
                    Spacer()
                    Text("See all")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor((isDark ? Color(hex: "#B296EB") : Color(hex: "#6B5CE7")).opacity(0.4))
                }
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 12)

                EmptyStateView()
                    .padding(.horizontal, 20)

                // ── CTA Buttons ────────────────────────────
                // ✅ تستدعي onCreateChallenge/onJoinChallenge اللي تجي من HomeView
                // مربوطة فعلياً بـ onSignIn للضيف (راجع HomeView.swift) — مايصل لصفحة حقيقية بدون حساب
                HStack(spacing: 12) {
                    PrimaryButtonView(title: "+ Create", style: .solid, action: onCreateChallenge)
                    PrimaryButtonView(title: "Join", style: .muted, action: onJoinChallenge)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .background(backgroundView)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            Color(hex: "#0A0814").ignoresSafeArea()
        } else {
            Color.clear
        }
    }
}

#Preview("Light") {
    GuestHomeView(onSignIn: {}, onCreateChallenge: {}, onJoinChallenge: {})
}

#Preview("Dark") {
    GuestHomeView(onSignIn: {}, onCreateChallenge: {}, onJoinChallenge: {})
        .preferredColorScheme(.dark)
}
