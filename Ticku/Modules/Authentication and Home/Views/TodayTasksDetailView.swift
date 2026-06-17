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

    let activeChallenges: [Challenge]
    var onBack: () -> Void = {}

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Nav Bar
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.ticku.textPrimary)
                    }
                    Text("Today Tasks")
                        .font(Font.ticku.sectionHeader)
                        .foregroundColor(Color.ticku.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, TickuSpacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 20)

                if vm.isLoading {
                    ProgressView().tint(Color.ticku.primary)
                        .padding(.top, 40)
                } else {
                    // Progress Ring
                    progressRingSection
                        .padding(.top, 20)
                        .padding(.bottom, 20)

                    if vm.taskGroups.allSatisfy({ $0.tasks.isEmpty }) {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 40))
                                .foregroundColor(Color.ticku.accent.opacity(0.4))
                            Text("No tasks yet")
                                .font(Font.ticku.bodyMedium)
                                .foregroundColor(Color.ticku.textSecondary)
                            Text("Add tasks inside a challenge to track them here.")
                                .font(Font.ticku.caption)
                                .foregroundColor(Color.ticku.textSecondary.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                    } else {
                        VStack(spacing: 20) {
                            ForEach(vm.taskGroups) { group in
                                if !group.tasks.isEmpty {
                                    TaskGroupSection(
                                        group: group,
                                        onToggle: { task in
                                            Task {
                                                await vm.toggleTask(task, in: group.challenge.id ?? "")
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, TickuSpacing.screenH)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(hex: "#F5F4FA").ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            if let uid = authVM.currentUserId {
                await vm.load(uid: uid, activeChallenges: activeChallenges)
            }
        }
    }

    private var progressRingSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.ticku.accent.opacity(0.15), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: vm.overallProgress)
                    .stroke(Color.ticku.primary, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.2), value: vm.overallProgress)
                Text("\(Int(vm.overallProgress * 100))%")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color.ticku.textPrimary)
            }
            .frame(width: 180, height: 180)

            Text("\(vm.completedTasks) of \(vm.totalTasks) tasks done")
                .font(Font.ticku.caption)
                .foregroundColor(Color.ticku.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Task Group Section
private struct TaskGroupSection: View {
    let group: ChallengeTaskGroup
    var onToggle: (TickuTask) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.challenge.title)
                .font(Font.ticku.captionBold)
                .foregroundColor(Color.ticku.textSecondary)
                .padding(.leading, 8)
                .padding(.bottom, 2)

            VStack(spacing: 0) {
                ForEach(group.tasks) { task in
                    TaskRowItem(task: task, onToggle: { onToggle(task) })
                    if task.id != group.tasks.last?.id {
                        Divider().padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: TickuRadius.lg))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Task Row
private struct TaskRowItem: View {
    let task: TickuTask
    var onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(task.isCompleted ? Color.ticku.primary : Color(hex: "#E5E5EA"))
                        .frame(width: 26, height: 26)
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(Font.ticku.body)
                .foregroundColor(task.isCompleted ? Color.ticku.textSecondary : Color.ticku.textPrimary)
                .strikethrough(task.isCompleted, color: Color.ticku.textSecondary)
                .animation(.easeInOut(duration: 0.15), value: task.isCompleted)

            Spacer()

            if let due = task.dueDate {
                Text(due.shortDate)
                    .font(Font.ticku.caption)
                    .foregroundColor(Color.ticku.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
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

#Preview {
    TodayTasksDetailView(activeChallenges: [])
        .environmentObject(AuthViewModel())
}
