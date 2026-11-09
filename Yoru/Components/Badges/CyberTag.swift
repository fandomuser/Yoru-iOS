import SwiftUI

public struct CyberTag: View {
    @Environment(\.yoruTheme) private var theme
    private let text: String
    private let kanji: String?

    public init(_ text: String, kanji: String? = nil) {
        self.text = text
        self.kanji = kanji
    }

    public var body: some View {
        HStack(spacing: 4) {
            Text(text.uppercased())
                .font(.yoruCyberBadge)
            if let kanji = kanji {
                Text(kanji)
                    .font(.system(size: 9, weight: .bold))
            }
        }
        .foregroundColor(theme.accentSecondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(theme.accentSecondary.opacity(0.12))
        .clipShape(CyberCutoutShape(cornerCut: 4))
        .overlay(
            CyberCutoutShape(cornerCut: 4)
                .stroke(theme.accentSecondary.opacity(0.4), lineWidth: 0.8)
        )
    }
}
