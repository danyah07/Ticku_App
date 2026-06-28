//
//  TodayTasksDetailView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 05/06/2026.
//

import SwiftUI

struct TodayTasksDetailView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = TodayTasksDetailViewModel()
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    let activeChallenges: [Challenge]
    var onBack: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    if vm.isLoading {
                        ProgressView()
                            .tint(isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"))
                            .padding(.top, 40)
                    } else {
                        progressRingSection
                            .padding(.top, 10)
                            .padding(.bottom, 42)

                        if vm.taskGroups.allSatisfy({ $0.tasks.isEmpty }) {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(isDark ? Color(hex: "#8E8AC5").opacity(0.45) : Color(hex: "#341D71").opacity(0.35))

                                Text("No tasks yet")
                                    .font(Font.ticku.bodyMedium)
                                    .foregroundColor(isDark ? .white.opacity(0.65) : Color.ticku.textSecondary)

                                Text("Add tasks inside a challenge to track them here.")
                                    .font(Font.ticku.caption)
                                    .foregroundColor(isDark ? .white.opacity(0.45) : Color.ticku.textSecondary.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, 20)
                        } else {
                            VStack(spacing: 22) {
                                ForEach(vm.taskGroups) { group in
                                    if !group.tasks.isEmpty {
                                        TaskGroupSection(
                                            group: group,
                                            isDark: isDark,
                                            onToggle: { task in
                                                Task {
                                                    await vm.toggleTask(task, in: group.challenge.id ?? "")
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 23)
                        }
                    }
                }
                .padding(.top, 62)
                .padding(.bottom, 32)
            }

            fixedHeader
        }
        .navigationBarHidden(true)
        .task {
            if let uid = authVM.currentUserId {
                await vm.load(uid: uid, activeChallenges: activeChallenges)
            }
        }
    }

    private var fixedHeader: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isDark ? .white : .black)
            }

            Spacer()

            Text("Today Tasks")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isDark ? .white : Color.black.opacity(0.65))
            Spacer()

            Color.clear.frame(width: 24)
        }
        .padding(.horizontal, 23)
        .padding(.top, 5)
        .frame(height: 52)
        .background(isDark ? Color.black : Color.white)
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            Color.black.ignoresSafeArea()
        } else {
            Color.white.ignoresSafeArea()
        }
    }

    private var progressRingSection: some View {
        VStack(spacing: 0) {
            ZStack {
                if vm.overallProgress > 0 {
                    Circle()
                        .trim(from: 0, to: vm.overallProgress)
                        .stroke(
                            isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71"),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.2), value: vm.overallProgress)
                }

                Circle()
                    .fill(isDark ? Color(hex: "#212122") : Color(hex: "#F2F2F7"))
                    .frame(width: 136, height: 136)

                Text("\(Int(vm.overallProgress * 100))%")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(isDark ? .white : .black)
            }
            .frame(width: 170, height: 170)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TaskGroupSection: View {
    let group: ChallengeTaskGroup
    let isDark: Bool
    var onToggle: (TickuTask) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.challenge.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isDark ? .white.opacity(0.75) : Color.black.opacity(0.55))
                .padding(.leading, 8)

            VStack(spacing: 0) {
                ForEach(group.tasks) { task in
                    TaskRowItem(task: task, isDark: isDark, onToggle: { onToggle(task) })

                    if task.id != group.tasks.last?.id {
                        Divider()
                            .background(isDark ? Color.white.opacity(0.12) : Color(hex: "#D5D5D5"))
                    }
                }
            }
            .background(isDark ? Color(hex: "#171717") : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isDark ? Color(hex: "#303030") : Color(hex: "#D5D5D5"), lineWidth: 1)
            )
        }
    }
}

private struct TaskRowItem: View {
    let task: TickuTask
    let isDark: Bool
    var onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(task.isCompleted ? Color(hex: "#8E8AC5") : (isDark ? Color(hex: "#2A2A2A") : Color(hex: "#D9D9D9")))
                    .frame(width: 26, height: 26)
                    .overlay {
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isDark ? Color.white.opacity(0.12) : Color.clear, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(Font.ticku.body)
                .foregroundColor(task.isCompleted ? (isDark ? .white.opacity(0.45) : Color.ticku.textSecondary) : (isDark ? .white : Color.ticku.textPrimary))
                .strikethrough(task.isCompleted, color: isDark ? .white.opacity(0.45) : Color.ticku.textSecondary)

            Spacer()

            if let due = task.dueDate {
                Text(due.shortDate)
                    .font(Font.ticku.caption)
                    .foregroundColor(isDark ? .white.opacity(0.45) : Color.ticku.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}

private extension Date {
    var shortDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: self)
    }
}

#Preview("Light") {
    TodayTasksDetailView(activeChallenges: [])
        .environmentObject(AuthViewModel())
}

#Preview("Dark") {
    TodayTasksDetailView(activeChallenges: [])
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
