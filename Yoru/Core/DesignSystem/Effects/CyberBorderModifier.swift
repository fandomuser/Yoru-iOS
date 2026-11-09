import SwiftUI

public struct CyberCutoutShape: Shape {
    public let cornerCut: CGFloat

    public init(cornerCut: CGFloat = 12) {
        self.cornerCut = cornerCut
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let c = min(cornerCut, min(w / 3, h / 3))

        // Top-left angled cutout, then straight clockwise
        path.move(to: CGPoint(x: c, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h - c))
        path.addLine(to: CGPoint(x: w - c, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: c))
        path.closeSubpath()

        return path
    }
}

public struct CyberBorderModifier: ViewModifier {
    public let cornerCut: CGFloat
    public let strokeColor: Color
    public let lineWidth: CGFloat

    public init(cornerCut: CGFloat = 12, strokeColor: Color = Color.cyan, lineWidth: CGFloat = 1.5) {
        self.cornerCut = cornerCut
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }

    public func body(content: Content) -> some View {
        content
            .clipShape(CyberCutoutShape(cornerCut: cornerCut))
            .overlay(
                CyberCutoutShape(cornerCut: cornerCut)
                    .stroke(strokeColor, lineWidth: lineWidth)
            )
    }
}

public extension View {
    public func yoruCyberBorder(cornerCut: CGFloat = 12, strokeColor: Color = Color.cyan, lineWidth: CGFloat = 1.5) -> some View {
        modifier(CyberBorderModifier(cornerCut: cornerCut, strokeColor: strokeColor, lineWidth: lineWidth))
    }
}
