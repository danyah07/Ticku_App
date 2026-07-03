//
//  AllChallengesView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 13/06/2026.
//

//
//  AllChallengesView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 13/06/2026.
//

import SwiftUI

struct AllChallengesView: View {

    @ObservedObject var vm: HomeViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var onBack: () -> Void = {}
    var onViewRoom: (Challenge) -> Void = { _ in }
    var onMyTasks: (Challenge) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if vm.activeChallenges.isEmpty {
                        EmptyStateView()
                            .padding(.horizontal, 23)
                            .padding(.top, 40)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(vm.activeChallenges) { challenge in
                                ChallengeCard(
                                    challenge: challenge,
                                    isDark: isDark,
                                    onViewRoom: { onViewRoom(challenge) },
                                    onMyTasks: { onMyTasks(challenge) }
                                )
                            }
                        }
                        .padding(.horizontal, 23)
                        .padding(.bottom, 32)
                    }
                }
                .padding(.top, 100)
            }

            fixedHeader
                .background(isDark ? Color.black : Color.white)
        }
        .navigationBarHidden(true)
        .task {
            if let uid = authVM.currentUserId {
                await vm.loadHome(for: uid)
            }
        }
    }

    private var fixedHeader: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isDark ? .white : .black)
            }

            Spacer()

            Text(NSLocalizedString("active_challenges", comment: ""))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isDark ? .white : Color.black.opacity(0.65))

            Spacer()

            Color.clear.frame(width: 24)
        }
        .padding(.horizontal, 23)
        .padding(.top, 5)
        .frame(height: 64)
    }

    @ViewBuilder
    private var backgroundView: some View {
        isDark ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
    }
}

private struct ChallengeCard: View {
    let challenge: Challenge
    let isDark: Bool
    var onViewRoom: () -> Void
    var onMyTasks: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text("\(challenge.memberCount) \(NSLocalizedString("participants", comment: "")) | \(challenge.durationLabel) \(NSLocalizedString("days_left", comment: ""))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.62))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .environment(\.locale, Locale(identifier: "en_US"))
                }

                Spacer()

                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            HStack(spacing: -8) {
                ForEach(0..<max(challenge.memberCount, 0), id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: "#F2F2F7"))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#341D71"))
                        )
                        .overlay(
                            Circle().stroke(Color(hex: "#341D71"), lineWidth: 2)
                        )
                }
            }

            HStack(spacing: 12) {
                Button(action: onViewRoom) {
                    Text(NSLocalizedString("view_room", comment: ""))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .frame(height: 57)
                }
                .liquidGlassButton(
                    tint: .white,
                    cornerRadius: 28,
                    intensity: 0.10
                )

                Button(action: onMyTasks) {
                    Text(NSLocalizedString("my_tasks", comment: ""))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .frame(height: 57)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(isDark ? Color(hex: "#341D71").opacity(0.20) : Color(hex: "#341D71"))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(isDark ? Color(hex: "#8E8AC5").opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .liquidGlass(
            tint: isDark ? Color(hex: "#341D71").opacity(0.20) : Color(hex: "#341D71"),
            cornerRadius: 26,
            intensity: isDark ? 0.18 : 0.35
        )
        .shadow(
            color: .black.opacity(isDark ? 0 : 0.25),
            radius: 4,
            x: 0,
            y: 4
        )
    }
}

#Preview("Light") {
    NavigationStack {
        AllChallengesView(vm: HomeViewModel())
            .environmentObject(AuthViewModel())
    }
}
