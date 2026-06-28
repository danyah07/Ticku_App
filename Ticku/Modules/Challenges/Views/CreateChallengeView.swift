//
//  CreateChallengeView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI
import TipKit

struct CreateChallengeView: View {

    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = CreateChallengeViewModel()
    private let enterTimeTip = EnterTimeTip()
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var onBack: () -> Void = {}
    var onCreated: (Challenge) -> Void = { _ in }

    private var selectedPurple: Color {
        Color(hex: "#4C3882")
    }

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {

                ZStack {
                    Text("Create Challenge")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isDark ? .white : Color.black.opacity(0.65))
                        .frame(maxWidth: .infinity, alignment: .center)

                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isDark ? .white : .black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 23)
                .padding(.top, 5)
                .padding(.bottom, 48)
                .background(Color.clear)
                .zIndex(1)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        fieldLabel("Challenge name")
                        inputField(placeholder: "e.g. 30-Day Grind", text: $vm.challengeName)
                            .padding(.horizontal, 23)
                            .padding(.bottom, 28)

                        fieldLabel("Challenge type")

                        HStack(spacing: 8) {
                            ForEach(ChallengeType.allCases) { type in
                                Button(action: { vm.selectedType = type }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: type.icon)
                                            .font(.system(size: 17, weight: .bold))

                                        Text(type.label)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .foregroundColor(vm.selectedType == type ? .white : typeUnselectedTextColor)
                                    .frame(width: 174, height: 52)
                                    .background(typeBackground(selected: vm.selectedType == type))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(typeStrokeColor(selected: vm.selectedType == type), lineWidth: 1)
                                    )
                                    .shadow(
                                        color: vm.selectedType == type ? .clear : Color.black.opacity(isDark ? 0 : 0.15),
                                        radius: vm.selectedType == type ? 0 : 4,
                                        x: 0,
                                        y: vm.selectedType == type ? 0 : 4
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .padding(.bottom, 24)

                        fieldLabel("Duration")

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(DurationOption.allCases) { option in
                                    Button(action: { vm.selectedDuration = option }) {
                                        Text(option.rawValue == "today" ? "today" : option.rawValue)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(vm.selectedDuration == option ? .white : durationUnselectedTextColor)
                                            .padding(.horizontal, 25)
                                            .frame(height: 46)
                                            .background(durationBackground(selected: vm.selectedDuration == option))
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .stroke(durationStrokeColor(selected: vm.selectedDuration == option), lineWidth: 1)
                                            )
                                            .shadow(
                                                color: vm.selectedDuration == option ? .clear : Color.black.opacity(isDark ? 0 : 0.15),
                                                radius: vm.selectedDuration == option ? 0 : 4,
                                                x: 0,
                                                y: vm.selectedDuration == option ? 0 : 4
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .fixedSize()
                                }
                            }
                            .padding(.horizontal, 23)
                            .padding(.vertical, 10)
                        }
                        .padding(.bottom, 22)

                        if vm.showTimePicker {
                            purpleTimePicker
                                .padding(.horizontal, 23)
                                .padding(.bottom, 22)
                                .popoverTip(enterTimeTip, arrowEdge: .top)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        EnterTimeTip.hasSeenTimePickerBefore = true
                                    }
                                }
                        }

                        fieldLabel("Challenge rule")
                        inputField(placeholder: "e.g. Punishment or Reward", text: $vm.challengeRule)
                            .padding(.horizontal, 23)
                            .padding(.bottom, 40)
                    }
                }

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
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 250, height: 52)
                        .background(createButtonBackground)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(isDark ? 0 : 0.25), radius: 4, x: 0, y: 4)
                    }
                    .disabled(!vm.isFormValid || vm.isLoading)

                    Spacer()
                }
                .padding(.vertical, 20)
                .background(Color.clear)
            }

            if let msg = vm.errorMessage {
                VStack {
                    Spacer()

                    Text(msg)
                        .font(Font.ticku.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.ticku.errorRed.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
                        .onTapGesture { vm.errorMessage = nil }
                }
            }
        }
        .navigationBarHidden(true)
        .withErrorHandling()
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
            Color.white.ignoresSafeArea()
        }
    }

    private var createButtonBackground: Color {
        guard vm.isFormValid else {
            return isDark ? Color(hex: "#4C3882").opacity(0.35) : Color(hex: "#C4C4C4")
        }
        return selectedPurple
    }

    private var typeUnselectedTextColor: Color {
        isDark ? .white : .black
    }

    private var durationUnselectedTextColor: Color {
        isDark ? .white : Color(hex: "#341D71")
    }

    private func typeBackground(selected: Bool) -> Color {
        selected ? selectedPurple : (isDark ? Color(hex: "#2A2A2A") : Color.white)
    }

    private func typeStrokeColor(selected: Bool) -> Color {
        selected ? .clear : (isDark ? Color(hex: "#3B3B3B") : Color(hex: "#C5BFBF"))
    }

    private func durationBackground(selected: Bool) -> Color {
        selected ? selectedPurple : (isDark ? Color(hex: "#2A2A2A") : Color.white)
    }

    private func durationStrokeColor(selected: Bool) -> Color {
        selected ? .clear : (isDark ? Color(hex: "#3B3B3B") : Color(hex: "#C5BFBF"))
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
        .background(isDark ? selectedPurple.opacity(0.75) : Color(hex: "#341D71"))
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
                .background(isDark ? Color(hex: "#E0D6FA") : Color(hex: "#D4CCE8"))
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
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71").opacity(0.65))
            .padding(.horizontal, 23)
            .padding(.bottom, 7)
    }

    private func inputField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 14))
            .foregroundColor(isDark ? .white : Color.ticku.textPrimary)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(inputFieldBackground(isEmpty: text.wrappedValue.isEmpty))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isDark ? Color.white.opacity(0.15) : Color(hex: "#E2DDEF"), lineWidth: 1.5)
            )
    }

    private func inputFieldBackground(isEmpty: Bool) -> Color {
        if isDark {
            return isEmpty ? Color(hex: "#2A2A2A") : Color(hex: "#303030")
        }
        return isEmpty ? Color(hex: "#F0EFF7") : Color.white
    }
}

#Preview("Light") {
    CreateChallengeView()
        .environmentObject(AuthViewModel())
}

#Preview("Dark") {
    CreateChallengeView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
