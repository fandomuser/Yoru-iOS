import SwiftUI

public extension Font {
    // Japanese / Cyber Anime Typography Tokens
    public static var yoruLargeTitle: Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }

    public static var yoruTitle: Font {
        .system(size: 24, weight: .bold, design: .rounded)
    }

    public static var yoruHeadline: Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }

    public static var yoruSubheadline: Font {
        .system(size: 15, weight: .medium, design: .default)
    }

    public static var yoruBody: Font {
        .system(size: 16, weight: .regular, design: .default)
    }

    public static var yoruCaption: Font {
        .system(size: 12, weight: .medium, design: .monospaced)
    }

    public static var yoruCyberBadge: Font {
        .system(size: 10, weight: .black, design: .monospaced)
    }

    public static var yoruKanjiAccent: Font {
        .system(size: 20, weight: .heavy, design: .serif)
    }
}
