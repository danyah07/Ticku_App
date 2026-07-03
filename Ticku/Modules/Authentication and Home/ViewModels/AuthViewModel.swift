//
//  AuthViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  AuthViewModel.swift
//  firebasetrial

//
//  AuthViewModel.swift
//  firebasetrial

//
//  AuthViewModel.swift
//  firebasetrial

import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isAuthenticated: Bool = false
    @Published var currentUserId: String? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isDeleting: Bool = false

    private(set) var currentNonce: String? = nil
    private var authListener: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        startListening()
    }

    deinit {
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Listener
    private func startListening() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("🔔 Auth state changed — user: \(user?.uid ?? "nil")")
            Task { @MainActor in
                self?.currentUserId = user?.uid
                self?.isAuthenticated = user != nil
                print("🔔 isAuthenticated published: \(user != nil)")
            }
        }
    }

    // MARK: - Nonce (للـ Sign In العادي)
    func prepareNonce() -> String {
        let nonce = CryptoUtils.randomNonceString()
        currentNonce = nonce
        return CryptoUtils.sha256(nonce)
    }

    // MARK: - Apple Sign In
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .failure(let error):
            let nsError = error as NSError
            print("❌ Apple Sign In failed: \(nsError.code) — \(error.localizedDescription)")
            if nsError.code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
            return

        case .success(let authorization):
            print("✅ Apple authorization succeeded")

            guard
                let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let identityTokenData = appleCredential.identityToken,
                let identityTokenString = String(data: identityTokenData, encoding: .utf8),
                let rawNonce = currentNonce
            else {
                print("❌ Missing credentials after Apple auth")
                errorMessage = "Apple Sign In failed: missing credentials."
                return
            }

            print("✅ Credentials extracted, signing into Firebase...")
            isLoading = true
            defer { isLoading = false }

            do {
                let firebaseCredential = OAuthProvider.appleCredential(
                    withIDToken: identityTokenString,
                    rawNonce: rawNonce,
                    fullName: appleCredential.fullName
                )

                let authResult = try await Auth.auth().signIn(with: firebaseCredential)
                print("✅ Firebase sign in succeeded, uid: \(authResult.user.uid)")

                let displayName = [
                    appleCredential.fullName?.givenName,
                    appleCredential.fullName?.familyName
                ]
                .compactMap { $0 }
                .joined(separator: " ")

                print("✅ Writing to Firestore...")
                try await createOrUpdateUser(
                    uid: authResult.user.uid,
                    email: authResult.user.email ?? appleCredential.email ?? "",
                    displayName: displayName.isEmpty
                        ? authResult.user.displayName ?? "Ticku User"
                        : displayName,
                    appleUserIdentifier: appleCredential.user
                )
                print("✅ Firestore write complete")

                try await Task.sleep(for: .milliseconds(500))
                print("✅ isAuthenticated is now: \(self.isAuthenticated)")
                currentNonce = nil

            } catch {
                print("❌ Error during Firebase sign in: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Re-authenticate then Delete Account
    // ✅ Apple تشترط حذف الحساب الكامل للـ App Store
    // Firebase يطلب re-auth قبل الحذف لو تسجيل الدخول قديم
    // هذا منفصل تماماً عن منطق تسجيل الدخول العادي
    func reauthAndDelete(idToken: String, rawNonce: String) async {
        isDeleting = true
        defer { isDeleting = false }

        guard let uid = currentUserId else { return }

        do {
            // 1. Re-authenticate
            let credential = OAuthProvider.appleCredential(
                withIDToken: idToken,
                rawNonce: rawNonce,
                fullName: nil
            )
            try await Auth.auth().currentUser?.reauthenticate(with: credential)

            // 2. احذف كل التحديات
            let snap = try? await db
                .collection("challenges")
                .whereField("memberIds", arrayContains: uid)
                .getDocuments()

            for doc in snap?.documents ?? [] {
                let members = try? await doc.reference.collection("members").getDocuments()
                for m in members?.documents ?? [] { try? await m.reference.delete() }
                let tasks = try? await doc.reference.collection("tasks").getDocuments()
                for t in tasks?.documents ?? [] { try? await t.reference.delete() }
                try? await doc.reference.delete()
            }

            // 3. احذف مستند المستخدم
            try? await db.collection("users").document(uid).delete()

            // 4. احذف Firebase Auth — يطلق listener → isAuthenticated = false → الهوم
            try await Auth.auth().currentUser?.delete()

            print("✅ Account fully deleted")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Delete failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Account (fallback بدون re-auth — للحالات القريبة من تسجيل الدخول)
    func deleteAccount() async {
        isDeleting = true
        defer { isDeleting = false }

        guard let uid = currentUserId else { return }

        let snap = try? await db
            .collection("challenges")
            .whereField("memberIds", arrayContains: uid)
            .getDocuments()

        for doc in snap?.documents ?? [] {
            let members = try? await doc.reference.collection("members").getDocuments()
            for m in members?.documents ?? [] { try? await m.reference.delete() }
            let tasks = try? await doc.reference.collection("tasks").getDocuments()
            for t in tasks?.documents ?? [] { try? await t.reference.delete() }
            try? await doc.reference.delete()
        }

        try? await db.collection("users").document(uid).delete()

        do {
            try await Auth.auth().currentUser?.delete()
            print("✅ Account deleted")
        } catch {
            // لو فشل بسبب re-auth، نعمل sign out على الأقل
            print("⚠️ Auth delete failed, signing out: \(error.localizedDescription)")
            signOut()
        }
    }

    // MARK: - Firestore User Document
    private func createOrUpdateUser(
        uid: String,
        email: String,
        displayName: String,
        appleUserIdentifier: String
    ) async throws {
        let ref = db.collection("users").document(uid)
        let doc = try await ref.getDocument()

        if doc.exists {
            try await ref.updateData([
                "lastActiveDate": FieldValue.serverTimestamp()
            ])
            print("✅ Returning user — lastActiveDate updated")
        } else {
            let newUser: [String: Any] = [
                "uid":                      uid,
                "displayName":              displayName,
                "profileImageURL":          NSNull(),
                "email":                    email,
                "appleUserIdentifier":      appleUserIdentifier,
                "totalChallengesCompleted": 0,
                "currentStreak":            0,
                "longestStreak":            0,
                "lastActiveDate":           FieldValue.serverTimestamp(),
                "createdAt":                FieldValue.serverTimestamp()
            ]
            try await ref.setData(newUser)
            print("✅ New user document created for uid: \(uid)")
        }
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentNonce = nil
            print("✅ User signed out")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
