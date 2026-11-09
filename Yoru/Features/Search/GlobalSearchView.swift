import SwiftUI

public struct GlobalSearchView: View {
    @Environment(\.yoruTheme) private var theme
    @State private var viewModel = SearchViewModel()
    private let onSelectChat: (TelegramChat) -> Void

    public init(onSelectChat: @escaping (TelegramChat) -> Void) {
        self.onSelectChat = onSelectChat
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
                            Text("GLOBAL SEARCH")
                                .font(.yoruTitle)
                                .foregroundColor(theme.textPrimary)
                            Text("検索")
                                .font(.yoruKanjiAccent)
                                .foregroundColor(theme.accentSecondary.opacity(0.8))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.textTertiary)
                    TextField("", text: $viewModel.query, prompt: Text("Search across Telegram network...").foregroundColor(theme.textTertiary))
                        .font(.yoruBody)
                        .foregroundColor(theme.textPrimary)
                        .onSubmit {
                            viewModel.executeSearch()
                        }
                        .onChange(of: viewModel.query) {
                            viewModel.executeSearch()
                        }

                    if !viewModel.query.isEmpty {
                        Button(action: {
                            viewModel.query = ""
                            viewModel.results = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(theme.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(theme.glassSurface.opacity(0.75))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)

                // Results or Empty State
                if viewModel.query.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "Neural Directory",
                        subtitle: "Search public channels, supergroups, bots, and contacts across Telegram.",
                        kanji: "探",
                        systemIcon: "magnifyingglass.circle.fill"
                    )
                    Spacer()
                } else if viewModel.results.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "No Signals Found",
                        subtitle: "No matches located in the Telegram spectrum for '\(viewModel.query)'.",
                        kanji: "無",
                        systemIcon: "antenna.radiowaves.left.and.right.slash"
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.results) { chat in
                            Button(action: { onSelectChat(chat) }) {
                                ChatRowView(chat: chat)
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
}
