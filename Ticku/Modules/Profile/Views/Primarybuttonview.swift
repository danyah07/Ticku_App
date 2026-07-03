//
//  Primarybuttonview.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 19/05/2026.
//

import SwiftUI

struct PrimaryButtonView: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    var style: ButtonStyle = .solid
    var action: () -> Void

    enum ButtonStyle {
        case solid
        case muted
        case outline
        case white
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(fgColor)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(bgColor)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(strokeColor, lineWidth: strokeWidth))
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        }
        .buttonStyle(.plain)
        // ✅ Liquid Glass — بس تأثير الزجاج التفاعلي فوق الألوان الأصلية بدون أي تغيير عليها
        .if_available_glass()
    }

    private var fgColor: Color {
        switch style {
        case .solid:   return .white
        case .muted:   return colorScheme == .dark ? .white : .black
        case .outline: return .white
        case .white:   return Color.ticku.challengeDarkPurple
        }
    }

    private var bgColor: Color {
        switch style {
        case .solid:
            return colorScheme == .dark ? Color(hex: "#7771C8") : Color.ticku.challengeDarkPurple
        case .muted:
            return colorScheme == .dark ? Color(hex: "#C9E3FF").opacity(0.35) : Color(hex: "#579CE7").opacity(0.35)
        case .outline: return Color.white.opacity(0.15)
        case .white:   return .white
        }
    }

    private var strokeColor: Color {
        switch style {
        case .muted:
            return colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.35)
        case .outline: return Color.white.opacity(0.35)
        default:       return .clear
        }
    }

    private var strokeWidth: CGFloat {
        switch style {
        case .muted, .outline: return 1
        default:               return 0
        }
    }

    private var shadowColor: Color {
        switch style {
        case .solid:  return Color.black.opacity(0.25)
        case .muted:  return colorScheme == .dark ? Color.black.opacity(0.25) : .clear
        default:      return .clear
        }
    }

    private var shadowRadius: CGFloat { style == .solid || style == .muted ? 4 : 0 }
    private var shadowY: CGFloat      { style == .solid || style == .muted ? 4 : 0 }
}

// ✅ تأثير الزجاج التفاعلي فقط — بدون تغيير أي لون أصلي
private extension View {
    @ViewBuilder
    func if_available_glass() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            self
        }
    }
}
