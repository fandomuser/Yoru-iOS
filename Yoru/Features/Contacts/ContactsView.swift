import SwiftUI

public struct ContactsView: View {
    @Environment(\.yoruTheme) private var theme
    @State private var viewModel = ContactsViewModel()
    private let onSelectUser: (TelegramUser) -> Void

    public init(onSelectUser: @escaping (TelegramUser) -> Void) {
        self.onSelectUser = onSelectUser
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("CONTACTS")
                                .font(.yoruTitle)
                                .foregroundColor(theme.textPrimary)
                            Text("連絡先")
                                .font(.yoruKanjiAccent)
                                .foregroundColor(theme.accentSecondary.opacity(0.8))
                        }
                    }
                    Spacer()

                    CyberIconButton(icon: "person.badge.plus", size: 38) {
                        // Add contact
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.textTertiary)
                    TextField("", text: $viewModel.searchText, prompt: Text("Search contacts...").foregroundColor(theme.textTertiary))
                        .font(.yoruBody)
                        .foregroundColor(theme.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(theme.glassSurface.opacity(0.75))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)

                // Contacts List
                List {
                    ForEach(viewModel.filteredContacts) { user in
                        Button(action: { onSelectUser(user) }) {
                            HStack(spacing: 14) {
                                YoruAvatarView(name: user.fullName, size: 48, isOnline: true)

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(user.fullName)
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)

                                        if user.isPremium {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(Color(hex: "#FFD700"))
                                        }
                                    }

                                    if let username = user.username {
                                        Text("@\(username)")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.accentPrimary)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(theme.textTertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
