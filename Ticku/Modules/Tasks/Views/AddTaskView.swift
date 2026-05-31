//
//  AddTaskView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct AddTasksView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var taskText: String = ""
    @State private var tasks: [String]

    @State private var editingIndex: Int? = nil
    @State private var editingText: String = ""
    @State private var showEditPopup: Bool = false

    var onSave: (([String]) -> Void)? = nil

    init(tasks: [String] = [], onSave: (([String]) -> Void)? = nil) {
        _tasks = State(initialValue: tasks)
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Nav Bar
                ZStack {
                    Text("Create Challenge")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A2E"))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A1A2E"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 70)

                // MARK: - Label
                Text("Add tasks")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#341D71").opacity(0.65))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 7)

                // MARK: - Input Field
                HStack(spacing: 0) {
                    TextField("add your tasks", text: $taskText)
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
                .background(taskText.isEmpty ? Color(hex: "#F0EFF7") : Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#E2DDEF"), lineWidth: 1.5)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // MARK: - Tasks List — List عشان swipeActions تشتغل
                List {
                    ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#E8E6EF"))
                                .frame(width: 36, height: 36)

                            Text(task)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)

                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                .padding(.vertical, 4)
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                tasks.remove(at: index)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.gray)

                            Button {
                                editingIndex = index
                                editingText = task
                                showEditPopup = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(Color(hex: "#341D71"))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                Spacer()

                // MARK: - Save Button
                HStack {
                    Spacer()
                    Button(action: {
                        onSave?(tasks)
                        dismiss()
                    }) {
                        Text("save")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 220, height: 44)
                            .background(Color(hex: "#341D71"))
                            .cornerRadius(22)
                    }
                    Spacer()
                }
                .padding(.bottom, 70)
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(hex: "#F5F4FB"))
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .navigationBar)

            // MARK: - Edit Popup
            if showEditPopup {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { showEditPopup = false }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Edit task")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 14)

                    TextField("", text: $editingText)
                        .font(.system(size: 15))
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(Color(hex: "#F0EFF7"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E2DDEF"), lineWidth: 1.5)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        Button { showEditPopup = false } label: {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray5))
                                .cornerRadius(25)
                        }
                        Button {
                            if let i = editingIndex, !editingText.isEmpty {
                                tasks[i] = editingText
                            }
                            showEditPopup = false
                        } label: {
                            Text("Save")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "#341D71"))
                                .cornerRadius(25)
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
        }
    }

    private func addTask() {
        let trimmed = taskText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        tasks.append(trimmed)
        taskText = ""
    }
}

#Preview {
    NavigationStack {
        AddTasksView()
    }
}
