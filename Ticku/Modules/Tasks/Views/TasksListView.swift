//
//  TasksListView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct MyTasksView: View {

    let challengeId: String
    let userId: String

    @Environment(\.dismiss) private var dismiss
    @StateObject private var service = ChallengeTaskService()

    @State private var newTaskText: String = ""
    @State private var swipedIndex: Int? = nil

    var progress: Double {
        guard !service.tasks.isEmpty else { return 0 }
        return Double(service.tasks.filter { $0.isCompleted }.count) / Double(service.tasks.count)
    }

    var completedCount: Int { service.tasks.filter { $0.isCompleted }.count }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#FFFFFF"),
                    Color(hex: "#F2ECFA"),
                    Color(hex: "#D6C9F0"),
                    Color(hex: "#7B5BC7")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // Nav Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A1A2E"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 20)

                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#DDD8F5"), lineWidth: 16)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color(hex: "#341D71"),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: progress)

                    VStack(spacing: 4) {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(Color(hex: "#341D71"))
                        Text("\(completedCount)/\(service.tasks.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#341D71").opacity(0.5))
                    }
                }
                .padding(.bottom, 30)

                // Title
                HStack {
                    Text("My Tasks")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#341D71"))
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)

                // Add tasks field
                HStack(spacing: 0) {
                    TextField("add your tasks", text: $newTaskText)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#1A1A2E"))
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .submitLabel(.done)
                        .onSubmit { addTask() }

                    Button(action: addTask) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#341D71").opacity(0.5))
                            .padding(.trailing, 14)
                    }
                }
                .background(newTaskText.isEmpty ? Color(hex: "#F0EFF7") : Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#E2DDEF"), lineWidth: 1.5)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Tasks ScrollView
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(service.tasks.enumerated()), id: \.offset) { index, _ in
                            taskRow(index: index)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }

                // Submit Button — يرجع لـ ChallengeDetailView
                Button(action: { dismiss() }) {
                    Text("SUBMIT PROGRESS")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#341D71"))
                        .cornerRadius(26)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onTapGesture { swipedIndex = nil }
        .onAppear {
            service.listenToTasks(challengeId: challengeId, userId: userId)
        }
        .onDisappear {
            service.stopListening()
        }
    }

    // MARK: - Task Row
    @ViewBuilder
    private func taskRow(index: Int) -> some View {
        let isOpen = swipedIndex == index
        let task = service.tasks[index]

        ZStack(alignment: .trailing) {

            Button {
                withAnimation(.spring()) {
                    service.deleteTask(challengeId: challengeId, userId: userId, taskId: task.id)
                    swipedIndex = nil
                }
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Delete")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.gray.opacity(0.7))
                .clipShape(Capsule())
            }
            .opacity(isOpen ? 1 : 0)
            .padding(.trailing, 4)

            HStack(spacing: 14) {
                Button(action: {
                    withAnimation(.spring()) {
                        service.toggleTask(challengeId: challengeId, userId: userId, task: task)
                        swipedIndex = nil
                    }
                }) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(task.isCompleted
                            ? Color(hex: "#341D71")
                            : Color(hex: "#E8E6EF")
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(task.isCompleted ? 1 : 0)
                        )
                }

                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .strikethrough(task.isCompleted, color: .gray)

                Spacer()

                if task.isCompleted {
                    Text("Done ✓")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#341D71"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.6))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            .offset(x: isOpen ? -76 : 0)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        withAnimation(.spring()) {
                            if value.translation.width < -50 {
                                swipedIndex = index
                            } else {
                                swipedIndex = nil
                            }
                        }
                    }
            )
        }
        .clipped()
        .animation(.spring(), value: isOpen)
    }

    private func addTask() {
        let trimmed = newTaskText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        service.addTask(challengeId: challengeId, userId: userId, title: trimmed)
        newTaskText = ""
    }
}

#Preview {
    MyTasksView(challengeId: "test123", userId: "user1")
}
