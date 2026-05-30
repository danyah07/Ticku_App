//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 11/12/1447 AH.
//

import SwiftUI

struct ChallengeDetailsPage: View {

    let challenge: Challenge

    @Environment(\.dismiss) private var dismiss

    @State private var challengeName: String
    @State private var newName: String = ""
    @State private var showNamePopup: Bool = false

    @State private var challengeRole: String
    @State private var showRolePopup: Bool = false
    @State private var newRole: String = ""

    init(challenge: Challenge) {
        self.challenge = challenge
        _challengeName = State(initialValue: challenge.name)
        _challengeRole = State(initialValue: challenge.rule.isEmpty ? "Buy dinner for the group" : challenge.rule)
    }

    var body: some View {

        ZStack {

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    // MARK: - Nav Bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text("Details")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Color.clear.frame(width: 18)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                    // MARK: - Challenge name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chalenge name")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#341D71"))

                        HStack(spacing: 8) {
                            Text(challengeName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)

                            Button {
                                newName = challengeName
                                showNamePopup = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(Color(hex: "#341D71"))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                    // MARK: - Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#341D71"))

                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(Color(hex: "#341D71").opacity(0.6))
                            Text(durationText)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#F0EDF8"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // MARK: - Challenge role
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chalenge role")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#341D71"))

                        HStack(spacing: 8) {
                            Text(challengeRole)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(2)

                            Button {
                                newRole = challengeRole
                                showRolePopup = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(Color(hex: "#341D71"))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .navigationBar)

            // MARK: - Name Popup
            if showNamePopup {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showNamePopup = false }

                editCard(
                    title: "Chalenge name",
                    text: $newName,
                    onCancel: { showNamePopup = false },
                    onSave: {
                        if !newName.isEmpty { challengeName = newName }
                        showNamePopup = false
                    }
                )
            }

            // MARK: - Role Popup
            if showRolePopup {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showRolePopup = false }

                editCard(
                    title: "Chalenge role",
                    text: $newRole,
                    onCancel: { showRolePopup = false },
                    onSave: {
                        if !newRole.isEmpty { challengeRole = newRole }
                        showRolePopup = false
                    }
                )
            }
        }
    }

    // MARK: - Edit Card — نفس شكل الـ sheet
    @ViewBuilder
    private func editCard(
        title: String,
        text: Binding<String>,
        onCancel: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) -> some View {

        VStack(alignment: .leading, spacing: 0) {

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 20)
                .padding(.horizontal, 24)
                .padding(.bottom, 14)

            TextField(title, text: text)
                .font(.system(size: 15))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 24)

            HStack {
                Spacer()
                Text("\(text.wrappedValue.count)/26")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.top, 6)
            .padding(.bottom, 24)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.systemGray5))
                        .cornerRadius(26)
                }

                Button(action: onSave) {
                    Text("Request")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#341D71"))
                        .cornerRadius(26)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
        .padding(.horizontal, 24)
    }

    private var durationText: String {
        switch challenge.duration {
        case .today:
            return String(format: "%02d:%02d:00", challenge.scheduledHour, challenge.scheduledMinute)
        case .days3:  return "3 Days"
        case .days7:  return "7 Days"
        case .days14: return "14 Days"
        case .days30: return "30 Days"
        }
    }
}

#Preview {
    NavigationStack {
        ChallengeDetailsPage(
            challenge: Challenge(
                name: "let's do it",
                duration: .today,
                rule: "Buy dinner for the group",
                scheduledHour: 2,
                scheduledMinute: 30
            )
        )
    }
}
