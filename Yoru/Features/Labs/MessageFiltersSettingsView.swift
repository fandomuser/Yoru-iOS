import SwiftUI

public struct MessageFiltersSettingsView: View {
    @Environment(\.yoruTheme) private var theme
    private let labs = YoruLabsManager.shared
    private let onBack: () -> Void

    @State private var newKeyword: String = ""

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

                    Text("MESSAGE FILTERS")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("FIREWALL", kanji: "遮断")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Master Toggle
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(theme.accentSecondary)
                                    Text("CYBER MESSAGE FIREWALL")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                }

                                Text("Automatically detect and neutralize scam patterns, crypto giveaways, ad spam, and spoilers before they reach your eyes.")
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)

                                Toggle("Enable Message Filtering", isOn: Binding(
                                    get: { labs.currentSettings.filters.filterEnabled },
                                    set: { val in labs.updateSettings { $0.filters.filterEnabled = val } }
                                ))
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Action Selection
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("INTERCEPTION ACTION")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                Picker("Action", selection: Binding(
                                    get: { labs.currentSettings.filters.action },
                                    set: { val in labs.updateSettings { $0.filters.action = val } }
                                )) {
                                    ForEach(FilterAction.allCases) { action in
                                        Text(action.displayName).tag(action)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Blocked Keywords
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("BLOCKED KEYWORDS")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                HStack(spacing: 8) {
                                    TextField("", text: $newKeyword, prompt: Text("Add keyword...").foregroundColor(theme.textTertiary))
                                        .font(.yoruBody)
                                        .foregroundColor(theme.textPrimary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(theme.backgroundElevated)
                                        .cornerRadius(8)

                                    Button("Add") {
                                        let kw = newKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard !kw.isEmpty else { return }
                                        labs.updateSettings { $0.filters.blockedKeywords.append(kw) }
                                        newKeyword = ""
                                    }
                                    .font(.yoruHeadline)
                                    .foregroundColor(theme.accentPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(theme.accentPrimary.opacity(0.15))
                                    .cornerRadius(8)
                                }

                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                                    ForEach(labs.currentSettings.filters.blockedKeywords, id: \.self) { kw in
                                        HStack(spacing: 4) {
                                            Text(kw)
                                                .font(.yoruCaption)
                                                .foregroundColor(theme.textPrimary)
                                                .lineLimit(1)
                                            Button(action: {
                                                labs.updateSettings {
                                                    $0.filters.blockedKeywords.removeAll { $0 == kw }
                                                }
                                            }) {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(theme.destructive)
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(theme.glassSurface)
                                        .cornerRadius(6)
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                    }
                                }
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
