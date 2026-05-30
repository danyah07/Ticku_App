//
//  AvatarView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 19/05/2026.
//


import SwiftUI

struct AvatarView: View {
    let imageURL: String?
    var size: CGFloat = 44
    var borderColor: Color = Color(hex: "#6B5CE7")
    var borderWidth: CGFloat = 2.5

    var body: some View {
        Group {
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(borderColor, lineWidth: borderWidth))
    }

    private var placeholder: some View {
        Circle()
            .fill(Color(hex: "#F5F4FA"))
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(Color(hex: "#8B8B9E"))
            )
    }
}
