import SwiftUI

public struct UserProfileView: View {
    @Environment(\.yoruTheme) private var theme
    @State private var viewModel: ProfileViewModel
    private let onDismiss: () -> Void

    public init(user: TelegramUser = MockDataGenerator.currentUser, onDismiss: @escaping () -> Void) {
        _viewModel = State(initialValue: ProfileViewModel(user: user))
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.accentSecondary)
                            .frame(width: 36, height: 36)
                            .background(theme.glassSurface.opacity(0.8))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("PROFILE DOSSIER")
                        .font(.yoruCyberBadge)
                        .foregroundColor(theme.accentSecondary)

                    Spacer()

                    CyberIconButton(icon: "square.and.arrow.up", size: 36) {
                        // Share profile
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 20) {
                        // Cyber Card
                        ProfileCard(user: viewModel.user)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)

                        // Quick Actions Row
                        HStack(spacing: 12) {
                            actionButton(icon: "message.fill", title: "Message") {}
                            actionButton(icon: "bell.fill", title: "Mute") {
                                viewModel.isMuted.toggle()
                            }
                            actionButton(icon: "slash.circle", title: "Block", isDestructive: true) {}
                        }
                        .padding(.horizontal, 16)

                        // Media / Shared content tabs
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("TRANSMISSION ARCHIVES")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                HStack(spacing: 12) {
                                    statBadge(count: "24", title: "Media")
                                    statBadge(count: "8", title: "Voice")
                                    statBadge(count: "15", title: "Files")
                                    statBadge(count: "103", title: "Links")
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }

    private func actionButton(icon: String, title: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundColor(isDestructive ? theme.destructive : theme.accentPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(theme.glassSurface.opacity(0.75))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }

    private func statBadge(count: String, title: String) -> some View {
        VStack(spacing: 2) {
            Text(count)
                .font(.yoruHeadline)
                .foregroundColor(theme.textPrimary)
            Text(title)
                .font(.yoruCaption)
                .foregroundColor(theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(theme.backgroundElevated.opacity(0.5))
        .cornerRadius(8)
    }
}
