//
//  SettingsViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 04/06/2026.

import Foundation
import FirebaseFirestore
import UIKit
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published var displayName: String = ""
    @Published var handle: String = ""
    @Published var profileImageBase64: String? = nil  // ✅ Base64 instead of URL
    @Published var selectedImage: UIImage? = nil
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var language: String = "EN"
    @Published var isDarkMode: Bool = false

    private let db = Firestore.firestore()

    // MARK: - Load
    func load(uid: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let doc = try await db
                .collection("users")
                .document(uid)
                .getDocument()

            guard doc.exists else { return }
            displayName          = doc["displayName"] as? String ?? ""
            handle               = doc["handle"] as? String ?? ""
            profileImageBase64   = doc["profileImageBase64"] as? String
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save
    func save(uid: String) async {
        isSaving = true
        defer { isSaving = false }
        errorMessage = nil

        let trimmedName   = displayName.trimmingCharacters(in: .whitespaces)
        let trimmedHandle = handle.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            errorMessage = "Display name cannot be empty."
            return
        }
        guard !trimmedHandle.isEmpty else {
            errorMessage = "Handle cannot be empty."
            return
        }

        do {
            var updates: [String: Any] = [
                "displayName": trimmedName,
                "handle":      trimmedHandle
            ]

            // ✅ Convert selected image to Base64 and save to Firestore
            if let image = selectedImage {
                guard let base64 = imageToBase64(image) else {
                    errorMessage = "Failed to process image. Try a smaller one."
                    return
                }
                updates["profileImageBase64"] = base64
                profileImageBase64 = base64
                selectedImage = nil
            }

            try await db
                .collection("users")
                .document(uid)
                .updateData(updates)

            successMessage = "Profile updated!"

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Image → Base64
    // ⚠️ Firestore document limit is 1MB.
    // We compress aggressively to stay well under that.
    private func imageToBase64(_ image: UIImage) -> String? {
        // Resize to max 200x200 to keep Firestore document small
        let resized = resizeImage(image, maxDimension: 200)
        guard let data = resized.jpegData(compressionQuality: 0.5) else { return nil }

        // Safety check — Firestore doc limit is 1MB, Base64 adds ~33% overhead
        let base64 = data.base64EncodedString()
        let sizeKB = Double(base64.count) / 1024
        print("📸 Profile image size: \(String(format: "%.1f", sizeKB))KB")

        guard sizeKB < 700 else {
            return nil  // Too large — caller shows error
        }
        return base64
    }

    // MARK: - Resize Helper
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        guard ratio < 1 else { return image } // Already small enough

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
