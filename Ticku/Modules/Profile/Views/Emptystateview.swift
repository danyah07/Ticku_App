//
//  Emptystateview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 19/05/2026.
//

import SwiftUI

struct EmptyStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var title: String = NSLocalizedString("ready_to_compete", comment: "")
    var message: String = NSLocalizedString("create_first_challenge", comment: "")
    
    var body: some View {
        VStack(spacing: 14) {

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isDark ? .white.opacity(0.45) : Color(hex: "#6E6E73"))

            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isDark ? .white.opacity(0.35) : Color(hex: "#8E8E93"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 30)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: isDark
                        ? [
                            Color(hex: "#341D71").opacity(0.20),
                            Color(hex: "#341D71").opacity(0.12)
                        ]
                        : [
                            Color(hex: "#341D71").opacity(0.05),
                            Color(hex: "#341D71").opacity(0.09)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(
                    isDark ? Color(hex: "#8E8AC5").opacity(0.25) : Color.white.opacity(0.45),
                    lineWidth: 1
                )
        )
    }
}
