//
//  SplashViewModel.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct SplashViewModel: View {
    
    @State private var navigateToNext = false
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                colors: [
                    Color(hex: "8E8AC5"),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Text("Ticku")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#341D71"))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                navigateToNext = true
            }
        }
    }
}

#Preview {
    SplashViewModel()
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: UInt64
        
        switch hex.count {
        case 6:
            (r, g, b) = (
                (int >> 16) & 0xff,
                (int >> 8) & 0xff,
                int & 0xff
            )
            
        default:
            (r, g, b) = (1, 1, 1)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
