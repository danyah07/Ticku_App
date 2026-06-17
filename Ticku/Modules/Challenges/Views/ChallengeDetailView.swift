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

struct ChallengeDetailView: View {

    @StateObject private var vm: ChallengeDetailViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var showGiveUpAlert = false
    @State private var showMenu = false
    @State private var showDetails = false
    @State private var showComplete = false
    @State private var hasPendingChange = false

    var onBack: () -> Void = {}
    var onMyTasks: (Challenge) -> Void = { _ in }

    private let db = Firestore.firestore()
    @State private var pendingListener: ListenerRegistration? = nil

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

            VStack(spacing: 0) {

                // ── Nav Bar ───────────────────────────────
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    if vm.timerDisplay == "START" {
                        Button(action: shareChallenge) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    } else {
                        Button(action: { showMenu = true }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
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
                            Button("Details") { showDetails = true }
                            Button("Give up", role: .destructive) { showGiveUpAlert = true }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer().frame(height: 36)

                // ── Title ─────────────────────────────────
                HStack(spacing: 8) {
                    Text(vm.challenge.title)
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.black)
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#888888"))
                }

                Spacer().frame(height: 8)

                Text("TIME REMAINING")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#AAAAAA"))
                    .tracking(1.5)

                Spacer().frame(height: 14)

                // ── Timer / START ─────────────────────────
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(hex: "#E8E2F8"))
                        .frame(width: 260, height: 58)
                    Text(vm.timerDisplay)
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Color(hex: "#5B3DBF"))
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
                    .foregroundColor(Color(hex: "#5B6AD4"))
                    .padding(.horizontal, 16).padding(.vertical, 5)
                    .background(Color(hex: "#E4E8FF"))
                    .cornerRadius(20)

                Spacer().frame(height: 24)

                // ── Members Grid ──────────────────────────
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 14
                    ) {
                        ForEach(Array(vm.members.enumerated()), id: \.element.id) { index, member in
                            let isMe = member.userId == authVM.currentUserId
                            if isMe {
                                Button(action: { onMyTasks(vm.challenge) }) {
                                    MemberCard(member: member, rank: index + 1, isMe: true)
                                }
                                .buttonStyle(.plain)
                            } else {
                                MemberCard(member: member, rank: index + 1, isMe: false)
                            }
                        }


                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
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
                players: vm.members.enumerated().map { index, member in
                    Player(
                        name: member.displayName,
                        rank: index + 1,
                        isMe: member.userId == authVM.currentUserId,
                        completedTasks: member.tasksCompleted,
                        totalTasks: member.tasksTotal
                    )
                },
                challengeRule: vm.challenge.description,
                onDone: { onBack() }
            )
        }
        .onChange(of: vm.timerDisplay) {
            if vm.timerDisplay == "00:00:00" && vm.challengeStartDate != nil {
                showComplete = true
            }
        }
        .onChange(of: vm.members) {
            if vm.challengeStartDate != nil &&
               vm.members.contains(where: { $0.progressPercent >= 100 }) {
                showComplete = true
            }
        }
        .alert("Give up?", isPresented: $showGiveUpAlert) {
            Button("Give up", role: .destructive) { onBack() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to leave this challenge?")
        }
        .onAppear {
            vm.startListening(currentUserId: authVM.currentUserId ?? "")
            startPendingListener()
        }
        .onDisappear {
            pendingListener?.remove()
        }
        .task {
            await vm.saveInviteCode()
        }
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

    private var progress: Double { member.progressPercent / 100.0 }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(Color(hex: "#D9D5F0"), lineWidth: 7).frame(width: 90, height: 90)
                if progress > 0 {
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(Color(hex: "#341D71"), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
                Circle().fill(Color(hex: "#E8E4F0")).frame(width: 74, height: 74)
                if let url = member.profileImageURL, !url.isEmpty {
                    AsyncImage(url: URL(string: url)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill").font(.system(size: 30)).foregroundColor(Color(hex: "#341D71"))
                    }
                    .frame(width: 70, height: 70).clipShape(Circle())
                } else {
                    Image(systemName: "person.fill").font(.system(size: 34)).foregroundColor(Color(hex: "#341D71"))
                }
            }
            .frame(width: 100, height: 100).padding(.top, 16)

            Text(isMe ? "ME" : member.displayName.uppercased())
                .font(.system(size: 14, weight: .black)).foregroundColor(Color(hex: "#341D71")).lineLimit(1)
            Text("\(Int(member.progressPercent))%")
                .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "#9E9E9E"))
            Text("#\(rank)")
                .font(.system(size: 12, weight: .black)).foregroundColor(.black)
                .padding(.horizontal, 14).padding(.vertical, 4)
                .background(Color.white).cornerRadius(30)
            Spacer(minLength: 4)
        }
        .frame(height: 210).frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.30))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "#8EBAC5").opacity(0.45), lineWidth: 1))
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

#Preview {
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
