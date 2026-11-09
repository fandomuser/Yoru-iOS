import SwiftUI

public struct AuthCodeView: View {
    @Environment(\.yoruTheme) private var theme
    @Bindable var viewModel: AuthViewModel
    let codeType: AuthCodeType
    let timeout: Int

    public init(viewModel: AuthViewModel, codeType: AuthCodeType, timeout: Int) {
        self.viewModel = viewModel
        self.codeType = codeType
        self.timeout = timeout
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    MangaGraphicView(kanji: "暗", icon: "lock.shield.fill")
                        .padding(.top, 40)

                    Text("ENTER VERIFICATION CODE")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Text("We've sent an encrypted authentication code to your \(codeType.title).")
                        .font(.yoruBody)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // Code Input Card
                CyberCard(cornerCut: 14) {
                    VStack(spacing: 16) {
                        YoruTextField(
                            "Verification Code",
                            prompt: "12345",
                            text: $viewModel.authCode,
                            icon: "key.fill",
                            keyboardType: .numberPad
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
                        "CONFIRM CODE",
                        kanji: "検証完了",
                        icon: "checkmark.circle.fill",
                        style: .primary,
                        isLoading: viewModel.isLoading
                    ) {
                        viewModel.submitAuthCode()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
