//
//  AuthView.swift
//  firebasetrial
//
//  Created by Danyah ALbarqawi on 10/05/2026.
//

//
//  SignInView.swift
//  firebasetrial

//
//  SignInView.swift
//  firebasetrial

//
//  SignInView.swift
//  firebasetrial

import SwiftUI
import AuthenticationServices
import UIKit

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    var onBack: () -> Void = {}

    @State private var appleSignInCoordinator: AppleSignInCoordinator? = nil
    @State private var showPrivacySheet = false

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {

                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(isDark ? .white : .black)
                    }

                    Spacer()
                }
                .padding(.horizontal, 29)
                .padding(.top, 4)

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text(NSLocalizedString("welcome", comment: ""))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(isDark ? .white : .black)

                    Text(NSLocalizedString("ready_for_today_challenge", comment: ""))
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(isDark ? .white.opacity(0.56) : Color(hex: "#3A3A3A"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 36)
                .offset(y: -12)

                Spacer()

                VStack(spacing: 22) {
                    Button(action: handleAppleSignInTap) {
                        HStack(spacing: 8) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 17, weight: .bold))

                            Text(NSLocalizedString("sign_in_with_apple", comment: ""))
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(isDark ? .white : .black)
                        .frame(width: 330, height: 55)
                        .background(isDark ? Color.black : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(isDark ? Color(hex: "#2A2525") : Color(hex: "#D3D1D1"), lineWidth: 1)
                        )
                        .shadow(
                            color: Color.black.opacity(isDark ? 0.25 : 0.20),
                            radius: 4,
                            x: 0,
                            y: 4
                        )
                    }
                    .buttonStyle(.plain)

                    VStack(spacing: 8) {
                        Text(NSLocalizedString("terms_privacy_note", comment: ""))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(isDark ? .white.opacity(0.60) : Color.black.opacity(0.60))
                            .multilineTextAlignment(.center)

                        Button {
                            showPrivacySheet = true
                        } label: {
                            Text("سياسة الخصوصية")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isDark ? Color(hex: "#D8CCFF") : Color(hex: "#341D71"))
                                .underline()
                        }
                    }
                }
                .padding(.bottom, 46)
            }

            if let msg = authVM.errorMessage {
                VStack {
                    Spacer()

                    Text(msg)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.ticku.errorRed.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
                        .onTapGesture {
                            authVM.errorMessage = nil
                        }
                }
            }

            if authVM.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.4)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyPolicySheet()
        }
        .onChange(of: authVM.isAuthenticated) {
            if authVM.isAuthenticated {
                onBack()
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isDark {
            LinearGradient(
                colors: [
                    Color(hex: "#604D93"),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [
                    Color(hex: "#9B84E7"),
                    Color(hex: "#DED8F5"),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private func handleAppleSignInTap() {
        let hashedNonce = authVM.prepareNonce()

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce

        let controller = ASAuthorizationController(authorizationRequests: [request])

        let delegate = AppleSignInCoordinator { result in
            Task {
                await authVM.handleAppleSignIn(result: result)
            }
        }

        appleSignInCoordinator = delegate
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
    }
}

private struct PrivacyPolicySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    private var isDark: Bool { colorScheme == .dark }

    private let cardColor = Color(hex: "#9A86D0")

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("سياسة الخصوصية")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(isDark ? .white : .black)
                        .padding(.bottom, 4)

                    Text("آخر تحديث: يوليو 2026")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isDark ? .white.opacity(0.55) : .black.opacity(0.45))
                        .padding(.bottom, 10)

                    privacyCard(title: "مقدمة", text: """
مرحبًا بك في Ticku.

نحن نُقدّر خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة المعلومات التي يجمعها التطبيق، وكيفية استخدامها، والوسائل التي نتبعها لحمايتها عند استخدامك للتطبيق.
""")

                    privacyCard(title: "المعلومات التي نجمعها", text: """
قد نقوم بجمع الاسم المعروض، البريد الإلكتروني عند تسجيل الدخول، الصورة الشخصية إذا قمت بإضافتها، معرف المستخدم، التحديات التي تنشئها أو تنضم إليها، المهام، ونسبة الإنجاز وعدد مرات الفوز.
""")

                    privacyCard(title: "معلومات لا نجمعها", text: """
لا يجمع Ticku الهوية الوطنية، المعلومات البنكية، البيانات الصحية، جهات الاتصال، الموقع الجغرافي، تسجيلات الصوت، أو الصور الموجودة في جهازك دون اختيارك.
""")

                    privacyCard(title: "كيفية استخدام البيانات", text: """
نستخدم البيانات لإنشاء الحساب، حفظ التحديات والمهام، مزامنة البيانات، عرض التقدم، حساب الإحصائيات، إرسال إشعارات مرتبطة بالتحديات، وتحسين أداء التطبيق وأمانه.
""")

                    privacyCard(title: "مشاركة البيانات", text: """
قد تظهر بعض بياناتك للمستخدمين المشاركين معك في نفس التحدي، مثل الاسم، الصورة الشخصية، التقدم، والمهام المكتملة حسب آلية التحدي. لا نبيع بياناتك ولا نشاركها لأغراض إعلانية.
""")

                    privacyCard(title: "تخزين البيانات وأمانها", text: """
يتم تخزين البيانات باستخدام خدمات سحابية موثوقة مثل Firebase، مع استخدام وسائل حماية مناسبة للحد من الوصول غير المصرح به أو الفقد أو التعديل.
""")

                    privacyCard(title: "حذف الحساب والبيانات", text: """
يمكنك التوقف عن استخدام التطبيق في أي وقت. وعند توفر حذف الحساب، سيتم حذف البيانات المرتبطة بحسابك وفقًا لسياسة الاحتفاظ بالبيانات، ما لم يكن الاحتفاظ ببعض المعلومات مطلوبًا نظاميًا أو أمنيًا.
""")

                    privacyCard(title: "الالتزام بالأنظمة", text: """
يلتزم Ticku باحترام الأنظمة واللوائح المتعلقة بحماية البيانات والخصوصية. ولا يتم الكشف عن أي معلومات إلا إذا كان ذلك مطلوبًا بموجب أمر قضائي أو طلب رسمي من جهة مختصة، وبالحد الأدنى اللازم فقط.
""")

                    privacyCard(title: "التواصل معنا", text: """
إذا كانت لديك أي استفسارات حول سياسة الخصوصية أو بياناتك، يمكنك التواصل مع فريق Ticku من خلال وسائل التواصل المتوفرة داخل التطبيق أو صفحة التطبيق في App Store.
""")
                }
                .padding(22)
            }
            .background(isDark ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("تم") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#9A86D0"))
                }
            }
        }
    }

    private func privacyCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.white)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.88))
                .lineSpacing(5)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let onComplete: (Result<ASAuthorization, Error>) -> Void

    init(onComplete: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.onComplete = onComplete
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        onComplete(.success(authorization))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        onComplete(.failure(error))
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first ?? ASPresentationAnchor()
    }
}

#Preview("Light") {
    SignInView()
        .environmentObject(AuthViewModel())
}

#Preview("Dark") {
    SignInView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
