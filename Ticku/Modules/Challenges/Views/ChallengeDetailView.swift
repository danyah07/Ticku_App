//
//  ChallengeDetailView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct ChallengeDetailView: View {

    @StateObject private var vm: ChallengeDetailViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var hasShared: Bool = false
    @State private var showDetails: Bool = false
    @State private var showGiveUpAlert: Bool = false
    @State private var showMyTasks: Bool = false

    let currentUserId: String
    let currentUserName: String
    let initialTasks: [String]

    init(challenge: Challenge, tasks: [String] = [], currentUserId: String = "", currentUserName: String = "") {
        _vm = StateObject(
            wrappedValue: ChallengeDetailViewModel(challenge: challenge, tasks: tasks)
        )
        self.initialTasks = tasks
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
    }

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

                // MARK: - Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    if hasShared {
                        Menu {
                            Button(role: .destructive, action: {
                                showGiveUpAlert = true
                            }) {
                                Label("Give up", systemImage: "xmark.circle")
                            }
                            Button(action: {
                                showDetails = true
                            }) {
                                Label("Details", systemImage: "info.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    } else {
                        Button(action: { shareChallenge() }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                Spacer().frame(height: 28)

                // MARK: - Title
                HStack(spacing: 6) {
                    Text(vm.challenge.name)
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.black)
                    Image(systemName: "pencil")
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.6))
                }

                Spacer().frame(height: 10)

                // MARK: - Time Remaining
                Text("TIME REMAINING")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#9E9E9E"))
                    .tracking(1.2)

                Spacer().frame(height: 14)

                // MARK: - Timer
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(hex: "#E7DEF8"))
                        .frame(width: 290, height: 64)

                    Text(vm.timerDisplay)
                        .font(.system(
                            size: vm.timerStarted ? 20 : 32,
                            weight: .black
                        ))
                        .foregroundColor(Color(hex: "#4A2D91"))
                }

                Spacer().frame(height: 14)

                // MARK: - Players Count
                Text("\(vm.players.count) PLAYERS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#4A2D91"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#D8E8FF"))
                    .cornerRadius(20)

                Spacer().frame(height: 20)

                // MARK: - Players Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(vm.players) { player in
                            if player.isMe {
                                Button(action: { showMyTasks = true }) {
                                    PlayerCard(player: player)
                                }
                                .buttonStyle(.plain)
                            } else {
                                PlayerCard(player: player)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showDetails) {
            ChallengeDetailsPage(challenge: vm.challenge)
        }
        .navigationDestination(isPresented: $showMyTasks) {
            MyTasksView(
                challengeId: vm.challengeId,
                userId: currentUserId
            )
        }
        .alert("Give up?", isPresented: $showGiveUpAlert) {
            Button("Give up", role: .destructive) { dismiss() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to leave this challenge?")
        }
        .onAppear {
            // حفظ المهام الأولية في Firebase لما يدخل أول مرة
            if !initialTasks.isEmpty && !currentUserId.isEmpty {
                let service = ChallengeTaskService()
                service.saveTasks(
                    challengeId: vm.challengeId,
                    userId: currentUserId,
                    titles: initialTasks
                )
            }
        }
    }

    private func shareChallenge() {
        let av = UIActivityViewController(
            activityItems: [vm.shareMessage],
            applicationActivities: nil
        )
        av.completionWithItemsHandler = { _, completed, _, _ in
            if completed {
                hasShared = true
                vm.joinChallenge(playerName: "NAME\(vm.players.count)")
            }
        }
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}

#Preview {
    NavigationStack {
        ChallengeDetailView(
            challenge: Challenge(name: "let's do it", duration: .days3),
            currentUserId: "user1",
            currentUserName: "Danyah"
        )
    }
}
