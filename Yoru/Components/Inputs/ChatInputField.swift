import SwiftUI

public struct ChatInputField: View {
    @Environment(\.yoruTheme) private var theme
    @Binding private var text: String
    private let onSend: () -> Void
    private let onAttachmentTap: () -> Void
    private let onVoiceRecordTap: () -> Void

    public init(
        text: Binding<String>,
        onSend: @escaping () -> Void,
        onAttachmentTap: @escaping () -> Void,
        onVoiceRecordTap: @escaping () -> Void
    ) {
        self._text = text
        self.onSend = onSend
        self.onAttachmentTap = onAttachmentTap
        self.onVoiceRecordTap = onVoiceRecordTap
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Attachment Button
            Button(action: onAttachmentTap) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(theme.accentSecondary)
            }
            .frame(width: 38, height: 38)

            // Text Input Box
            HStack(alignment: .center, spacing: 8) {
                TextField("", text: $text, prompt: Text("Transmit message...").foregroundColor(theme.textTertiary), axis: .vertical)
                    .lineLimit(1...5)
                    .font(.yoruBody)
                    .foregroundColor(theme.textPrimary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)

                Button(action: {
                    // Emoji / Sticker panel toggle
                }) {
                    Image(systemName: "face.smiling.inverse")
                        .font(.system(size: 20))
                        .foregroundColor(theme.textSecondary)
                }
                .padding(.trailing, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(theme.backgroundElevated.opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )

            // Dynamic Action Button (Send or Voice)
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: onVoiceRecordTap) {
                    ZStack {
                        Circle()
                            .fill(theme.glassSurface)
                            .frame(width: 38, height: 38)
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                        Image(systemName: "mic.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(theme.accentPrimary)
                    }
                }
            } else {
                Button(action: onSend) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [theme.accentPrimary, theme.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 38, height: 38)
                            .yoruNeonGlow(color: theme.neonGlow, radius: 6)

                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.textInverse)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            theme.backgroundSecondary.opacity(0.92)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
        .animation(.snappy, value: text.isEmpty)
    }
}
