import SwiftUI

public struct PhoneNumberView: View {
    @Environment(\.yoruTheme) private var theme
    @Bindable var viewModel: AuthViewModel

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    MangaGraphicView(kanji: "認", icon: "phone.fill")
                        .padding(.top, 40)

                    Text("TELEGRAM AUTHENTICATION")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Text("Please confirm your country code and enter your phone number to sign in to the Telegram network.")
                        .font(.yoruBody)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // Phone Input Card
                CyberCard(cornerCut: 14) {
                    VStack(spacing: 16) {
                        YoruTextField(
                            "Phone Number",
                            prompt: "+1 (555) 000-0000",
                            text: $viewModel.phoneNumber,
                            icon: "antenna.radiowaves.left.and.right",
                            keyboardType: .phonePad
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
                        "REQUEST LOGIN CODE",
                        kanji: "確認コード送信",
                        icon: "arrow.right",
                        style: .primary,
                        isLoading: viewModel.isLoading
                    ) {
                        viewModel.submitPhoneNumber()
                    }

                    Text("Yoru connects directly to official Telegram servers via TDLib. Your credentials are never stored externally.")
                        .font(.yoruCaption)
                        .foregroundColor(theme.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
