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

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Header ────────────────────────────────
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("#8B8B9E"))
                        Text("Get started")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color("#1A1A2E"))
                    }
                    Spacer()
                    Button(action: onSignIn) {
                        Text("Sign in")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("#6B5CE7"))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 26)

                // ── Today's Tasks ──────────────────────────
                Text("Today's Tasks")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("#1A1A2E"))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
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
                        .foregroundColor(Color("#1A1A2E"))
                    Spacer()
                    Text("See all")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("#6B5CE7").opacity(0.4))
                }
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 12)

                EmptyStateView()
                    .padding(.horizontal, 20)

                // ── CTA Buttons ────────────────────────────
                HStack(spacing: 12) {
                    PrimaryButtonView(title: "+ Create", style: .solid, action: onCreateChallenge)
                    PrimaryButtonView(title: "Join", style: .muted, action: onJoinChallenge)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
    }
}
