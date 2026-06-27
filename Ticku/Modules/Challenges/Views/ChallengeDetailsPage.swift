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
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    @State private var challengeName: String
    @State private var challengeRule: String
    @State private var showRolePopup = false
    @State private var showNamePopup = false
    @State private var newRole: String = ""
    @State private var newName: String = ""
    @State private var pendingRule: String? = nil
    @State private var requestedBy: String? = nil
    @State private var acceptedBy: [String] = []
    @State private var memberCount: Int = 0
    @State private var memberNames: [String: String] = [:]
    @State private var listener: ListenerRegistration? = nil

    private let db = Firestore.firestore()

    // ✅ لو عضو واحد بس بالتحدي، التغيير يطبق فوراً بدون انتظار موافقة أحد
    private var isSolo: Bool { challenge.memberCount <= 1 }

    init(challenge: Challenge) {
        self.challenge = challenge
        _challengeName = State(initialValue: challenge.title)
        _challengeRule = State(initialValue: challenge.description.isEmpty ? "No rule set" : challenge.description)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Pending Change Banner (top) ───────
                    if let pending = pendingRule, let requester = requestedBy {
                        let requesterName = memberNames[requester] ?? requester
                        let myId = authVM.currentUserId ?? ""
                        let isRequester = requester == myId
                        let alreadyAccepted = acceptedBy.contains(myId)

                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(isDark ? .white : .black)
                            }

                            Group {
                                Text(isRequester ? "You" : requesterName).fontWeight(.bold)
                                + Text(" requested a change")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(isDark ? .white : .black)

                            Spacer()

                            if !alreadyAccepted && !isRequester {
                                Button(action: { acceptRuleChange() }) {
                                    Text("Accepted")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(isDark ? Color(hex: "#E0D6FA") : .white)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 8)
                                        .background(isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71"))
                                        .cornerRadius(20)
                                }
                            } else {
                                Text("Accepted")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(isDark ? Color(hex: "#E0D6FA") : .white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71"))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(isDark ? Color.white.opacity(0.06) : Color(hex: "#F0EDF8"))
                        .cornerRadius(20)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    // ── Nav Bar ───────────────────────────
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(isDark ? .white : .black)
                        }

                        Spacer()

                        Text("Details")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isDark ? .white : .black)

                        Spacer()

                        Color.clear.frame(width: 28)
                    }
                    .padding(.horizontal, 36)
                    .padding(.top, 5)
                    .padding(.bottom, 50)

                    // ── Challenge Name ────────────────────
                    detailSection(label: "Challenge name") {
                        HStack(spacing: 18) {
                            Text(challengeName)
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(isDark ? Color(hex: "#C9C9C9") : Color(hex: "#55555A"))

                            Button {
                                newName = challengeName
                                showNamePopup = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(isDark ? .white : .black)
                            }
                        }
                    }

                    // ── Duration ──────────────────────────
                    detailSection(label: "Duration") {
                        HStack(spacing: 10) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(isDark ? Color(hex: "#C9C9C9").opacity(0.68) : Color(hex: "#6B6B72"))

                            Text(durationText)
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(isDark ? Color(hex: "#C9C9C9").opacity(0.68) : Color(hex: "#6B6B72"))
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 47)
                        .background(isDark ? Color(hex: "#3A3944") : Color(hex: "#F0EDF8"))
                        .cornerRadius(24)
                    }

                    // ── Challenge Rule ────────────────────
                    detailSection(label: "Challenge role") {
                        HStack(spacing: 2) {
                            if pendingRule != nil {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                            }

                            Text(challengeRule)
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(challengeRuleColor)
                                .lineLimit(1)

                            Button {
                                newRole = challengeRule
                                showRolePopup = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(isDark ? .white : .black)
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
                            .foregroundColor(isDark ? .white : .black)

                            if !alreadyAccepted && !isRequester {
                                Button(action: { acceptRuleChange() }) {
                                    Text("Accepted")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(isDark ? Color(hex: "#E0D6FA") : .white)
                                        .padding(.horizontal, 20).padding(.vertical, 8)
                                        .background(isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71"))
                                        .cornerRadius(20)
                                }
                            } else {
                                Text("Accepted")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(isDark ? Color(hex: "#E0D6FA") : .white)
                                    .padding(.horizontal, 20).padding(.vertical, 8)
                                    .background((isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71")).opacity(0.5))
                                    .cornerRadius(20)
                            }

                            Text("\(acceptedBy.count)/\(memberCount) Accepted")
                                .font(.system(size: 12))
                                .foregroundColor(isDark ? .white.opacity(0.5) : .gray)
                        }
                        .padding(.horizontal, 36)
                        .padding(.vertical, 16)
                        .background(isDark ? Color.white.opacity(0.05) : Color.clear)
                        .cornerRadius(20)
                        .padding(.top, 8)
                    }

                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(darkLightBackground.ignoresSafeArea())
            .navigationBarHidden(true)

            // ── Rule Popup ────────────────────────────────
            if showRolePopup {
                popupOverlay(
                    title: "Challenge role",
                    text: $newRole,
                    buttonLabel: "Request",
                    onCancel: { showRolePopup = false },
                    onSave: {
                        if !newRole.isEmpty && newRole != challengeRule {
                            requestRuleChange(newRole)
                        }
                        showRolePopup = false
                    }
                )
            }

            // ── Name Popup ────────────────────────────────
            if showNamePopup {
                popupOverlay(
                    title: "Challenge name",
                    text: $newName,
                    buttonLabel: "Save",
                    onCancel: { showNamePopup = false },
                    onSave: {
                        if !newName.isEmpty && newName != challengeName {
                            updateChallengeName(newName)
                        }
                        showNamePopup = false
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

    @ViewBuilder
    private var darkLightBackground: some View {
        if isDark {
            Color.black
        } else {
            Color.white
        }
    }

    private var challengeRuleColor: Color {
        isDark ? Color(hex: "#7183B4") : Color(hex: "#5EA8FF")
    }

    // MARK: - Duration — من الحين لـ endDate
    private var durationText: String {
        let remaining = challenge.endDate.timeIntervalSinceNow
        if remaining <= 0 { return "Finished" }

        let total = Int(remaining)
        let days = total / 86400
        let hours = (total % 86400) / 3600
        let mins = (total % 3600) / 60
        let secs = total % 60

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
                    pendingRule = pending["newRule"] as? String
                    requestedBy = pending["requestedBy"] as? String
                    acceptedBy = pending["acceptedBy"] as? [String] ?? []
                } else {
                    pendingRule = nil
                    requestedBy = nil
                    acceptedBy = []
                }

                if let rule = data["description"] as? String {
                    challengeRule = rule
                }

                if let title = data["title"] as? String {
                    challengeName = title
                }
            }
    }

    // MARK: - Load Member Names
    func loadMemberNames() async {
        guard let cid = challenge.id else { return }

        let snap = try? await db.collection("challenges")
            .document(cid)
            .collection("members")
            .getDocuments()

        snap?.documents.forEach { doc in
            if let name = doc.data()["displayName"] as? String {
                memberNames[doc.documentID] = name
            }
        }
    }

    // MARK: - Request Rule Change
    func requestRuleChange(_ newRule: String) {
        guard let cid = challenge.id, let uid = authVM.currentUserId else { return }

        // ✅ لو لحاله (Solo) — يطبق التغيير مباشرة بدون pendingRuleChange/موافقة
        if isSolo {
            challengeRule = newRule
            db.collection("challenges").document(cid).updateData([
                "description": newRule
            ])
            return
        }

        let pendingData: [String: Any] = [
            "newRule": newRule,
            "requestedBy": uid,
            "acceptedBy": [uid]
        ]

        db.collection("challenges").document(cid).updateData([
            "pendingRuleChange": pendingData
        ])

        let requesterName = memberNames[uid] ?? "Someone"

        NotificationManager.shared.sendRuleChangeRequest(
            requesterName: requesterName,
            newRule: newRule,
            challengeName: challenge.title
        )
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

    // MARK: - Update Challenge Name
    func updateChallengeName(_ name: String) {
        guard let cid = challenge.id else { return }

        challengeName = name
        db.collection("challenges").document(cid).updateData([
            "title": name
        ])
    }

    // MARK: - Section helper
    private func detailSection<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(isDark ? Color(hex: "#7F71A6") : Color(hex: "#8E78B4"))

            content()
        }
        .padding(.horizontal, 36)
        .padding(.bottom, 30)
    }

    // MARK: - Popup
    private func popupOverlay(
        title: String,
        text: Binding<String>,
        buttonLabel: String,
        onCancel: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) -> some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(isDark ? .white : .black)
                    .padding(.top, 39)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 29)

                HStack {
                    TextField(title, text: text)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    Image(systemName: "pencil")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 22)
                .frame(height: 49)
                .background(isDark ? Color(hex: "#BEBEBE") : Color.white)
                .cornerRadius(27)
                .padding(.horizontal, 28)

                HStack {
                    Spacer()

                    Text("\(text.wrappedValue.count)/40")
                        .font(.system(size: 16))
                        .foregroundColor(isDark ? .white.opacity(0.7) : Color(hex: "#55555A"))
                }
                .padding(.horizontal, 32)
                .padding(.top, 6)
                .padding(.bottom, 24)

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isDark ? .white : .black)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(isDark ? Color.white.opacity(0.12) : Color(hex: "#EDEDED"))
                            .cornerRadius(30)
                    }

                    Button(action: onSave) {
                        Text(buttonLabel)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(isDark ? Color(hex: "#341D71").opacity(0.34) : Color(hex: "#341D71"))
                            .cornerRadius(30)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: 363)
            .background(isDark ? Color(hex: "#1C1C1E") : Color(hex: "#D9D9D9"))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isDark ? Color.white.opacity(0.12) : Color(hex: "#CBCBCB"), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 24)
        }
    }
}

#Preview("Light") {
    NavigationStack {
        ChallengeDetailsPage(
            challenge: Challenge(
                id: "preview",
                title: "let's do it",
                description: "Buy dinner for the group",
                createdBy: "uid",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                status: "active",
                memberCount: 2,
                createdAt: Date(),
                memberIds: ["uid"]
            )
        )
        .environmentObject(AuthViewModel())
    }
}

#Preview("Dark") {
    NavigationStack {
        ChallengeDetailsPage(
            challenge: Challenge(
                id: "preview",
                title: "let's do it",
                description: "Buy dinner for the group",
                createdBy: "uid",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                status: "active",
                memberCount: 2,
                createdAt: Date(),
                memberIds: ["uid"]
            )
        )
        .environmentObject(AuthViewModel())
    }
    .preferredColorScheme(.dark)
}
