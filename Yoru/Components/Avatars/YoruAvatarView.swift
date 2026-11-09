import SwiftUI

public struct HexagonShape: Shape {
    public init() {}
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let side = min(w, h)
        let cx = w / 2
        let cy = h / 2
        let r = side / 2

        for i in 0..<6 {
            let angle = CGFloat(i) * CGFloat.pi / 3 - CGFloat.pi / 6
            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

public struct YoruAvatarView: View {
    @Environment(\.yoruTheme) private var theme
    private let name: String
    private let avatarUrl: String?
    private let size: CGFloat
    private let isOnline: Bool
    private let showBorder: Bool
    private let customShape: AvatarShape?

    public init(
        name: String,
        avatarUrl: String? = nil,
        size: CGFloat = 50,
        isOnline: Bool = false,
        showBorder: Bool = true,
        customShape: AvatarShape? = nil
    ) {
        self.name = name
        self.avatarUrl = avatarUrl
        self.size = size
        self.isOnline = isOnline
        self.showBorder = showBorder
        self.customShape = customShape
    }

    private var activeShape: AvatarShape {
        customShape ?? YoruLabsManager.shared.currentSettings.appearance.avatarShape
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarContainer
                .frame(width: size, height: size)

            if isOnline {
                OnlineStatusBadge(isOnline: true)
                    .offset(x: 1, y: 1)
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var avatarContainer: some View {
        let gradient = LinearGradient(
            colors: [
                theme.accentPrimary.opacity(0.85),
                theme.accentSecondary.opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        switch activeShape {
        case .circle:
            Circle()
                .fill(gradient)
                .overlay(initialsView)
                .overlay(Circle().stroke(showBorder ? theme.accentPrimary.opacity(0.6) : Color.clear, lineWidth: 1.5))

        case .squircle:
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(gradient)
                .overlay(initialsView)
                .overlay(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous).stroke(showBorder ? theme.accentPrimary.opacity(0.6) : Color.clear, lineWidth: 1.5))

        case .hexagon:
            HexagonShape()
                .fill(gradient)
                .overlay(initialsView)
                .overlay(HexagonShape().stroke(showBorder ? theme.accentPrimary.opacity(0.6) : Color.clear, lineWidth: 1.5))

        case .cyberCut:
            CyberCutoutShape(cornerCut: size * 0.2)
                .fill(gradient)
                .overlay(initialsView)
                .overlay(CyberCutoutShape(cornerCut: size * 0.2).stroke(showBorder ? theme.accentPrimary.opacity(0.6) : Color.clear, lineWidth: 1.5))
        }
    }

    private var initialsView: some View {
        Text(initials)
            .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
            .foregroundColor(theme.textInverse)
    }

    private var initials: String {
        let parts = name.split(separator: " ")
        if let first = parts.first?.prefix(1) {
            if parts.count > 1, let last = parts.last?.prefix(1) {
                return "\(first)\(last)".uppercased()
            }
            return String(first).uppercased()
        }
        return "Y"
    }
}
