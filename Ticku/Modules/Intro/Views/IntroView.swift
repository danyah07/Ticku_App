//
//  IntroView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

import SwiftUI

struct IntroView: View {

    var onFinish: () -> Void = {}

    @StateObject private var viewModel = IntroViewModels()
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    private var backgroundColor: Color { isDark ? .black : .white }
    private var mainTextColor: Color { isDark ? .white : .black }
    private var descriptionTextColor: Color { isDark ? .white.opacity(0.9) : .black.opacity(0.8) }

    private var circleFillColor: Color {
        isDark
            ? Color(red: 36/255, green: 36/255, blue: 36/255)
            : Color(red: 242/255, green: 242/255, blue: 247/255)
    }

    private var avatarColor: Color {
        isDark ? .white.opacity(0.85) : Color(red: 217/255, green: 217/255, blue: 217/255)
    }

    private var purpleDark: Color  { Color(red: 52/255,  green: 29/255,  blue: 113/255) }
    private var blueCircle: Color  { Color(red: 170/255, green: 209/255, blue: 252/255) }
    private var purpleCircle: Color{ Color(red: 145/255, green: 141/255, blue: 226/255) }
    private var grayCircle: Color  { Color(red: 219/255, green: 220/255, blue: 229/255) }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            TabView(selection: $viewModel.currentPage) {
                pageOne.tag(0)
                pageTwo.tag(1)
                pageThree.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if viewModel.currentPage != 2 { topSkip }
            bottomControls
        }
    }
}

// MARK: - PAGES
extension IntroView {

    private var pageOne: some View {
        VStack {
            Spacer().frame(height: 170)
            circlesPageOne.environment(\.layoutDirection, .leftToRight)
            Spacer().frame(height: 70)
            VStack(spacing: 19) {
                Text("intro_challenge_title".localized)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(mainTextColor)
                Text("intro_challenge_desc".localized)
                    .font(.system(size: 16))
                    .foregroundColor(descriptionTextColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }
            Spacer()
        }
    }

    private var pageTwo: some View {
        VStack {
            Spacer().frame(height: 250)
            friendsCircles.environment(\.layoutDirection, .leftToRight)
            Spacer().frame(height: 90)
            VStack(spacing: 19) {
                Text("intro_friends_title".localized)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(mainTextColor)
                Text("intro_friends_desc".localized)
                    .font(.system(size: 14))
                    .foregroundColor(descriptionTextColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 330)
            }
            Spacer()
        }
    }

    private var pageThree: some View {
        VStack {
            Spacer().frame(height: 195)
            streakIcons.scaleEffect(0.95).environment(\.layoutDirection, .leftToRight)
            Spacer().frame(height: 115)
            VStack(spacing: 19) {
                Text("intro_stay_title".localized)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(mainTextColor)
                Text("intro_stay_desc".localized)
                    .font(.system(size: 14))
                    .foregroundColor(descriptionTextColor)
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
                    withAnimation { viewModel.currentPage = 2 }
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
                    if viewModel.currentPage == 2 {
                        Button {
                            withAnimation { viewModel.currentPage -= 1 }
                        } label: {
                            Image(systemName: Locale.current.language.languageCode?.identifier == "ar"
                                  ? "chevron.right" : "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(mainTextColor)
                        }
                    }
                    Spacer()
                    if viewModel.currentPage != 2 {
                        Button {
                            withAnimation { viewModel.currentPage += 1 }
                        } label: {
                            Image(systemName: Locale.current.language.languageCode?.identifier == "ar"
                                  ? "chevron.left" : "chevron.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(mainTextColor)
                        }
                    } else {
                        // ✅ Get Started — marks intro as seen and transitions to app
                        Button {
                            onFinish()
                        } label: {
                            ZStack {
                                Capsule()
                                    .fill(isDark
                                          ? Color(red: 142/255, green: 138/255, blue: 197/255)
                                          : Color(red: 52/255,  green: 29/255,  blue: 113/255))
                                Text("intro_start".localized)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 125, height: 50)
                            .shadow(color: Color("Start").opacity(0.35), radius: 8, x: 0, y: 5)
                        }
                        .buttonStyle(.plain)
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
                    .fill(viewModel.currentPage == index
                          ? mainTextColor : Color.gray.opacity(0.35))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - PAGE 1 CIRCLES
extension IntroView {

    private var circlesPageOne: some View {
        ZStack {
            userCircleTop.offset(x: -78, y: -42)
            userCircleBottom.offset(x: 70, y: 50)
            checkIconSmall.offset(x: -38, y: -152)
            checkIconBig.offset(x: 60, y: -79)
            checkIconBig.offset(x: -45, y: 80)
        }
        .frame(width: 360, height: 330)
    }

    private var userCircleTop: some View {
        Circle()
            .fill(circleFillColor)
            .overlay(Circle().stroke(Color("Circle"), lineWidth: 5))
            .frame(width: 122, height: 119)
            .overlay {
                Text("%100")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(isDark ? .white : purpleDark)
            }
    }

    private var userCircleBottom: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.60)
                .stroke(Color("Circle"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 122, height: 119)
                .rotationEffect(.degrees(260))
                .offset(x: 1, y: -1)
            Circle()
                .fill(circleFillColor)
                .frame(width: 119, height: 126)
                .shadow(color: .black.opacity(0.19), radius: 4, x: -2, y: 3)
            Text("%60")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundColor(isDark ? .white : purpleDark)
        }
        .frame(width: 185, height: 185)
    }

    private var checkIconBig: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 58, weight: .bold))
            .foregroundColor(Color("Check"))
    }

    private var checkIconSmall: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(Color("Check"))
    }
}

// MARK: - PAGE 2 CIRCLES
extension IntroView {

    private var friendsCircles: some View {
        ZStack {
            userAvatarCircle.offset(x: -80, y: -45)
            userAvatarCircleShadow.offset(x: 69, y: -68)
            userAvatarCircleBottom.offset(x: 22, y: 72)
        }
        .scaleEffect(0.82)
        .frame(width: 240, height: 230)
    }

    private var userAvatarCircle: some View {
        Circle()
            .fill(circleFillColor)
            .overlay(Circle().stroke(Color("Circle"), lineWidth: 6))
            .frame(width: 128, height: 128)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 58))
                    .foregroundColor(avatarColor)
            }
    }

    private var userAvatarCircleShadow: some View {
        Circle()
            .fill(circleFillColor)
            .frame(width: 128, height: 128)
            .shadow(color: .black.opacity(0.28), radius: 6, x: 0, y: 4)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 58))
                    .foregroundColor(avatarColor)
            }
    }

    private var userAvatarCircleBottom: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.80)
                .stroke(Color("Circle"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 128, height: 128)
                .rotationEffect(.degrees(260))
                .offset(x: 1, y: -1)
            Circle().fill(circleFillColor).frame(width: 120, height: 120)
            Image(systemName: "person.fill")
                .font(.system(size: 58))
                .foregroundColor(avatarColor)
        }
        .frame(width: 140, height: 140)
    }
}

// MARK: - PAGE 3 ICONS
extension IntroView {

    private var streakIcons: some View {
        ZStack {
            blueBoltShape.offset(x: -58, y: -42)
            purpleCheckShape.offset(x: 64, y: -22)
            grayFireShape.offset(x: -18, y: 70)
        }
        .frame(width: 280, height: 260)
    }

    private var blueBoltShape: some View {
        RoundedRectangle(cornerRadius: 52)
            .fill(blueCircle)
            .frame(width: 111, height: 96)
            .rotationEffect(.degrees(-10))
            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 4)
            .overlay { Image(systemName: "bolt.fill").font(.system(size: 58)).foregroundColor(.black) }
    }

    private var purpleCheckShape: some View {
        RoundedRectangle(cornerRadius: 55)
            .fill(purpleCircle)
            .frame(width: 120, height: 110)
            .rotationEffect(.degrees(8))
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
            .overlay {
                Image(systemName: "checkmark")
                    .font(.system(size: 62, weight: .bold))
                    .foregroundColor(purpleDark)
            }
    }

    private var grayFireShape: some View {
        RoundedRectangle(cornerRadius: 50)
            .fill(grayCircle)
            .frame(width: 111, height: 96)
            .rotationEffect(.degrees(-4))
            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
            .overlay { Image(systemName: "flame").font(.system(size: 48)).foregroundColor(.black) }
    }
}

// MARK: - PREVIEW
#Preview("Light") { IntroView().preferredColorScheme(.light) }
#Preview("Dark")  { IntroView().preferredColorScheme(.dark) }
