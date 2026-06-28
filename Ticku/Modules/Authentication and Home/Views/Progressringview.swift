//
//  Progressringview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 19/05/2026.
//

//
//  Progressringview.swift
//  firebasetrial

import SwiftUI

struct ProgressRingView: View {
    let percentage: Double
    var ringSize: CGFloat = 90
    var lineWidth: CGFloat = 10

    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    @State private var animated: Double = 0

    private var progressColor: Color {
        isDark ? Color(hex: "#8E8AC5") : Color(hex: "#341D71")
    }

    private var circleFillColor: Color {
        isDark ? Color(hex: "#212122") : Color(hex: "#F2F2F7")
    }

    private var textColor: Color {
        isDark ? .white : Color(hex: "#341D71")
    }

    var body: some View {
        ZStack {
            if animated > 0 {
                Circle()
                    .trim(from: 0, to: animated)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: ringSize + 8, height: ringSize + 8)
                    .rotationEffect(.degrees(-90))
            }

            Circle()
                .fill(circleFillColor)
                .frame(width: ringSize, height: ringSize)
                .shadow(
                    color: Color.black.opacity(isDark ? 0 : 0.25),
                    radius: 4,
                    x: 0,
                    y: 4
                )

            Text("%\(Int(percentage * 100))")
                .font(.system(size: ringSize * 0.25, weight: .bold, design: .rounded))
                .foregroundColor(textColor)
        }
        .frame(width: ringSize + 18, height: ringSize + 18)
        .onAppear {
            animated = percentage
        }
        .onChange(of: percentage) {
            animated = percentage
        }
    }
}
