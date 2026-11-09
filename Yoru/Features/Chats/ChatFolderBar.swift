import SwiftUI

public struct ChatFolderBar: View {
    @Environment(\.yoruTheme) private var theme
    let folders: [ChatFolder]
    @Binding var selectedFolderId: Int32

    public init(folders: [ChatFolder], selectedFolderId: Binding<Int32>) {
        self.folders = folders
        self._selectedFolderId = selectedFolderId
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(folders) { folder in
                    let isSelected = selectedFolderId == folder.id

                    Button(action: {
                        withAnimation(.snappy) {
                            selectedFolderId = folder.id
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: folder.iconName)
                                .font(.system(size: 13, weight: .semibold))
                            Text(folder.title)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                        }
                        .foregroundColor(isSelected ? theme.textInverse : theme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isSelected ? theme.accentPrimary : theme.glassSurface.opacity(0.8))
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                        .yoruNeonGlow(color: theme.neonGlow, radius: 4, isActive: isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
}
