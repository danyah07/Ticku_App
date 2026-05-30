//
//  AddTasksView2.swift
//  firebasetrial
//
//  Created by Jumana on 12/12/1447 AH.
//

import SwiftUI

struct TaskItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
}

struct MyTasksView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var tasks: [TaskItem]
    @State private var newTaskText: String = ""
    @State private var swipedIndex: Int? = nil

    var onProgressUpdate: ((Int, Int) -> Void)? = nil

    init(tasks: [String] = [], onProgressUpdate: ((Int, Int) -> Void)? = nil) {
        _tasks = State(initialValue: tasks.map { TaskItem(title: $0) })
        self.onProgressUpdate = onProgressUpdate
    }

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter { $0.isCompleted }.count) / Double(tasks.count)
    }

    var completedCount: Int { tasks.filter { $0.isCompleted }.count }

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
                        Text("\(completedCount)/\(tasks.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#341D71").opacity(0.5))
                    }
                }
                .padding(.bottom, 30)

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
                        ForEach(Array(tasks.enumerated()), id: \.offset) { index, _ in
                            taskRow(index: index)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }

                // Submit Button
                Button(action: {}) {
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
        .onChange(of: tasks) { _ in
            onProgressUpdate?(
                tasks.filter { $0.isCompleted }.count,
                tasks.count
            )
        }
    }

    // MARK: - Task Row
    @ViewBuilder
    private func taskRow(index: Int) -> some View {
        let isOpen = swipedIndex == index

        ZStack(alignment: .trailing) {

            // زر الحذف بس
            Button {
                withAnimation(.spring()) {
                    tasks.remove(at: index)
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

            // الكارد
            HStack(spacing: 14) {
                Button(action: {
                    withAnimation(.spring()) {
                        tasks[index].isCompleted.toggle()
                        swipedIndex = nil
                    }
                }) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tasks[index].isCompleted
                            ? Color(hex: "#341D71")
                            : Color(hex: "#E8E6EF")
                        )
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(tasks[index].isCompleted ? 1 : 0)
                        )
                }

                Text(tasks[index].title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .strikethrough(tasks[index].isCompleted, color: .gray)

                Spacer()

                if tasks[index].isCompleted {
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
        tasks.append(TaskItem(title: trimmed))
        newTaskText = ""
    }
}
#Preview {
    MyTasksView()
}
