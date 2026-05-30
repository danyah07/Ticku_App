//
//  Primarybuttonview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 19/05/2026.
//

import SwiftUI

struct PrimaryButtonView: View {
    let title: String
    var style: ButtonStyle = .solid
    var action: () -> Void

    enum ButtonStyle {
        case solid    // purple fill
        case muted    // lavender fill
        case outline  // white border on dark bg
        case white    // white fill on dark bg
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(fgColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(bgColor)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(strokeColor, lineWidth: strokeWidth))
        }
    }

    private var fgColor: Color {
        switch style {
        case .solid:   return .white
        case .muted:   return Color(hex: "#1A1A2E")
        case .outline: return .white
        case .white:   return Color(hex: "#3D2C8D")
        }
    }
    private var bgColor: Color {
        switch style {
        case .solid:   return Color(hex: "#3D2C8D")
        case .muted:   return Color(hex: "#C8C4E8")
        case .outline: return Color.white.opacity(0.15)
        case .white:   return .white
        }
    }
    private var strokeColor: Color {
        style == .outline ? Color.white.opacity(0.35) : .clear
    }
    private var strokeWidth: CGFloat {
        style == .outline ? 1 : 0
    }
}
