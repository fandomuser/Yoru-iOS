import SwiftUI

public struct ChatListView: View {
    @Environment(\.yoruTheme) private var theme
    @State private var viewModel = ChatListViewModel()
    private let onSelectChat: (TelegramChat) -> Void
    private let onProfileTap: () -> Void

    public init(
        onSelectChat: @escaping (TelegramChat) -> Void,
        onProfileTap: @escaping () -> Void
    ) {
        self.onSelectChat = onSelectChat
        self.onProfileTap = onProfileTap
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Custom Cyber Navigation Header
                HStack(spacing: 12) {
                    Button(action: onProfileTap) {
                        YoruAvatarView(
                            name: "Ren Amamiya",
                            size: 38,
                            isOnline: true
                        )
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("CHATS")
                                .font(.yoruTitle)
                                .foregroundColor(theme.textPrimary)
                            Text("会談")
                                .font(.yoruKanjiAccent)
                                .foregroundColor(theme.accentSecondary.opacity(0.8))
                        }
                    }

                    Spacer()

                    // New Chat Action
                    CyberIconButton(icon: "square.and.pencil", size: 38) {
                        // Compose new message
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.textTertiary)
                    TextField("", text: $viewModel.searchText, prompt: Text("Search transmissions...").foregroundColor(theme.textTertiary))
                        .font(.yoruBody)
                        .foregroundColor(theme.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(theme.glassSurface.opacity(0.75))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)

                // Chat Folder Filter Bar
                if !viewModel.folders.isEmpty {
                    ChatFolderBar(
                        folders: viewModel.folders,
                        selectedFolderId: $viewModel.selectedFolderId
                    )
                }

                // Chat List or Empty State
                if viewModel.chats.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "No Transmissions",
                        subtitle: "Your neural inbox is clear. Start a new chat to begin transmitting.",
                        kanji: "空",
                        systemIcon: "bubble.left.and.exclamationmark.bubble.right.fill"
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.chats) { chat in
                            Button(action: { onSelectChat(chat) }) {
                                ChatRowView(chat: chat)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
        }
    }
}
