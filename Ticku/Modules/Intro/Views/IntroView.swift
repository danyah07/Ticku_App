//
//  IntroView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct IntroView: View {
    
    @StateObject private var viewModel = IntroViewModels()
    
    var body: some View {
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            TabView(selection: $viewModel.currentPage) {
                pageOne.tag(0)
                pageTwo.tag(1)
                pageThree.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            if viewModel.currentPage != 2 {
                topSkip
            }
            
            bottomControls
        }
    }
}

// MARK: - PAGES

extension IntroView {
    
    private var pageOne: some View {
        VStack {
            
            Spacer()
                .frame(height: 170)
            
            circlesPageOne
            
            Spacer()
                .frame(height: 70)
            
            VStack(spacing: 19) {
                
                Text("intro_challenge_title".localized)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                Text("intro_challenge_desc".localized)
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }
            
            Spacer()
        }
    }
    
    private var pageTwo: some View {
        VStack {
            
            Spacer()
                .frame(height: 250)
            
            friendsCircles
            
            Spacer()
                .frame(height: 90)
            
            VStack(spacing: 19) {
                
                Text("intro_friends_title".localized)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                Text("intro_friends_desc".localized)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 330)
            }
            
            Spacer()
        }
    }
    
    private var pageThree: some View {
        VStack {
            
            Spacer()
                .frame(height: 195)
            
            streakIcons
                .scaleEffect(0.95)
            
            Spacer()
                .frame(height: 115)
            
            VStack(spacing: 19) {
                
                Text("intro_stay_title".localized)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                Text("intro_stay_desc".localized)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 330)
            }
            
            Spacer()
        }
    }
}

// MARK: - TOP SKIP

extension IntroView {
    
    private var topSkip: some View {
        VStack {
            
            HStack {
                
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.currentPage = 2
                    }
                } label: {
                    
                    Text("intro_skip".localized)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 36)
            .padding(.top, 5)
            
            Spacer()
        }
    }
}

// MARK: - BOTTOM CONTROLS

extension IntroView {
    
    private var bottomControls: some View {
        VStack {
            
            Spacer()
            
            ZStack {
                
                pageDots
                
                HStack {
                    
                    // BACK BUTTON
                    if viewModel.currentPage == 2 {
                        
                        Button {
                            withAnimation {
                                viewModel.currentPage -= 1
                            }
                        } label: {
                            
                            Image(
                                systemName:
                                    Locale.current.language.languageCode?.identifier == "ar"
                                ? "chevron.right"
                                : "chevron.left"
                            )
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        }
                    }
                    
                    Spacer()
                    
                    // NEXT BUTTON
                    if viewModel.currentPage != 2 {
                        
                        Button {
                            withAnimation {
                                viewModel.currentPage += 1
                            }
                        } label: {
                            
                            Image(
                                systemName:
                                    Locale.current.language.languageCode?.identifier == "ar"
                                ? "chevron.left"
                                : "chevron.right"
                            )
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        }
                        
                    } else {
                        
                        // START BUTTON
                        Button {
                            
                        } label: {
                            
                            Text("intro_start".localized)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 125, height: 50)
                                .background(Color(hex: "#341D71"))
                                .clipShape(Capsule())
                                .shadow(
                                    color: Color(hex: "#341D71").opacity(0.35),
                                    radius: 8,
                                    x: 0,
                                    y: 5
                                )
                        }
                        .offset(x: 18)
                    }
                }
                .padding(.horizontal, 36)
            }
            .padding(.bottom, 10)
        }
    }
    
    private var pageDots: some View {
        HStack(spacing: 8) {
            
            ForEach(0..<3) { index in
                
                Circle()
                    .fill(
                        viewModel.currentPage == index
                        ? Color.black
                        : Color.gray.opacity(0.3)
                    )
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - PAGE 1 CIRCLES

extension IntroView {
    
    private var circlesPageOne: some View {
        ZStack {
            
            userCircleTop
                .offset(x: -78, y: -42)
            
            userCircleBottom
                .offset(x: 70, y: 50)
            
            checkIconSmall
                .offset(x: -38, y: -152)
            
            checkIconBig
                .offset(x: 60, y: -79)
            
            checkIconBig
                .offset(x: -45, y: 80)
        }
        .frame(width: 360, height: 330)
    }
    
    private var userCircleTop: some View {
        Circle()
            .fill(Color(hex: "#F2F2F7"))
            .overlay(
                Circle()
                    .stroke(Color(hex: "#8E8AC5"), lineWidth: 5)
            )
            .frame(width: 122, height: 119)
            .overlay {
                
                Text("%100")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "#341D71"))
            }
    }
    
    private var userCircleBottom: some View {
        ZStack {
            
            Circle()
                .trim(from: 0.0, to: 0.60)
                .stroke(
                    Color(hex: "#8E8AC5"),
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round
                    )
                )
                .frame(width: 122, height: 119)
                .rotationEffect(.degrees(260))
                .offset(x: 1, y: -1)
            
            Circle()
                .fill(Color(hex: "#F2F2F7"))
                .frame(width: 119, height: 126)
                .shadow(
                    color: .black.opacity(0.19),
                    radius: 4,
                    x: -2,
                    y: 3
                )
            
            Text("%60")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "#341D71"))
        }
        .frame(width: 185, height: 185)
    }
    
    private var checkIconBig: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 58, weight: .bold))
            .foregroundColor(Color(hex: "#341D71"))
    }
    
    private var checkIconSmall: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(Color(hex: "#341D71"))
    }
}

// MARK: - PAGE 2 CIRCLES

extension IntroView {
    
    private var friendsCircles: some View {
        ZStack {
            
            userAvatarCircle
                .offset(x: -80, y: -45)
            
            userAvatarCircleShadow
                .offset(x: 69, y: -68)
            
            userAvatarCircleBottom
                .offset(x: 22, y: 72)
        }
        .scaleEffect(0.82)
        .frame(width: 240, height: 230)
    }
    
    private var userAvatarCircle: some View {
        Circle()
            .fill(Color(hex: "#F2F2F7"))
            .overlay(
                Circle()
                    .stroke(Color(hex: "#8E8AC5"), lineWidth: 6)
            )
            .frame(width: 128, height: 128)
            .overlay {
                
                Image(systemName: "person.fill")
                    .font(.system(size: 58))
                    .foregroundColor(Color(hex: "#D9D9D9"))
            }
    }
    
    private var userAvatarCircleShadow: some View {
        Circle()
            .fill(Color(hex: "#F2F2F7"))
            .frame(width: 128, height: 128)
            .shadow(
                color: .black.opacity(0.28),
                radius: 6,
                x: 0,
                y: 4
            )
            .overlay {
                
                Image(systemName: "person.fill")
                    .font(.system(size: 58))
                    .foregroundColor(Color(hex: "#D9D9D9"))
            }
    }
    
    private var userAvatarCircleBottom: some View {
        ZStack {
            
            Circle()
                .trim(from: 0.0, to: 0.80)
                .stroke(
                    Color(hex: "#8E8AC5"),
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    )
                )
                .frame(width: 128, height: 128)
                .rotationEffect(.degrees(260))
                .offset(x: 1, y: -1)
            
            Circle()
                .fill(Color(hex: "#F2F2F7"))
                .frame(width: 120, height: 120)
            
            Image(systemName: "person.fill")
                .font(.system(size: 58))
                .foregroundColor(Color(hex: "#D9D9D9"))
        }
        .frame(width: 140, height: 140)
    }
}

// MARK: - PAGE 3 ICONS

extension IntroView {
    
    private var streakIcons: some View {
        ZStack {
            
            blueBoltShape
                .offset(x: -58, y: -42)
            
            purpleCheckShape
                .offset(x: 64, y: -22)
            
            grayFireShape
                .offset(x: -18, y: 70)
        }
        .frame(width: 280, height: 260)
    }
    
    private var blueBoltShape: some View {
        RoundedRectangle(cornerRadius: 52)
            .fill(Color(hex: "#AAD1FC"))
            .frame(width: 111, height: 96)
            .rotationEffect(.degrees(-10))
            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 4)
            .overlay {
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 58))
                    .foregroundColor(.black)
            }
    }
    
    private var purpleCheckShape: some View {
        RoundedRectangle(cornerRadius: 55)
            .fill(Color(hex: "#918DE2"))
            .frame(width: 120, height: 110)
            .rotationEffect(.degrees(8))
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
            .overlay {
                
                Image(systemName: "checkmark")
                    .font(.system(size: 62, weight: .bold))
                    .foregroundColor(Color(hex: "#341D71"))
            }
    }
    
    private var grayFireShape: some View {
        RoundedRectangle(cornerRadius: 50)
            .fill(Color(hex: "#DBDCE5"))
            .frame(width: 111, height: 96)
            .rotationEffect(.degrees(-4))
            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
            .overlay {
                
                Image(systemName: "flame")
                    .font(.system(size: 48))
                    .foregroundColor(.black)
            }
    }
}

// MARK: - PREVIEW

#Preview {
    IntroView()
}
