import SwiftUI

public struct AppearanceCustomizationView: View {
    @Environment(\.yoruTheme) private var theme
    private let labs = YoruLabsManager.shared
    private let onBack: () -> Void

    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.accentSecondary)
                    }

                    Text("APPEARANCE LABS")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("GEOMETRY", kanji: "外観")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Avatar Shape Picker
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("AVATAR GEOMETRY")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                HStack(spacing: 14) {
                                    ForEach(AvatarShape.allCases) { shape in
                                        let isSelected = labs.currentSettings.appearance.avatarShape == shape
                                        Button(action: {
                                            labs.updateSettings { $0.appearance.avatarShape = shape }
                                        }) {
                                            VStack(spacing: 6) {
                                                YoruAvatarView(
                                                    name: "Ren A",
                                                    size: 46,
                                                    isOnline: true,
                                                    customShape: shape
                                                )

                                                Text(shape.rawValue.capitalized)
                                                    .font(.system(size: 11, weight: isSelected ? .bold : .regular))
                                                    .foregroundColor(isSelected ? theme.accentPrimary : theme.textSecondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(isSelected ? theme.accentPrimary.opacity(0.15) : Color.clear)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(isSelected ? theme.accentPrimary : Color.clear, lineWidth: 1.5)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Bubble Corner Radius Slider
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("MESSAGE BUBBLE CORNER RADIUS")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                    Spacer()
                                    Text("\(Int(labs.currentSettings.appearance.bubbleCornerRadius)) pt")
                                        .font(.yoruCaption)
                                        .foregroundColor(theme.textPrimary)
                                }

                                Slider(
                                    value: Binding(
                                        get: { labs.currentSettings.appearance.bubbleCornerRadius },
                                        set: { val in labs.updateSettings { $0.appearance.bubbleCornerRadius = val } }
                                    ),
                                    in: 4...28,
                                    step: 1
                                )
                                .tint(theme.accentPrimary)

                                // Mini Live Bubble Preview
                                HStack {
                                    Spacer()
                                    Text("Sample Cyber Transmission Bubble")
                                        .font(.yoruCaption)
                                        .foregroundColor(theme.bubbleOutgoingText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(theme.bubbleOutgoing)
                                        .clipShape(RoundedRectangle(cornerRadius: CGFloat(labs.currentSettings.appearance.bubbleCornerRadius)))
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Hidden UI Elements
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("STREAMER PRIVACY & HIDDEN UI")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                Toggle("Hide Phone Numbers Everywhere", isOn: Binding(
                                    get: { labs.currentSettings.appearance.hidePhoneNumber },
                                    set: { val in labs.updateSettings { $0.appearance.hidePhoneNumber = val } }
                                ))
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle("Hide Usernames in Headers", isOn: Binding(
                                    get: { labs.currentSettings.appearance.hideUsernames },
                                    set: { val in labs.updateSettings { $0.appearance.hideUsernames = val } }
                                ))
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle("Hide Quick Reaction Floating Bar", isOn: Binding(
                                    get: { labs.currentSettings.appearance.hideQuickReactionsBar },
                                    set: { val in labs.updateSettings { $0.appearance.hideQuickReactionsBar = val } }
                                ))
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
