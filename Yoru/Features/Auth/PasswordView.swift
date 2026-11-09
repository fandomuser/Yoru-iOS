import SwiftUI

public struct PasswordView: View {
    @Environment(\.yoruTheme) private var theme
    @Bindable var viewModel: AuthViewModel
    let hint: String?

    public init(viewModel: AuthViewModel, hint: String? = nil) {
        self.viewModel = viewModel
        self.hint = hint
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    MangaGraphicView(kanji: "密", icon: "lock.fill")
                        .padding(.top, 40)

                    Text("TWO-STEP VERIFICATION")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Text("Your Telegram account is protected with a cloud password.")
                        .font(.yoruBody)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    if let hint = hint, !hint.isEmpty {
                        Text("Password Hint: \(hint)")
                            .font(.yoruCaption)
                            .foregroundColor(theme.accentSecondary)
                    }
                }

                // Password Input Card
                CyberCard(cornerCut: 14) {
                    VStack(spacing: 16) {
                        YoruTextField(
                            "Cloud Password",
                            prompt: "Enter your 2FA password",
                            text: $viewModel.password,
                            icon: "shield.lefthalf.filled",
                            isSecure: true
                        )

                        if let error = viewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 13))
                                Text(error)
                                    .font(.yoruCaption)
                            }
                            .foregroundColor(theme.destructive)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Submit Button
                VStack(spacing: 12) {
                    YoruButton(
                        "UNLOCK ACCOUNT",
                        kanji: "アカウント解除",
                        icon: "lock.open.fill",
                        style: .primary,
                        isLoading: viewModel.isLoading
                    ) {
                        viewModel.submitPassword()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
