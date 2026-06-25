//
//  AvatarView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 19/05/2026.
//


//
//  AvatarView.swift — part of SharedComponents.swift
//  firebasetrial

import SwiftUI

struct AvatarView: View {
    // ✅ Accepts either a URL string OR a Base64 string
    let imageURL: String?
    var size: CGFloat = 44
    // Optional Base64 override — takes priority over URL
    var base64: String? = nil
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var body: some View {
        Group {
            if let base64 = base64,
               let imageData = Data(base64Encoded: base64),
               let uiImage = UIImage(data: imageData) {
                // ✅ Render from Base64
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()

            } else if let urlString = imageURL,
                      let url = URL(string: urlString) {
                // Render from URL (future-proof for when Storage is added)
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure, .empty:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(isDark ? Color(hex: "#B296EB") : Color.ticku.primary, lineWidth: size * 0.077)
        )
    }

    private var placeholder: some View {
        ZStack {
            Circle().fill(Color.ticku.accentSoft)
            Image(systemName: "person.fill")
                .font(.system(size: size * 0.45))
                .foregroundColor(Color.ticku.accent)
        }
    }
}
