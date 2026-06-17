//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 11/12/1447 AH.
//

import SwiftUI
import FirebaseFirestore

struct ChallengeDetailsPage: View {

    let challenge: Challenge

    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var challengeName: String
    @State private var challengeRule: String
    @State private var showRolePopup = false
    @State private var newRole: String = ""
    @State private var pendingRule: String? = nil
    @State private var requestedBy: String? = nil
    @State private var acceptedBy: [String] = []
    @State private var memberCount: Int = 0
    @State private var memberNames: [String: String] = [:]
    @State private var listener: ListenerRegistration? = nil

    private let db = Firestore.firestore()

    init(challenge: Challenge) {
        self.challenge  = challenge
        _challengeName  = State(initialValue: challenge.title)
        _challengeRule  = State(initialValue: challenge.description.isEmpty ? "No rule set" : challenge.description)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    // ── Nav Bar ───────────────────────────
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text("Details")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Color.clear.frame(width: 18)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                    // ── Challenge Name ────────────────────
                    detailSection(label: "Challenge name") {
                        Text(challengeName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                    }

                    // ── Duration ──────────────────────────
                    detailSection(label: "Duration") {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(Color(hex: "#341D71").opacity(0.6))
                            Text(durationText)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color(hex: "#F0EDF8"))
                        .cornerRadius(16)
                    }

                    // ── Challenge Rule ────────────────────
                    detailSection(label: "Challenge role") {
                        HStack(spacing: 8) {
                            if pendingRule != nil {
                                Circle().fill(Color.red).frame(width: 8, height: 8)
                            }
                            Text(challengeRule)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(pendingRule != nil ? Color(hex: "#341D71") : .black)
                                .lineLimit(2)
                            Button {
                                newRole = challengeRule
                                showRolePopup = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(Color(hex: "#341D71"))
                            }
                        }
                    }

                    // ── Pending Rule Change ───────────────
                    if let pending = pendingRule, let requester = requestedBy {
                        let requesterName = memberNames[requester] ?? requester
                        let myId = authVM.currentUserId ?? ""
                        let isRequester = requester == myId
                        let alreadyAccepted = acceptedBy.contains(myId)

                        VStack(alignment: .leading, spacing: 10) {
                            Group {
                                Text(isRequester ? "You" : requesterName)
                                    .fontWeight(.bold)
                                + Text(" requested\nto change the challenge role to : ")
                                + Text(pending)
                                    .fontWeight(.bold)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.black)

                            if !alreadyAccepted && !isRequester {
                                Button(action: { acceptRuleChange() }) {
                                    Text("Accepted")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20).padding(.vertical, 8)
                                        .background(Color(hex: "#341D71"))
                                        .cornerRadius(20)
                                }
                            } else {
                                Text("Accepted")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20).padding(.vertical, 8)
                                    .background(Color(hex: "#341D71").opacity(0.5))
                                    .cornerRadius(20)
                            }

                            Text("\(acceptedBy.count)/\(memberCount) Accepted")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }

                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarHidden(true)

            // ── Rule Popup ────────────────────────────────
            if showRolePopup {
                popupOverlay(
                    title: "Challenge role",
                    text: $newRole,
                    onCancel: { showRolePopup = false },
                    onSave: {
                        if !newRole.isEmpty && newRole != challengeRule {
                            requestRuleChange(newRole)
                        }
                        showRolePopup = false
                    }
                )
            }
        }
        .onAppear {
            memberCount = challenge.memberIds.count
            startListener()
            Task { await loadMemberNames() }
        }
        .onDisappear {
            listener?.remove()
        }
    }

    // MARK: - Duration — من الحين لـ endDate
    private var durationText: String {
        let remaining = challenge.endDate.timeIntervalSinceNow
        if remaining <= 0 { return "Finished" }

        let total = Int(remaining)
        let days  = total / 86400
        let hours = (total % 86400) / 3600
        let mins  = (total % 3600) / 60
        let secs  = total % 60

        if days > 1 { return "\(days) Days left" }
        if days == 1 { return "1 Day left" }
        return String(format: "%02d:%02d:%02d", hours, mins, secs)
    }

    // MARK: - Real-time listener
    func startListener() {
        guard let cid = challenge.id else { return }
        listener = db.collection("challenges").document(cid)
            .addSnapshotListener { snap, _ in
                guard let data = snap?.data() else { return }
                if let pending = data["pendingRuleChange"] as? [String: Any] {
                    pendingRule  = pending["newRule"] as? String
                    requestedBy  = pending["requestedBy"] as? String
                    acceptedBy   = pending["acceptedBy"] as? [String] ?? []
                } else {
                    pendingRule  = nil
                    requestedBy  = nil
                    acceptedBy   = []
                }
                // تحديث الحكم لو تغير
                if let rule = data["description"] as? String {
                    challengeRule = rule
                }
            }
    }

    // MARK: - Load Member Names
    func loadMemberNames() async {
        guard let cid = challenge.id else { return }
        let snap = try? await db.collection("challenges").document(cid).collection("members").getDocuments()
        snap?.documents.forEach { doc in
            if let name = doc.data()["displayName"] as? String {
                memberNames[doc.documentID] = name
            }
        }
    }

    // MARK: - Request Rule Change
    func requestRuleChange(_ newRule: String) {
        guard let cid = challenge.id, let uid = authVM.currentUserId else { return }
        let pendingData: [String: Any] = [
            "newRule": newRule,
            "requestedBy": uid,
            "acceptedBy": [uid]
        ]
        db.collection("challenges").document(cid).updateData(["pendingRuleChange": pendingData])
    }

    // MARK: - Accept Rule Change
    func acceptRuleChange() {
        guard let cid = challenge.id, let uid = authVM.currentUserId else { return }

        db.collection("challenges").document(cid).updateData([
            "pendingRuleChange.acceptedBy": FieldValue.arrayUnion([uid])
        ])

        let newAccepted = acceptedBy + [uid]
        if newAccepted.count >= memberCount, let pending = pendingRule {
            db.collection("challenges").document(cid).updateData([
                "description": pending,
                "pendingRuleChange": FieldValue.delete()
            ])
        }
    }

    // MARK: - Section helper
    private func detailSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: "#341D71"))
            content()
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    // MARK: - Popup
    private func popupOverlay(title: String, text: Binding<String>, onCancel: @escaping () -> Void, onSave: @escaping () -> Void) -> some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea().onTapGesture { onCancel() }
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 20).padding(.horizontal, 24).padding(.bottom, 14)
                TextField(title, text: text)
                    .font(.system(size: 15)).padding()
                    .background(Color(.systemGray6)).cornerRadius(12)
                    .padding(.horizontal, 24)
                HStack {
                    Spacer()
                    Text("\(text.wrappedValue.count)/40")
                        .font(.system(size: 12)).foregroundColor(.gray)
                }
                .padding(.horizontal, 24).padding(.top, 6).padding(.bottom, 24)
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Color(.systemGray5)).cornerRadius(26)
                    }
                    Button(action: onSave) {
                        Text("Request")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Color(hex: "#341D71")).cornerRadius(26)
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 20)
            }
            .background(.ultraThinMaterial).cornerRadius(24)
            .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NavigationStack {
        ChallengeDetailsPage(
            challenge: Challenge(
                id: "preview", title: "let's do it",
                description: "Buy dinner for the group",
                createdBy: "uid", startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                status: "active", memberCount: 2, createdAt: Date(), memberIds: ["uid"]
            )
        )
        .environmentObject(AuthViewModel())
    }
}
