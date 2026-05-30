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
    let percentage: Double  // 0.0 – 1.0
    var ringSize: CGFloat = 90
    var lineWidth: CGFloat = 10

    @State private var animated: Double = 0

    private let accentColor  = Color.ticku.accent
    private let primaryColor = Color.ticku.primary

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(accentColor.opacity(0.15), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: animated)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.2), value: animated)

            // Percentage label
            Text("%\(Int(percentage * 100))")
                .font(.system(size: ringSize * 0.22, weight: .bold, design: .rounded))
                .foregroundColor(primaryColor)
        }
        .frame(width: ringSize, height: ringSize)
        .onAppear {
            animated = percentage
        }
        // ✅ iOS 17+ onChange syntax
        .onChange(of: percentage) {
            animated = percentage
        }
    }
}
