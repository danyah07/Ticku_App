//
//  Emptystateview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 19/05/2026.
//

import SwiftUI

struct EmptyStateView: View {
    var title: String   = "Ready to compete?"
    var message: String = "Create your first challenge and invite your friends to stay productive together"

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#8B8B9E"))
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#8B8B9E").opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(hex: "#E8E4F8"), Color(hex: "#D6D0F0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
