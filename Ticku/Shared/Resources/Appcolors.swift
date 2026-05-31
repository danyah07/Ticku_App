//
//  Appcolors.swift
//  firebasetrial
//
//  Created by Jumana on 11/12/1447 AH.
//

import SwiftUI

extension Color {

    // MARK: - Primary
    static let primaryPurple      = Color(hex: "#341D71")
    static let primaryContainer   = Color(hex: "#E8E3F7")
    static let onPrimaryContainer = Color(hex: "#1A0A45")

    // MARK: - Surface
    static let surfaceBg          = Color(hex: "#F5F4FB")
    static let surfaceCard        = Color(hex: "#FFFFFF")

    // MARK: - Time picker
    static let timeBoxBg          = Color(hex: "#341D71")
    static let timeFieldBg        = Color(hex: "#FFFFFF")
    static let timeSubLabel       = Color(hex: "#C4B5E8")
    static let timeColon          = Color(hex: "#FFFFFF")

    // MARK: - Duration chips
    static let chipBorder         = Color(hex: "#DDD9EF")
    static let chipText           = Color(hex: "#341D71")
    static let chipActiveBg       = Color(hex: "#341D71")
    static let chipActiveText     = Color(hex: "#FFFFFF")

    // MARK: - Input fields
    static let fieldBorder        = Color(hex: "#E4E1F0")
    static let fieldBg            = Color(hex: "#F9F8FC")
    static let fieldText          = Color(hex: "#1A1A2E")

    // MARK: - Labels
    static let sectionLabel       = Color(hex: "#341D71")
    static let navTitle           = Color(hex: "#1A1A2E")

    // MARK: - Buttons
    static let btnActiveBg        = Color(hex: "#341D71")
    static let btnInactiveBg      = Color(hex: "#CEC9E2")
    static let btnText            = Color(hex: "#FFFFFF")

    // MARK: - Hex init
    init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        var val: UInt64 = 0
        Scanner(string: h).scanHexInt64(&val)
        self.init(
            red:   Double((val >> 16) & 0xFF) / 255,
            green: Double((val >>  8) & 0xFF) / 255,
            blue:  Double( val        & 0xFF) / 255
        )
    }
}
