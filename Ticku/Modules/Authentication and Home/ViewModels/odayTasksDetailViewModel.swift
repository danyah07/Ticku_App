//
//  odayTasksDetailViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 05/06/2026.
//

import Foundation
import FirebaseFirestore
import Combine

// MARK: - Task Group
struct ChallengeTaskGroup: Identifiable {
    var id: String { challenge.id ?? UUID().uuidString }
    let challenge: Challenge
    var tasks: [TickuTask]
}

@MainActor
final class TodayTasksDetailViewModel: ObservableObject {

    @Published var taskGroups: [ChallengeTaskGroup] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    var totalTasks: Int { taskGroups.flatMap(\.tasks).count }
    var completedTasks: Int { taskGroups.flatMap(\.tasks).filter(\.isCompleted).count }
    var overallProgress: Double {
        totalTasks == 0 ? 0 : Double(completedTasks) / Double(totalTasks)
    }

    private let db = Firestore.firestore()

    // MARK: - Load
    func load(uid: String, activeChallenges: [Challenge]) async {
        isLoading = true
        defer { isLoading = false }

        do {
            var groups: [ChallengeTaskGroup] = []

            for challenge in activeChallenges {
                guard let cid = challenge.id else { continue }

                // ✅ الصح: challenges/{cid}/members/{uid}/tasks
                let snap = try await db
                    .collection("challenges").document(cid)
                    .collection("members").document(uid)
                    .collection("tasks")
                    .getDocuments()

                let tasks = snap.documents.compactMap { doc -> TickuTask? in
                    let data = doc.data()
                    var task = TickuTask()
                    task.id = doc.documentID
                    task.title = data["title"] as? String ?? ""
                    task.isCompleted = data["isCompleted"] as? Bool ?? false
                    task.ownerId = uid
                    if let ts = data["createdAt"] as? Timestamp {
                        task.createdAt = ts.dateValue()
                    }
                    return task
                }

                groups.append(ChallengeTaskGroup(challenge: challenge, tasks: tasks))
            }

            taskGroups = groups
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Toggle Task
    func toggleTask(_ task: TickuTask, in challengeId: String) async {
        guard let taskId = task.id else { return }

        let newValue = !task.isCompleted
        updateLocally(taskId: taskId, challengeId: challengeId, isCompleted: newValue)

        guard let group = taskGroups.first(where: { $0.challenge.id == challengeId }) else { return }
        let uid = group.tasks.first?.ownerId ?? ""

        do {
            var updates: [String: Any] = ["isCompleted": newValue]
            updates["completedAt"] = newValue ? Timestamp(date: Date()) : NSNull()

            try await db
                .collection("challenges").document(challengeId)
                .collection("members").document(uid)
                .collection("tasks").document(taskId)
                .updateData(updates)

            await updateMemberProgress(challengeId: challengeId, uid: uid)

        } catch {
            updateLocally(taskId: taskId, challengeId: challengeId, isCompleted: !newValue)
            errorMessage = error.localizedDescription
        }
    }

    private func updateLocally(taskId: String, challengeId: String, isCompleted: Bool) {
        for gi in taskGroups.indices {
            if taskGroups[gi].challenge.id == challengeId {
                for ti in taskGroups[gi].tasks.indices {
                    if taskGroups[gi].tasks[ti].id == taskId {
                        taskGroups[gi].tasks[ti].isCompleted = isCompleted
                        return
                    }
                }
            }
        }
    }

    private func updateMemberProgress(challengeId: String, uid: String) async {
        guard let group = taskGroups.first(where: { $0.challenge.id == challengeId }) else { return }

        let total     = group.tasks.count
        let completed = group.tasks.filter(\.isCompleted).count
        let percent   = total > 0 ? Double(completed) / Double(total) * 100 : 0.0

        do {
            try await db
                .collection("challenges").document(challengeId)
                .collection("members").document(uid)
                .updateData([
                    "tasksCompleted":  completed,
                    "tasksTotal":      total,
                    "progressPercent": percent,
                    "lastUpdated":     FieldValue.serverTimestamp()
                ])
        } catch {
            print("⚠️ Progress update failed: \(error.localizedDescription)")
        }
    }
}
