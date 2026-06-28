//
//  TickuDesignTokens.swift
//  firebasetrial
//
//  Single source of truth for all colors, typography, and spacing.
//  Usage: Color.ticku.primary, Font.ticku.title, etc.
//




import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: - Color Extension (Hex Support)
// ─────────────────────────────────────────────────────────────

extension Color {

    /// Unlabeled: Color("#6B5CE7")
    init(_ hex: String) {
        self.init(hex: hex)
    }

    /// Labeled: Color(hex: "#6B5CE7")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )

        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Ticku Design Tokens
// ─────────────────────────────────────────────────────────────

extension Color {
    static let ticku = TickuColors.self
}

/// Zero-cost namespace — use `Color.ticku.primary` anywhere.
enum TickuColors {
    // ── Challenge Result ─────────────────────────────────────────
    static let challengeDarkPurple    = Color(hex: "#341D71")
    static let challengePurple        = Color(hex: "#8E8AC5")
    static let challengeGradientStart = Color(hex: "#8E8AC5")
    static let challengeGradientEnd   = Color(hex: "#F6EFFA")
    static let challengeProgressTrack = Color(hex: "#D9D9D9")
    static let challengeButton        = Color(hex: "#5A3F93")
    static let joinButtonBlue = Color(hex: "#579CE7")
    // ── Brand ────────────────────────────────────────────────
    static let primary       = Color(hex: "#3D2C8D")
    static let primaryLight  = Color(hex: "#5B4DB5")
    static let accent        = Color(hex: "#6B5CE7")
    static let accentSoft    = Color(hex: "#EDE9FF")

    // ── Intro Action Colors ──────────────────────────────────
    static let introActionLight = Color(hex: "#341D71")
    static let introActionDark  = Color(hex: "#8E8AC5")

    // ── Backgrounds ──────────────────────────────────────────
    static let backgroundTop    = Color.white
    static let backgroundBottom = Color(hex: "#D6D0F0")
    static let cardBackground   = Color(hex: "#F5F4FA")
    static let challengeCard    = Color(hex: "#3D2C8D")

    // ── Status ───────────────────────────────────────────────
    static let doneGreen   = Color(hex: "#2ECC71")
    static let winsOrange  = Color(hex: "#F39C12")
    static let errorRed    = Color(hex: "#E74C3C")

    // ── Text ─────────────────────────────────────────────────
    static let textPrimary   = Color(hex: "#1A1A2E")
    static let textSecondary = Color(hex: "#8B8B9E")
    static let textOnPurple  = Color.white

    // ── Buttons ──────────────────────────────────────────────
    static let joinButtonBackground = Color(hex: "#C8C4E8")
}

// ─────────────────────────────────────────────────────────────
// MARK: - Ticku Typography Tokens
// ─────────────────────────────────────────────────────────────

extension Font {
    enum ticku {
        static let largeTitle    = Font.system(size: 28, weight: .bold)
        static let title         = Font.system(size: 22, weight: .bold)
        static let sectionHeader = Font.system(size: 17, weight: .bold)
        static let body          = Font.system(size: 15, weight: .regular)
        static let bodyMedium    = Font.system(size: 15, weight: .medium)
        static let caption       = Font.system(size: 12, weight: .regular)
        static let captionBold   = Font.system(size: 12, weight: .semibold)
        static let button        = Font.system(size: 15, weight: .semibold)
        static let smallButton   = Font.system(size: 13, weight: .semibold)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Ticku Spacing Tokens
// ─────────────────────────────────────────────────────────────

enum TickuSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 20
    static let xl:  CGFloat = 26
    static let xxl: CGFloat = 32

    /// Standard horizontal screen padding
    static let screenH: CGFloat = 20
}

// ─────────────────────────────────────────────────────────────
// MARK: - Ticku Corner Radius Tokens
// ─────────────────────────────────────────────────────────────

enum TickuRadius {
    static let sm:   CGFloat = 10
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 20
    static let pill: CGFloat = 999
}
