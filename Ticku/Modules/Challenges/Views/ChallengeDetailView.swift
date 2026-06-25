//
//  ChallengeDetailView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//
//
//  ChallengeDetailView.swift
//  firebasetrial

import SwiftUI
import FirebaseFirestore
import TipKit

struct ChallengeDetailView: View {

    @StateObject private var vm: ChallengeDetailViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var showGiveUpAlert = false
    @State private var showMenu = false
    @State private var showDetails = false
    @State private var showComplete = false
    @State private var hasPendingChange = false
    @State private var showNamePopup = false
    @State private var editedName: String = ""

    var onBack: () -> Void = {}
    var onMyTasks: (Challenge) -> Void = { _ in }

    private let db = Firestore.firestore()
    @State private var pendingListener: ListenerRegistration? = nil
    private let streakTip = StreakTip()

    private var isDark: Bool { colorScheme == .dark }

    init(
        challenge: Challenge,
        onBack: @escaping () -> Void = {},
        onMyTasks: @escaping (Challenge) -> Void = { _ in }
    ) {
        _vm = StateObject(wrappedValue: ChallengeDetailViewModel(challenge: challenge))
        self.onBack    = onBack
        self.onMyTasks = onMyTasks
    }

    var body: some View {
        ZStack {
            backgroundView

            if vm.challenge.isSolo {
                soloLayout
            } else {
                VStack(spacing: 0) {

                    // ── Nav Bar ───────────────────────────────
                    navBarSection

                    Spacer().frame(height: 36)

                    // ── Title ─────────────────────────────────
                    titleSection

                    Spacer().frame(height: 8)

                    timerSection

                    Spacer().frame(height: 24)

                    membersGridSection
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showDetails) {
            ChallengeDetailsPage(challenge: vm.challenge)
                .environmentObject(authVM)
        }
        .navigationDestination(isPresented: $showComplete) {
            ChallengeCompleteView(
                players: playersList,
                challengeRule: vm.challenge.description,
                onDone: { onBack() }
            )
        }
        .onChange(of: vm.timerDisplay) {
            if vm.timerDisplay == "00:00:00" && vm.challengeStartDate != nil {
                Task { await vm.completeChallenge() }
                showComplete = true
            }
        }
        .onChange(of: vm.members) {
            if vm.challengeStartDate != nil &&
               vm.members.contains(where: { $0.progressPercent >= 100 }) {
                Task { await vm.completeChallenge() }
                showComplete = true
            }
        }
        .alert("Give up?", isPresented: $showGiveUpAlert) {
            Button("Give up", role: .destructive) { handleGiveUp() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to leave this challenge?")
        }
        .onAppear {
            vm.startListening(currentUserId: authVM.currentUserId ?? "")
            startPendingListener()
        }
        .onChange(of: vm.timerDisplay) {
            if vm.timerDisplay != "START" {
                // ✅ بعد START، التب لازم يختفي ولا يطلع مرة ثانية لهذا المستخدم
                StreakTip.hasStartedChallengeBefore = true
                streakTip.invalidate(reason: .actionPerformed)
            }
        }
        .onDisappear {
            pendingListener?.remove()
        }
        .task {
            await vm.saveInviteCode()
        }
        .alert("Edit challenge name", isPresented: $showNamePopup) {
            TextField("Challenge name", text: $editedName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if !editedName.isEmpty && editedName != vm.challenge.title {
                    updateChallengeName(editedName)
                }
            }
        }
        .withErrorHandling()
    }

    // MARK: - Solo Layout
    @ViewBuilder
    private var soloLayout: some View {
        VStack(spacing: 0) {
            // Nav bar بدون زر مشاركة — فقط back و menu (لو بدأ)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isDark ? .white : .black)
                }
                Spacer()
                if vm.timerDisplay != "START" {
                    menuButton
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer().frame(height: 36)

            titleSection

            Spacer().frame(height: 8)

            timerSection

            Spacer().frame(height: 30)

            if let me = vm.members.first(where: { $0.userId == authVM.currentUserId }) {
                Button(action: { onMyTasks(vm.challenge) }) {
                    soloCard(member: me)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .popoverTip(streakTip, arrowEdge: .top)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func soloCard(member: ChallengeMember) -> some View {
        VStack(spacing: 10) {
            Circle()
                .fill(isDark ? Color.white.opacity(0.1) : Color(hex: "#E8E4F0"))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 28))
                        .foregroundColor(isDark ? .white.opacity(0.7) : Color(hex: "#341D71"))
                )

            Text("\(Int(member.progressPercent))%")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isDark ? .white.opacity(0.6) : Color(hex: "#9E9E9E"))

            Text("ME")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(isDark ? .white : .black)

            Text("View tasks »")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isDark ? Color(hex: "#B296EB") : Color(hex: "#5B6AD4"))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? Color.white.opacity(0.04) : Color.white.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(isDark ? Color(hex: "#B296EB").opacity(0.2) : Color(hex: "#E2DDEF"), lineWidth: 1))
        )
    }

    // MARK: - Background (Light / Dark)
    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            LinearGradient(
                colors: [
                    Color(hex: "#0A0814"),
                    Color(hex: "#0A0814"),
                    Color(hex: "#2A2150"),
                    Color(hex: "#5B4A8F")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [
                    Color(hex: "#FFFFFF"),
                    Color(hex: "#FFFFFF"),
                    Color(hex: "#EEE8FF"),
                    Color(hex: "#DDD4F8")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private func handleGiveUp() {
        let myName = vm.members.first(where: { $0.userId == authVM.currentUserId })?.displayName ?? "A player"
        NotificationManager.shared.sendPlayerLeft(
            playerName: myName,
            challengeName: vm.challenge.title
        )
        onBack()
    }

    private var playersList: [Player] {
        var result: [Player] = []
        for (index, member) in vm.members.enumerated() {
            let player = Player(
                name: member.displayName,
                rank: index + 1,
                isMe: member.userId == authVM.currentUserId,
                completedTasks: member.tasksCompleted,
                totalTasks: member.tasksTotal
            )
            result.append(player)
        }
        return result
    }

    @ViewBuilder
    private var navBarSection: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDark ? .white : .black)
            }
            Spacer()
            if vm.timerDisplay == "START" {
                shareButton
            } else {
                menuButton
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    @ViewBuilder
    private var shareButton: some View {
        Button(action: shareChallenge) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isDark ? .white : .black)
        }
    }

    @ViewBuilder
    private var menuButton: some View {
        Button(action: { showMenu = true }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDark ? .white : .black)
                    .rotationEffect(.degrees(90))
                    .padding(4)

                if hasPendingChange {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .confirmationDialog("", isPresented: $showMenu) {
            Button("Give up", role: .destructive) { showGiveUpAlert = true }
            Button("Details") { showDetails = true }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var timerSection: some View {
        Text("TIME REMAINING")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(isDark ? Color.white.opacity(0.5) : Color(hex: "#AAAAAA"))
            .tracking(1.5)

        Spacer().frame(height: 14)

        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(isDark ? Color.white.opacity(0.12) : Color(hex: "#E8E2F8"))
                .frame(width: 260, height: 58)
            Text(vm.timerDisplay)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(isDark ? Color(hex: "#B7A9E8") : Color(hex: "#5B3DBF"))
                .tracking(1)
        }
        .onTapGesture {
            if vm.timerDisplay == "START" {
                Task { await vm.startChallenge() }
            }
        }

        Spacer().frame(height: 14)

        Text("\(vm.members.count) PLAYERS")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(isDark ? Color(hex: "#A8C4E8") : Color(hex: "#5B6AD4"))
            .padding(.horizontal, 16).padding(.vertical, 5)
            .background(isDark ? Color(hex: "#1E3A5F").opacity(0.7) : Color(hex: "#E4E8FF"))
            .cornerRadius(20)
    }

    @ViewBuilder
    private var membersGridSection: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 14
            ) {
                ForEach(Array(vm.members.enumerated()), id: \.element.id) { index, member in
                    memberGridItem(member: member, index: index)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private var titleSection: some View {
        HStack(spacing: 8) {
            Text(vm.challenge.title)
                .font(.system(size: 26, weight: .black))
                .foregroundColor(isDark ? .white : .black)
            if vm.timerDisplay == "START" {
                Button(action: {
                    editedName = vm.challenge.title
                    showNamePopup = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isDark ? .white.opacity(0.6) : Color(hex: "#888888"))
                }
            }
        }
    }

    @ViewBuilder
    private func memberGridItem(member: ChallengeMember, index: Int) -> some View {
        let isMe = member.userId == authVM.currentUserId
        if isMe {
            Button(action: { onMyTasks(vm.challenge) }) {
                MemberCard(member: member, rank: index + 1, isMe: true)
            }
            .buttonStyle(.plain)
            .popoverTip(streakTip, arrowEdge: .top)
        } else {
            MemberCard(member: member, rank: index + 1, isMe: false)
        }
    }

    private func updateChallengeName(_ name: String) {
        guard let cid = vm.challenge.id else { return }
        db.collection("challenges").document(cid).updateData(["title": name])
    }

    private func startPendingListener() {
        guard let cid = vm.challenge.id else { return }
        pendingListener = db.collection("challenges").document(cid)
            .addSnapshotListener { snap, _ in
                let data = snap?.data()?["pendingRuleChange"]
                hasPendingChange = data != nil
            }
    }

    private func shareChallenge() {
        let av = UIActivityViewController(activityItems: [vm.shareMessage], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}

// MARK: - MemberCard
private struct MemberCard: View {
    let member: ChallengeMember
    let rank: Int
    let isMe: Bool
    @Environment(\.colorScheme) private var colorScheme

    private var progress: Double { member.progressPercent / 100.0 }
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(isDark ? Color.white.opacity(0.15) : Color(hex: "#D9D5F0"), lineWidth: 7).frame(width: 90, height: 90)
                if progress > 0 {
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(isDark ? Color(hex: "#B296EB") : Color(hex: "#341D71"), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
                Circle().fill(isDark ? Color.white.opacity(0.1) : Color(hex: "#E8E4F0")).frame(width: 74, height: 74)
                if let base64 = member.profileImageBase64, !base64.isEmpty,
                   let data = Data(base64Encoded: base64), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } else if let url = member.profileImageURL, !url.isEmpty {
                    AsyncImage(url: URL(string: url)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill").font(.system(size: 30)).foregroundColor(isDark ? .white.opacity(0.7) : Color(hex: "#341D71"))
                    }
                    .frame(width: 70, height: 70).clipShape(Circle())
                } else {
                    Image(systemName: "person.fill").font(.system(size: 34)).foregroundColor(isDark ? .white.opacity(0.7) : Color(hex: "#341D71"))
                }
            }
            .frame(width: 100, height: 100).padding(.top, 16)

            Text(isMe ? "ME" : member.displayName.uppercased())
                .font(.system(size: 14, weight: .black)).foregroundColor(isDark ? .white : Color(hex: "#341D71")).lineLimit(1)
            Text("\(Int(member.progressPercent))%")
                .font(.system(size: 13, weight: .semibold)).foregroundColor(isDark ? .white.opacity(0.5) : Color(hex: "#9E9E9E"))
            Text("#\(rank)")
                .font(.system(size: 12, weight: .black)).foregroundColor(isDark ? .black : .black)
                .padding(.horizontal, 14).padding(.vertical, 4)
                .background(isDark ? Color.white.opacity(0.9) : Color.white).cornerRadius(30)
            Spacer(minLength: 4)
        }
        .frame(height: 210).frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? Color.white.opacity(0.04) : Color.white.opacity(0.30))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(isDark ? Color(hex: "#B296EB").opacity(0.35) : Color(hex: "#8EBAC5").opacity(0.45), lineWidth: 1))
        )
    }
}

// MARK: - EmptySlotCard
private struct EmptySlotCard: View {
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(Color(hex: "#D9D5F0"), lineWidth: 7).frame(width: 90, height: 90)
                Circle().fill(Color(hex: "#E8E4F0")).frame(width: 74, height: 74)
                Image(systemName: "person.badge.plus").font(.system(size: 28)).foregroundColor(Color(hex: "#A89DD4"))
            }
            .frame(width: 100, height: 100).padding(.top, 16)
            Text("Invite").font(.system(size: 14, weight: .black)).foregroundColor(Color(hex: "#A89DD4"))
            Spacer(minLength: 4)
        }
        .frame(height: 210).frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "#C8C4E8").opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
        )
    }
}

#Preview("Light") {
    NavigationStack {
        ChallengeDetailView(
            challenge: Challenge(
                id: "preview", title: "let's do it", description: "",
                createdBy: "uid", startDate: Date().addingTimeInterval(60),
                endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                status: "active", memberCount: 1, createdAt: Date(), memberIds: ["uid"]
            )
        )
        .environmentObject(AuthViewModel())
    }
}

#Preview("Dark") {
    NavigationStack {
        ChallengeDetailView(
            challenge: Challenge(
                id: "preview", title: "let's do it", description: "",
                createdBy: "uid", startDate: Date().addingTimeInterval(60),
                endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                status: "active", memberCount: 1, createdAt: Date(), memberIds: ["uid"]
            )
        )
        .environmentObject(AuthViewModel())
    }
    .preferredColorScheme(.dark)
}
