//
//  Untitled.swift
//  firebasetrial
//
//  Created by Jumana on 09/01/1448 AH.
//

import SwiftUI


struct LiquidGlassStyle {
    /// شدة اللون تحت الزجاج (0 = زجاج شفاف بالكامل، 1 = صلب بدون شفافية)
    static let tintIntensity: Double = 0.55
    /// نصف قطر الانحناء الافتراضي
    static let defaultCornerRadius: CGFloat = 20
}

extension View {

    /// يطبق Liquid Glass الرسمي (iOS 26) مع لون شفاف فوقه.
    /// التينت يُقص بنفس شكل الزجاج بالضبط — ما يبرز أي مستطيل وراه.
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

    /// نسخة للأزرار التفاعلية — فيها تأثير ضغط زجاجي خفيف
    @ViewBuilder
    func liquidGlassButton(
        tint: Color,
        cornerRadius: CGFloat = LiquidGlassStyle.defaultCornerRadius
    ) -> some View {
        if #available(iOS 26.0, *) {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(tint.opacity(LiquidGlassStyle.tintIntensity))
                )
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(tint.opacity(LiquidGlassStyle.tintIntensity))
                )
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    /// زجاج دائري (للأفاتار، الأيقونات المستديرة، إلخ)
    @ViewBuilder
    func liquidGlassCircle(tint: Color) -> some View {
        if #available(iOS 26.0, *) {
            self
                .background(
                    Circle().fill(tint.opacity(LiquidGlassStyle.tintIntensity))
                )
                .glassEffect(.regular, in: .circle)
                .clipShape(Circle())
        } else {
            self
                .background(
                    Circle().fill(tint.opacity(LiquidGlassStyle.tintIntensity))
                )
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
}
