//
//  Guesthomeview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 14/05/2026.
//

import SwiftUI
import TipKit

struct GuestHomeView: View {
    var onSignIn: () -> Void
    var onCreateChallenge: () -> Void
    var onJoinChallenge: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    private let addTaskTip = AddTaskTip()
    private let createChallengeTip = CreateChallengeTip()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("welcome", comment: ""))
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(isDark ? .white.opacity(0.45) : Color.black.opacity(0.39))

                        Text(NSLocalizedString("get_started", comment: ""))
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(isDark ? .white : .black)
                    }

                    Spacer()

                    Button(action: onSignIn) {
                        Text(NSLocalizedString("sign_in", comment: ""))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#1D73D8"))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 34)
                .padding(.top, 5)
                .padding(.bottom, 50)

                Text(NSLocalizedString("today_tasks", comment: ""))
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(isDark ? .white : Color.black.opacity(0.65))
                    .padding(.horizontal, 34)
                    .padding(.bottom, 8)

                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isDark ? Color.black.opacity(0.18) : Color(hex: "#F6F6F6"))
                        .frame(width: 188, height: 214)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.35) : Color.clear, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(isDark ? 0 : 0.25), radius: 4, x: 0, y: 4)
                        .overlay(
                            ProgressRingView(
                                percentage: 0,
                                ringSize: 120,
                                lineWidth: 10
                            )
                        )
                        .popoverTip(addTaskTip, arrowEdge: .top)

                    FigmaGuestStatsSidePanelView(tasksCompleted: 0, wins: 0, isDark: isDark)
                        .frame(width: 147, height: 217)
                }
                .padding(.horizontal, 23)

                HStack {
                    Text(NSLocalizedString("active_challenges", comment: ""))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(isDark ? .white : Color.black.opacity(0.65))

                    Spacer()

                    Text(NSLocalizedString("see_all", comment: ""))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#4FA2FF"))
                }
                .padding(.horizontal, 34)
                .padding(.top, 30)
                .padding(.bottom, -5)

                HomeGuestEmptyChallengeView(isDark: isDark)
                    .padding(.top, 49)
                    .frame(height: 190)
                    .padding(.horizontal, 20)

                HStack(spacing: 13) {
                    PrimaryButtonView(
                        title: NSLocalizedString("create", comment: ""),
                        style: .solid,
                        action: onCreateChallenge
                    )
                    .popoverTip(createChallengeTip, arrowEdge: .top)

                    PrimaryButtonView(
                        title: NSLocalizedString("join", comment: ""),
                        style: .muted,
                        action: onJoinChallenge
                    )
                }
                .padding(.horizontal, 23)
                .padding(.top, 59)
                .padding(.bottom, 40)
            }
        }
        .background(backgroundView)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                AddTaskTip.hasOpenedHomeBefore = true
            }
            CreateChallengeTip.hasNoActiveChallenges = true
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black,
                    Color(hex: "#3E3C5E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [
                    Color.white,
                    Color.white,
                    Color(hex: "#341D71").opacity(0.69)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

private struct HomeGuestEmptyChallengeView: View {
    let isDark: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(NSLocalizedString("ready_to_compete", comment: ""))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isDark ? .white.opacity(0.55) : Color.black.opacity(0.45))

            Text(NSLocalizedString("create_first_challenge", comment: ""))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isDark ? .white.opacity(0.45) : Color.black.opacity(0.35))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isDark ? Color(hex: "#341D71").opacity(0.20) : Color.white.opacity(0.30))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.35) : Color.clear, lineWidth: 1)
        )
    }
}

private struct FigmaGuestStatsSidePanelView: View {
    let tasksCompleted: Int
    let wins: Int
    let isDark: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack(spacing: 3) {
                    Text("\(tasksCompleted)")
                    Text("✓")
                }
                .environment(\.locale, Locale(identifier: "en"))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#377329"))

                Text(NSLocalizedString("done", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isDark ? .white.opacity(0.65) : Color.black.opacity(0.45))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Rectangle()
                .fill(isDark ? Color.white.opacity(0.18) : Color(hex: "#D5D5D5"))
                .frame(height: 1)

            VStack(spacing: 12) {
                HStack(spacing: 3) {
                    Text("\(wins)")
                    Image(systemName: "trophy")
                }
                .environment(\.locale, Locale(identifier: "en"))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#C57723"))

                Text(NSLocalizedString("wins", comment: ""))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isDark ? .white.opacity(0.65) : Color.black.opacity(0.45))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(isDark ? Color.black.opacity(0.18) : Color(hex: "#F8F8F8"))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(isDark ? Color.white.opacity(0.18) : Color(hex: "#D5D5D5"), lineWidth: 1)
        )
    }
}

#Preview("Light") {
    GuestHomeView(onSignIn: {}, onCreateChallenge: {}, onJoinChallenge: {})
}

#Preview("Dark") {
    GuestHomeView(onSignIn: {}, onCreateChallenge: {}, onJoinChallenge: {})
        .preferredColorScheme(.dark)
}
