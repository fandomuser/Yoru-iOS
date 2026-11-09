import SwiftUI

public struct ProfileCard: View {
    @Environment(\.yoruTheme) private var theme
    private let user: TelegramUser

    public init(user: TelegramUser) {
        self.user = user
    }

    private var labs: YoruLabsManager {
        YoruLabsManager.shared
    }

    public var body: some View {
        CyberCard(cornerCut: 16) {
            VStack(alignment: .leading, spacing: 14) {
                // Header with ID tag
                HStack {
                    CyberTag("SYS-ID: \(user.id)", kanji: "身元")
                    Spacer()
                    if user.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                            Text("PREMIUM")
                                .font(.yoruCyberBadge)
                        }
                        .foregroundColor(Color(hex: "#FFD700"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#FFD700").opacity(0.15))
                        .clipShape(Capsule())
                    }
                }

                // Avatar + Name
                HStack(spacing: 16) {
                    YoruAvatarView(
                        name: user.fullName,
                        avatarUrl: user.avatarUrl,
                        size: 64,
                        isOnline: true
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(user.fullName)
                                .font(.yoruTitle)
                                .foregroundColor(theme.textPrimary)

                            if user.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(theme.accentSecondary)
                            }
                        }

                        if let username = user.username {
                            Text(labs.maskIfStreamer("@\(username)", type: .username))
                                .font(.yoruSubheadline)
                                .foregroundColor(theme.accentPrimary)
                        }

                        Text(labs.maskIfStreamer(user.phoneNumber, type: .phoneNumber))
                            .font(.yoruCaption)
                            .foregroundColor(theme.textTertiary)
                    }
                }

                // Bio
                if let bio = user.bio, !bio.isEmpty {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    Text(bio)
                        .font(.yoruBody)
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(3)
                }
            }
        }
    }
}
