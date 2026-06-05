//
//  SplashView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct SplashView: View {

    @StateObject private var viewModel = SplashViewModel()
    @Environment(\.colorScheme) private var colorScheme

    // ✅ Flipping this triggers SwiftUI to re-render and show RootView
    @State private var showHome = false

    private var gradientColors: [Color] {
        let purple = Color(red: 142/255, green: 138/255, blue: 197/255)
        return colorScheme == .dark ? [purple, .black] : [purple, .white]
    }

    private var titleColor: Color {
        colorScheme == .dark
            ? .white
            : Color(red: 52/255, green: 29/255, blue: 113/255)
    }

    var body: some View {
        Group {
            if showHome {
                RootView()
            } else if viewModel.navigateToNext {
                if viewModel.hasSeenIntro {
                    RootView()
                } else {
                    IntroView(onFinish: {
                        UserDefaults.standard.set(true, forKey: "hasSeenIntro")
                        showHome = true
                    })
                }
            } else {
                splashScreen
            }
        }
    }

    private var splashScreen: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Text("Ticku")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(titleColor)
        }
        .onAppear {
            viewModel.startSplashTimer()
        }
    }
}

#Preview("Light") { SplashView().preferredColorScheme(.light) }
#Preview("Dark")  { SplashView().preferredColorScheme(.dark) }
