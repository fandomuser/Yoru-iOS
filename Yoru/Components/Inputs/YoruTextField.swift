import SwiftUI

public struct YoruTextField: View {
    @Environment(\.yoruTheme) private var theme
    private let title: String
    private let prompt: String
    @Binding private var text: String
    private let icon: String?
    private let isSecure: Bool
    private let keyboardType: UIKeyboardType

    public init(
        _ title: String,
        prompt: String = "",
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.prompt = prompt
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.yoruCyberBadge)
                .foregroundColor(theme.accentSecondary)
                .tracking(1.2)

            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.accentPrimary)
                        .frame(width: 24)
                }

                if isSecure {
                    SecureField("", text: $text, prompt: Text(prompt).foregroundColor(theme.textTertiary))
                        .font(.yoruBody)
                        .foregroundColor(theme.textPrimary)
                } else {
                    TextField("", text: $text, prompt: Text(prompt).foregroundColor(theme.textTertiary))
                        .font(.yoruBody)
                        .foregroundColor(theme.textPrimary)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(theme.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.glassSurface.opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        text.isEmpty ? Color.white.opacity(0.1) : theme.accentPrimary.opacity(0.7),
                        lineWidth: text.isEmpty ? 1 : 1.5
                    )
            )
        }
    }
}
