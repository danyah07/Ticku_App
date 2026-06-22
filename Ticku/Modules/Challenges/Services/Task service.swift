//
//  Task service.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 05/06/2026.
//

import Foundation
import FirebaseFirestore
import Combine

// MARK: - Model
struct ChallengeTask: Identifiable, Equatable {
    let id: String
    var title: String
    var isCompleted: Bool
    let createdAt: Date

    init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    init?(id: String, data: [String: Any]) {
        guard let title = data["title"] as? String else { return nil }
        self.id = id
        self.title = title
        self.isCompleted = data["isCompleted"] as? Bool ?? false
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
    }

    var firestoreData: [String: Any] {
        [
            "title": title,
            "isCompleted": isCompleted,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
}

// MARK: - Service
final class ChallengeTaskService: ObservableObject {

    private let db = Firestore.firestore()

    @Published var tasks: [ChallengeTask] = []
    private var listener: ListenerRegistration?

    func listenToTasks(challengeId: String, userId: String) {
        listener?.remove()

        listener = db
            .collection("challenges")
            .document(challengeId)
            .collection("members")
            .document(userId)
            .collection("tasks")
            .order(by: "createdAt")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error {
                    Task { @MainActor in
                        ErrorHandler.shared.report(error, context: "loading tasks")
                    }
                    return
                }
                self?.tasks = snapshot?.documents.compactMap {
                    ChallengeTask(id: $0.documentID, data: $0.data())
                } ?? []
            }
    }

    func addTask(challengeId: String, userId: String, title: String) {
        let task = ChallengeTask(title: title)
        db.collection("challenges")
            .document(challengeId)
            .collection("members")
            .document(userId)
            .collection("tasks")
            .document(task.id)
            .setData(task.firestoreData) { error in
                if let error {
                    Task { @MainActor in
                        ErrorHandler.shared.report(error, context: "adding task")
                    }
                }
            }
    }

    func toggleTask(challengeId: String, userId: String, task: ChallengeTask) {
        db.collection("challenges")
            .document(challengeId)
            .collection("members")
            .document(userId)
            .collection("tasks")
            .document(task.id)
            .updateData(["isCompleted": !task.isCompleted]) { [weak self] error in
                if let error {
                    Task { @MainActor in
                        ErrorHandler.shared.report(error, context: "updating task")
                    }
                    return
                }
                self?.updateProgress(challengeId: challengeId, userId: userId)
            }
    }

    func deleteTask(challengeId: String, userId: String, taskId: String) {
        db.collection("challenges")
            .document(challengeId)
            .collection("members")
            .document(userId)
            .collection("tasks")
            .document(taskId)
            .delete { [weak self] error in
                if let error {
                    Task { @MainActor in
                        ErrorHandler.shared.report(error, context: "deleting task")
                    }
                    return
                }
                self?.updateProgress(challengeId: challengeId, userId: userId)
            }
    }

    private func updateProgress(challengeId: String, userId: String) {
        let completed: Int
        let percent: Int

        if tasks.isEmpty {
            completed = 0
            percent = 0
        } else {
            completed = tasks.filter { $0.isCompleted }.count
            percent = Int((Double(completed) / Double(tasks.count)) * 100)
        }

        db.collection("challenges")
            .document(challengeId)
            .collection("members")
            .document(userId)
            .updateData([
                "progressPercent": percent,
                "tasksCompleted": completed,
                "tasksTotal": tasks.count
            ]) { error in
                if let error {
                    Task { @MainActor in
                        ErrorHandler.shared.report(error, context: "updating progress")
                    }
                }
            }
    }

    func saveTasks(challengeId: String, userId: String, titles: [String]) {
        let ref = db.collection("challenges")
            .document(challengeId)
            .collection("members")
            .document(userId)
            .collection("tasks")

        for title in titles {
            let task = ChallengeTask(title: title)
            ref.document(task.id).setData(task.firestoreData) { error in
                if let error {
                    Task { @MainActor in
                        ErrorHandler.shared.report(error, context: "saving tasks")
                    }
                }
            }
        }
    }

    func stopListening() {
        listener?.remove()
    }
}
