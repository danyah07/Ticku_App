//
//  CreateChallengeView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct CreateChallengeView: View {

    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = CreateChallengeViewModel()

    var onBack: () -> Void = {}
    var onCreated: (Challenge) -> Void = { _ in }

    var body: some View {
        ZStack {
            Color(hex: "#F5F4FB").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Nav Bar ───────────────────────────────
                ZStack {
                    Text("Create Challenge")
                        .font(Font.ticku.sectionHeader)
                        .foregroundColor(Color.ticku.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.ticku.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 20)
                .background(Color(hex: "#F5F4FB"))
                .zIndex(1)

                // ── Scrollable Content ────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        fieldLabel("Challenge name")
                        inputField(placeholder: "e.g. 30-Day Grind", text: $vm.challengeName)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 28)

                        fieldLabel("Duration")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(DurationOption.allCases) { option in
                                    Button(action: { vm.selectedDuration = option }) {
                                        Text(option.rawValue == "today" ? "Today" : option.rawValue)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(vm.selectedDuration == option ? .white : Color.ticku.primary)
                                            .padding(.horizontal, 22)
                                            .frame(height: 44)
                                            .fixedSize()
                                            .background(vm.selectedDuration == option ? Color.ticku.primary : Color.white)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule().stroke(
                                                    vm.selectedDuration == option ? Color.clear : Color(hex: "#DDDAEE"),
                                                    lineWidth: 1.5
                                                )
                                            )
                                    }
                                    .fixedSize()
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 5)
                        }
                        .padding(.bottom, 16)

                        if vm.showTimePicker {
                            purpleTimePicker
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                        }

                        fieldLabel("Challenge rule")
                        inputField(placeholder: "e.g. Punishment or Reward", text: $vm.challengeRule)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 8)
                }

                // ── Create Button ─────────────────────────
                HStack {
                    Spacer()
                    Button {
                        Task {
                            guard let uid = authVM.currentUserId else { return }
                            if let challenge = await vm.createChallenge(creatorId: uid, creatorName: uid) {
                                onCreated(challenge)
                            }
                        }
                    } label: {
                        ZStack {
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 220, height: 44)
                        .background(vm.isFormValid ? Color.ticku.primary : Color(hex: "#C4C4C4"))
                        .clipShape(Capsule())
                    }
                    .disabled(!vm.isFormValid || vm.isLoading)
                    Spacer()
                }
                .padding(.vertical, 20)
                .background(Color(hex: "#F5F4FB"))
            }

            if let msg = vm.errorMessage {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(Font.ticku.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Color.ticku.errorRed.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
                        .onTapGesture { vm.errorMessage = nil }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var purpleTimePicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Enter time")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 20)
                .padding(.leading, 20)
                .padding(.bottom, 12)

            HStack(spacing: 0) {
                timeBox(text: $vm.hourText, max: 23, label: "Hour")
                Text(":")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24)
                timeBox(text: $vm.minuteText, max: 59, label: "Minute")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#341D71"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    @ViewBuilder
    private func timeBox(text: Binding<String>, max: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("00", text: text)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "#341D71"))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(Color(hex: "#D4CCE8"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onChange(of: text.wrappedValue) { _, val in
                    var f = val.filter { $0.isNumber }
                    if f.count > 2 { f = String(f.suffix(2)) }
                    if let n = Int(f), n > max { f = String(max) }
                    if f != text.wrappedValue { text.wrappedValue = f }
                }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Color.ticku.primary.opacity(0.65))
            .padding(.horizontal, 24)
            .padding(.bottom, 7)
    }

    private func inputField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 14))
            .foregroundColor(Color.ticku.textPrimary)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(text.wrappedValue.isEmpty ? Color(hex: "#F0EFF7") : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#E2DDEF"), lineWidth: 1.5)
            )
    }
}

#Preview {
    CreateChallengeView()
        .environmentObject(AuthViewModel())
}
