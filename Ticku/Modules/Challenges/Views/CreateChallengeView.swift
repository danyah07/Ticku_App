//
//  CreateChallengeView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct CreateChallengeView: View {

    @StateObject private var vm = CreateChallengeViewModel()
    @State private var navigateTo: Challenge? = nil
    @State private var showAddTasks: Bool = false

    var currentUserId: String = ""
    var currentUserName: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                // Nav Bar
                ZStack {
                    Text("Create Challenge")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A2E"))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A1A2E"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 70)

                // Challenge name
                Text("Challenge name")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#341D71").opacity(0.65))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 7)

                inputField(placeholder: "e.g. 30-Day Grind", text: $vm.challengeName)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                // Duration
                Text("Duration")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#341D71").opacity(0.65))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DurationOption.allCases) { option in
                            Button(action: { vm.selectedDuration = option }) {
                                Text(option.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(vm.selectedDuration == option ? .white : Color(hex: "#341D71"))
                                    .padding(.horizontal, 16)
                                    .frame(height: 34)
                                    .fixedSize()
                                    .background(vm.selectedDuration == option ? Color(hex: "#341D71") : Color.white)
                                    .cornerRadius(17)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 17)
                                            .stroke(
                                                vm.selectedDuration == option ? Color.clear : Color(hex: "#DDDAEE"),
                                                lineWidth: 1.0
                                            )
                                    )
                                    .shadow(color: Color(hex: "#341D71").opacity(0.15), radius: 2, x: 0, y: 3)
                            }
                            .fixedSize()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 5)
                }
                .padding(.bottom, 16)

                // Time Picker
                if vm.showTimePicker {
                    TimePickerBoxView(hourText: $vm.hourText, minuteText: $vm.minuteText)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }

                // Challenge rule
                Text("Challenge rule")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#341D71").opacity(0.65))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 7)

                inputField(placeholder: "e.g. Punishment or Reward", text: $vm.challengeRule)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                // Add Tasks Button — يظهر عدد المهام لو في
                Button(action: { showAddTasks = true }) {
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundColor(Color(hex: "#341D71"))
                        Text(vm.tasks.isEmpty ? "Add tasks" : "\(vm.tasks.count) tasks added")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#341D71"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#341D71").opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 46)
                    .background(Color(hex: "#F0EFF7"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#E2DDEF"), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 24)

                Spacer()

                // Create Button
                HStack {
                    Spacer()
                    Button(action: {
                        if let c = vm.createChallenge() {
                            navigateTo = c
                        }
                    }) {
                        Text("Create")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 220, height: 44)
                            .background(vm.isFormValid ? Color(hex: "#341D71") : Color(hex: "#AFAFB7"))
                            .cornerRadius(22)
                    }
                    .disabled(!vm.isFormValid)
                    Spacer()
                }
                .padding(.bottom, 70)
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(hex: "#F5F4FB"))
            .ignoresSafeArea(edges: .bottom)
            .toolbar(.hidden, for: .navigationBar)
            // الانتقال لـ ChallengeDetailView
            .navigationDestination(item: $navigateTo) { challenge in
                ChallengeDetailView(
                    challenge: challenge,
                    currentUserId: currentUserId,
                    currentUserName: currentUserName
                )
            }
            // الانتقال لـ AddTasksView
            .navigationDestination(isPresented: $showAddTasks) {
                AddTasksView(tasks: vm.tasks) { savedTasks in
                    vm.tasks = savedTasks
                }
            }
        }
    }

    private func inputField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 14))
            .foregroundColor(Color(hex: "#1A1A2E"))
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(text.wrappedValue.isEmpty ? Color(hex: "#F0EFF7") : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#E2DDEF"), lineWidth: 1.5)
            )
    }
}

// MARK: - Time Picker
struct TimePickerBoxView: View {
    @Binding var hourText: String
    @Binding var minuteText: String

    @FocusState private var focusedField: TimeField?
    enum TimeField { case hour, minute }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Enter time")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 24)
                .padding(.leading, 24)
                .padding(.bottom, 12)

            HStack(spacing: 0) {
                timeBox(text: $hourText, field: .hour, max: 23, label: "Hour")
                Text(":")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 20)
                timeBox(text: $minuteText, field: .minute, max: 59, label: "Minute")
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#341D71"))
        .cornerRadius(28)
    }

    @ViewBuilder
    private func timeBox(text: Binding<String>, field: TimeField, max: Int, label: String) -> some View {
        let isActive = focusedField == field
        VStack(alignment: .leading, spacing: 6) {
            TextField("00", text: text)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(text.wrappedValue.isEmpty
                    ? Color(hex: "#341D71").opacity(0.4)
                    : Color(hex: "#341D71")
                )
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: field)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(Color(hex: "#D4CCE8"))
                .cornerRadius(8)
                .shadow(
                    color: isActive ? Color(hex: "#341D71").opacity(0.35) : Color.clear,
                    radius: 8, x: 0, y: 4
                )
                .onChange(of: text.wrappedValue) { val in
                    var f = val.filter { $0.isNumber }
                    if f.count > 2 { f = String(f.suffix(2)) }
                    if let n = Int(f), n > max { f = String(max) }
                    if f != text.wrappedValue { text.wrappedValue = f }
                }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(.leading, 4)
        }
    }
}

#Preview {
    CreateChallengeView()
}
