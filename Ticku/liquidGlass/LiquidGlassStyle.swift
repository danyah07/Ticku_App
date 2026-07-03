//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 09/01/1448 AH.
//

import SwiftUI

struct LiquidGlassStyle {

    /// شدة اللون الافتراضية للكاردات
    static let tintIntensity: Double = 0.55

    /// نصف قطر الانحناء الافتراضي
    static let defaultCornerRadius: CGFloat = 20
}

extension View {

    /// للكاردات
    @ViewBuilder
    func liquidGlass(
        tint: Color,
        cornerRadius: CGFloat = LiquidGlassStyle.defaultCornerRadius,
        intensity: Double = LiquidGlassStyle.tintIntensity
    ) -> some View {

        if #available(iOS 26.0, *) {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(tint.opacity(intensity))
                )
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(tint.opacity(intensity))
                )
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    /// للأزرار (يمكن تحديد شفافية مختلفة)
    @ViewBuilder
    func liquidGlassButton(
        tint: Color,
        cornerRadius: CGFloat = LiquidGlassStyle.defaultCornerRadius,
        intensity: Double = LiquidGlassStyle.tintIntensity
    ) -> some View {

        if #available(iOS 26.0, *) {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(tint.opacity(intensity))
                )
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(tint.opacity(intensity))
                )
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    /// للعناصر الدائرية
    @ViewBuilder
    func liquidGlassCircle(
        tint: Color,
        intensity: Double = LiquidGlassStyle.tintIntensity
    ) -> some View {

        if #available(iOS 26.0, *) {
            self
                .background(
                    Circle()
                        .fill(tint.opacity(intensity))
                )
                .glassEffect(.regular, in: .circle)
                .clipShape(Circle())
        } else {
            self
                .background(
                    Circle()
                        .fill(tint.opacity(intensity))
                )
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
}
