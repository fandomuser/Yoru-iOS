import SwiftUI

public enum YoruTab: String, CaseIterable, Identifiable {
    case chats = "Chats"
    case contacts = "Contacts"
    case search = "Search"
    case settings = "Settings"

    public var id: String { rawValue }

    public var systemIcon: String {
        switch self {
        case .chats: return "bubble.left.and.bubble.right.fill"
        case .contacts: return "person.2.fill"
        case .search: return "magnifyingglass"
        case .settings: return "slider.horizontal.3"
        }
    }

    public var kanji: String {
        switch self {
        case .chats: return "談"
        case .contacts: return "友"
        case .search: return "索"
        case .settings: return "設"
        }
    }
}

public struct CustomTabBar: View {
    @Environment(\.yoruTheme) private var theme
    @Binding var selectedTab: YoruTab
    let unreadCount: Int32

    public init(selectedTab: Binding<YoruTab>, unreadCount: Int32 = 0) {
        self._selectedTab = selectedTab
        self.unreadCount = unreadCount
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(YoruTab.allCases) { tab in
                let isSelected = selectedTab == tab

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.systemIcon)
                                .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? theme.accentPrimary : theme.textTertiary)

                            if tab == .chats && unreadCount > 0 {
                                UnreadBadge(count: unreadCount)
                                    .offset(x: 14, y: -10)
                            }
                        }
                        .frame(height: 24)

                        HStack(spacing: 2) {
                            Text(tab.rawValue)
                                .font(.system(size: 11, weight: isSelected ? .bold : .regular, design: .rounded))
                            Text(tab.kanji)
                                .font(.system(size: 8, weight: .heavy, design: .serif))
                                .opacity(isSelected ? 0.9 : 0.4)
                        }
                        .foregroundColor(isSelected ? theme.accentSecondary : theme.textTertiary)

                        // Cyber active pill indicator
                        Capsule()
                            .fill(isSelected ? theme.accentPrimary : Color.clear)
                            .frame(width: isSelected ? 20 : 0, height: 3)
                            .yoruNeonGlow(color: theme.neonGlow, radius: 4, isActive: isSelected)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(
            theme.backgroundSecondary.opacity(0.85)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                theme.accentPrimary.opacity(0.3),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
        )
    }
}
