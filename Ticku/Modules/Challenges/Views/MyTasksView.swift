//
//  AddTaskViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI
import FirebaseFirestore

struct MyTasksView: View {

    var challengeId: String = ""
    var userId: String = ""
    var onComplete: (() -> Void)? = nil

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var service = ChallengeTaskService()
    @State private var newTaskText: String = ""
    @State private var isAdding: Bool = false
    @State private var isSaved: Bool = false
    @State private var challengeStarted: Bool = false
    @FocusState private var inputFocused: Bool

    private let db = Firestore.firestore()
    @State private var challengeListener: ListenerRegistration? = nil

    private var isDark: Bool { colorScheme == .dark }

    var tasks: [ChallengeTask] { service.tasks }
    var completedCount: Int { tasks.filter { $0.isCompleted }.count }
    var progress: Double { tasks.isEmpty ? 0 : Double(completedCount) / Double(tasks.count) }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Nav Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isDark ? .white : Color(hex: "#1A1A2E"))
                }
                Spacer()
                Text("Your tasks")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isDark ? .white : Color(hex: "#1A1A2E"))
                Spacer()
                if isAdding {
                    Button("Save") {
                        withAnimation(.easeInOut) { isAdding = false }
                        inputFocused = false
                        isSaved = true
                        newTaskText = ""
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71"))
                } else if isSaved && !challengeStarted {
                    Button("Edit") {
                        withAnimation(.easeInOut) { isSaved = false; isAdding = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { inputFocused = true }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71"))
                } else {
                    Color.clear.frame(width: 40, height: 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 50)

            // MARK: - Progress Ring
            ZStack {
                Circle().fill(isDark ? Color(hex: "#3A3550") : Color.clear)
                Circle().stroke(isDark ? Color.white.opacity(0.1) : Color(hex: "#E8E5F5"), lineWidth: 12)
                Circle().trim(from: 0, to: progress)
                    .stroke(isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: progress)
                Text(tasks.isEmpty ? "%0" : "%\(Int(progress * 100))")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isDark ? .white : Color(hex: "#341D71"))
            }
            .frame(width: 130, height: 130)
            .padding(.bottom, 80)

            // MARK: - Tasks Container
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(isDark ? Color(hex: "#15111F") : Color.white)
                    .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    if tasks.isEmpty && !isAdding {
                        Text("Tap 'Add a task' below to get started!")
                            .font(.system(size: 13))
                            .foregroundColor((isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71")).opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 40)
                    }

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(tasks) { task in
                                taskRow(task: task)
                                if task.id != tasks.last?.id || isAdding {
                                    Divider().padding(.leading, 50)
                                }
                            }
                            if isAdding {
                                HStack(spacing: 10) {
                                    Button(action: { submitTask() }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(addButtonBackground)
                                                .frame(width: 26, height: 26)
                                            Image(systemName: "plus")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(addButtonIconColor)
                                        }
                                        .animation(.easeInOut(duration: 0.2), value: newTaskText.isEmpty)
                                    }
                                    .disabled(newTaskText.isEmpty)

                                    TextField("Add a task...", text: $newTaskText)
                                        .font(.system(size: 14))
                                        .foregroundColor(isDark ? .white : Color(hex: "#1A1A2E"))
                                        .focused($inputFocused)
                                        .onSubmit { submitTask() }
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                            }
                        }
                        .padding(.bottom, 120)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(backgroundView)
        .safeAreaInset(edge: .bottom) {
            if !isAdding && !isSaved {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut) { isAdding = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { inputFocused = true }
                    }) {
                        Text("Add a task")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 46)
                            .background(Color(hex: "#341D71"))
                            .cornerRadius(23)
                            .shadow(color: (isDark ? Color.clear : Color(hex: "#341D71")).opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    Spacer()
                }
                .padding(.top, 12).padding(.bottom, 36)
                .background(Color.clear)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            guard !challengeId.isEmpty, !userId.isEmpty else { return }
            service.listenToTasks(challengeId: challengeId, userId: userId)
            startChallengeListener()
        }
        .onChange(of: service.tasks) {
            if !service.tasks.isEmpty && !isAdding {
                isSaved = true
            }
        }
        .onChange(of: progress) {
            if progress >= 1.0 && !tasks.isEmpty && challengeStarted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete?()
                }
            }
        }
        .onDisappear {
            service.stopListening()
            challengeListener?.remove()
        }
        .withErrorHandling()
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            Color(hex: "#0A0814")
        } else {
            Color(hex: "#F5F4FB")
        }
    }

    private var addButtonBackground: Color {
        if newTaskText.isEmpty {
            return isDark ? Color.white.opacity(0.1) : Color(hex: "#E8E5F5")
        }
        return isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71")
    }

    private var addButtonIconColor: Color {
        if newTaskText.isEmpty {
            return (isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71")).opacity(0.4)
        }
        return isDark ? Color(hex: "#E0D6FA") : .white
    }

    // MARK: - Listen to challenge startDate from Firebase
    private func startChallengeListener() {
        guard !challengeId.isEmpty else { return }
        challengeListener = db.collection("challenges").document(challengeId)
            .addSnapshotListener { snap, _ in
                if let ts = snap?.data()?["startDate"] as? Timestamp {
                    challengeStarted = ts.dateValue() <= Date()
                } else {
                    challengeStarted = false
                }
            }
    }

    @ViewBuilder
    private func taskRow(task: ChallengeTask) -> some View {
        HStack(spacing: 10) {
            if isSaved {
                Button(action: {
                    service.toggleTask(challengeId: challengeId, userId: userId, task: task)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(task.isCompleted ? (isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71")) : (isDark ? Color.white.opacity(0.1) : Color(hex: "#E8E5F5")))
                            .frame(width: 24, height: 24)
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(isDark ? Color(hex: "#E0D6FA") : .white)
                        }
                    }
                }
            } else {
                Button(action: {
                    service.deleteTask(challengeId: challengeId, userId: userId, taskId: task.id)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill((isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71")).opacity(0.7))
                            .frame(width: 24, height: 24)
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 10, height: 2)
                            .cornerRadius(1)
                    }
                }
            }

            Text(task.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(taskTextColor(isCompleted: task.isCompleted))
                .strikethrough(task.isCompleted && isSaved)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if !isSaved {
                Button(role: .destructive) {
                    service.deleteTask(challengeId: challengeId, userId: userId, taskId: task.id)
                } label: { Label("Delete", systemImage: "trash") }
            }
        }
    }

    private func taskTextColor(isCompleted: Bool) -> Color {
        if isCompleted && isSaved {
            return (isDark ? Color.white : Color(hex: "#1A1A2E")).opacity(0.4)
        }
        return isDark ? .white : Color(hex: "#1A1A2E")
    }

    private func submitTask() {
        let trimmed = newTaskText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        service.addTask(challengeId: challengeId, userId: userId, title: trimmed)
        newTaskText = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { inputFocused = true }
    }
}

#Preview("Light") { MyTasksView(challengeId: "demo", userId: "user1") }

#Preview("Dark") {
    MyTasksView(challengeId: "demo", userId: "user1")
        .preferredColorScheme(.dark)
}
