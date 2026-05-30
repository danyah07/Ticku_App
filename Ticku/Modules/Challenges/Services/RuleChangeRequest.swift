//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 11/12/1447 AH.
//

import Foundation
import FirebaseFirestore
import Combine

// MARK: - Model
struct RuleChangeRequest: Identifiable {
    let id: String
    let requestedBy: String
    let requestedByName: String
    let newRule: String
    var approvals: [String]
    var rejections: [String]
    var status: String
    let createdAt: Date

    var isPending: Bool { status == "pending" }
}

// MARK: - Service
final class RuleChangeService: ObservableObject {

    private let db = Firestore.firestore()

    func requestRuleChange(
        challengeId: String,
        newRule: String,
        memberCount: Int,
        requestedBy: String,
        requestedByName: String,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "requestedBy": requestedBy,
            "requestedByName": requestedByName,
            "newRule": newRule,
            "approvals": [],
            "rejections": [],
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),
            "memberCount": memberCount
        ]

        db.collection("challenges")
            .document(challengeId)
            .collection("pendingRuleChange")
            .addDocument(data: data) { error in
                completion(error)
            }
    }

    func respond(
        challengeId: String,
        requestId: String,
        approve: Bool,
        memberCount: Int,
        currentUserId: String,
        completion: @escaping (Error?) -> Void
    ) {
        let ref = db
            .collection("challenges")
            .document(challengeId)
            .collection("pendingRuleChange")
            .document(requestId)

        let field = approve ? "approvals" : "rejections"

        ref.updateData([field: FieldValue.arrayUnion([currentUserId])]) { error in
            if let error { completion(error); return }

            ref.getDocument { snapshot, _ in
                guard let data = snapshot?.data() else { return }
                let approvals = data["approvals"] as? [String] ?? []
                let newRule = data["newRule"] as? String ?? ""

                if approve && approvals.count >= memberCount {
                    self.db.collection("challenges")
                        .document(challengeId)
                        .updateData(["challengeRule": newRule]) { _ in }
                    ref.updateData(["status": "approved"]) { _ in }
                }
                completion(nil)
            }
        }
    }

    func listenForPendingRequests(
        challengeId: String,
        onChange: @escaping ([RuleChangeRequest]) -> Void
    ) -> ListenerRegistration {

        return db
            .collection("challenges")
            .document(challengeId)
            .collection("pendingRuleChange")
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, _ in
                let requests = snapshot?.documents.compactMap { doc -> RuleChangeRequest? in
                    let d = doc.data()
                    return RuleChangeRequest(
                        id: doc.documentID,
                        requestedBy:     d["requestedBy"]     as? String ?? "",
                        requestedByName: d["requestedByName"] as? String ?? "",
                        newRule:         d["newRule"]         as? String ?? "",
                        approvals:       d["approvals"]       as? [String] ?? [],
                        rejections:      d["rejections"]      as? [String] ?? [],
                        status:          d["status"]          as? String ?? "pending",
                        createdAt:       (d["createdAt"]      as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []
                onChange(requests)
            }
    }
}
