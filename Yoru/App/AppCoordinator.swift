import SwiftUI

public struct AppCoordinatorView: View {
    @Environment(\.yoruTheme) private var theme
    @State private var appState = AppState.shared
    private let telegramService = TelegramService.shared
    private let labs = YoruLabsManager.shared

    @State private var authViewModel = AuthViewModel()
    @State private var isBiometricLocked: Bool = false

    public init() {}

    public var body: some View {
        Group {
            if isBiometricLocked {
                biometricLockScreen
            } else if !appState.hasCompletedOnboarding {
                OnboardingView {
                    appState.hasCompletedOnboarding = true
                }
            } else {
                switch telegramService.authState {
                case .waitingForPhoneNumber, .uninitialized, .waitingForParameters:
                    PhoneNumberView(viewModel: authViewModel)

                case .waitingForCode(let type, _, let timeout):
                    AuthCodeView(viewModel: authViewModel, codeType: type, timeout: timeout)

                case .waitingForPassword(let hint, _):
                    PasswordView(viewModel: authViewModel, hint: hint)

                case .ready, .loggingOut:
                    mainAuthenticatedView

                case .error(let message):
                    errorStateView(message: message)

                default:
                    PhoneNumberView(viewModel: authViewModel)
                }
            }
        }
        .onAppear {
            checkBiometricLock()
        }
    }

    private func errorStateView(message: String) -> some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 20) {
                MangaGraphicView(kanji: "障", icon: "exclamationmark.triangle.fill")
                    .padding(.top, 40)

                Text("CORE PROTOCOL ERROR")
                    .font(.yoruTitle)
                    .foregroundColor(theme.destructive)

                CyberCard(cornerCut: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DIAGNOSTIC TRACE")
                            .font(.yoruCyberBadge)
                            .foregroundColor(theme.accentSecondary)

                        Text(message)
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundColor(theme.textPrimary)
                    }
                }
                .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    YoruButton("RETRY INITIALIZATION", kanji: "再接続", icon: "arrow.clockwise", style: .primary) {
                        telegramService.start()
                    }

                    Button("Open Offline Preview Sandbox") {
                        // Switch to preview mode for offline UI inspection
                        appState.navigateToChat(MockDataGenerator.sampleChats()[0])
                    }
                    .font(.yoruCaption)
                    .foregroundColor(theme.accentSecondary)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
    }

    private func checkBiometricLock() {
        if labs.currentSettings.privacy.localBiometricsEnabled {
            isBiometricLocked = true
            Task {
                let success = await BiometricAuthService.shared.authenticate()
                await MainActor.run {
                    if success {
                        self.isBiometricLocked = false
                    }
                }
            }
        }
    }

    private var biometricLockScreen: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 24) {
                MangaGraphicView(kanji: "錠", icon: "faceid")
                    .padding(.top, 40)

                Text("NEURAL TERMINAL LOCKED")
                    .font(.yoruTitle)
                    .foregroundColor(theme.textPrimary)

                Text("Biometric authorization required to decrypt session memory.")
                    .font(.yoruBody)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                YoruButton("AUTHENTICATE", kanji: "生体認証", icon: "faceid", style: .primary) {
                    Task {
                        let success = await BiometricAuthService.shared.authenticate()
                        await MainActor.run {
                            if success {
                                self.isBiometricLocked = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
        }
    }

    private var mainAuthenticatedView: some View {
        @Bindable var state = appState

        return NavigationStack(path: $state.navigationPath) {
            ZStack(alignment: .bottom) {
                // Tab content
                Group {
                    switch state.selectedTab {
                    case .chats:
                        ChatListView(
                            onSelectChat: { chat in
                                state.navigateToChat(chat)
                            },
                            onProfileTap: {
                                state.openProfile(user: telegramService.currentUser ?? MockDataGenerator.currentUser)
                            }
                        )
                    case .contacts:
                        ContactsView(
                            onSelectUser: { user in
                                state.openProfile(user: user)
                            }
                        )
                    case .search:
                        GlobalSearchView(
                            onSelectChat: { chat in
                                state.navigateToChat(chat)
                            }
                        )
                    case .settings:
                        SettingsView(
                            onOpenThemes: {
                                state.navigationPath.append(AppNavigationDestination.themeStudio)
                            },
                            onOpenSecurity: {
                                state.navigationPath.append(AppNavigationDestination.securitySettings)
                            },
                            onOpenProfile: {
                                state.openProfile(user: telegramService.currentUser ?? MockDataGenerator.currentUser)
                            },
                            onOpenLabs: {
                                state.navigationPath.append(AppNavigationDestination.yoruLabs)
                            }
                        )
                    }
                }
                .padding(.bottom, 64)

                // Custom floating Cyber Tab Bar
                CustomTabBar(
                    selectedTab: $state.selectedTab,
                    unreadCount: telegramService.chats.reduce(0) { $0 + $1.unreadCount }
                )
            }
            .navigationDestination(for: AppNavigationDestination.self) { destination in
                switch destination {
                case .conversation:
                    if let chat = state.activeChat {
                        ConversationView(
                            chat: chat,
                            onBack: {
                                state.navigationPath.removeLast()
                            },
                            onInfoTap: {
                                state.openProfile(user: MockDataGenerator.currentUser)
                            }
                        )
                    }
                case .themeStudio:
                    ThemeSettingsView(
                        onBack: {
                            state.navigationPath.removeLast()
                        }
                    )
                case .securitySettings:
                    SecuritySettingsView(
                        onBack: {
                            state.navigationPath.removeLast()
                        }
                    )
                case .userProfile:
                    if let user = state.selectedUserForProfile {
                        UserProfileView(user: user) {
                            state.navigationPath.removeLast()
                        }
                    }
                case .yoruLabs:
                    YoruLabsView(
                        onBack: {
                            state.navigationPath.removeLast()
                        },
                        onNavigate: { subDest in
                            switch subDest {
                            case .privacy: state.navigationPath.append(AppNavigationDestination.labsPrivacy)
                            case .history: state.navigationPath.append(AppNavigationDestination.labsHistory)
                            case .filters: state.navigationPath.append(AppNavigationDestination.labsFilters)
                            case .appearance: state.navigationPath.append(AppNavigationDestination.labsAppearance)
                            case .chat: state.navigationPath.append(AppNavigationDestination.labsChat)
                            case .translation: state.navigationPath.append(AppNavigationDestination.labsTranslation)
                            case .ai: state.navigationPath.append(AppNavigationDestination.labsAI)
                            case .advanced: state.navigationPath.append(AppNavigationDestination.labsAdvanced)
                            }
                        }
                    )
                case .labsPrivacy:
                    PrivacyActivitySettingsView { state.navigationPath.removeLast() }
                case .labsHistory:
                    MessageHistorySettingsView { state.navigationPath.removeLast() }
                case .labsFilters:
                    MessageFiltersSettingsView { state.navigationPath.removeLast() }
                case .labsAppearance:
                    AppearanceCustomizationView { state.navigationPath.removeLast() }
                case .labsChat:
                    ChatEnhancementsSettingsView { state.navigationPath.removeLast() }
                case .labsTranslation:
                    TranslationSettingsView { state.navigationPath.removeLast() }
                case .labsAI:
                    AIToolsSettingsView { state.navigationPath.removeLast() }
                case .labsAdvanced:
                    AdvancedSettingsView { state.navigationPath.removeLast() }
                }
            }
            .sheet(isPresented: $state.isShowingProfileModal) {
                if let user = state.selectedUserForProfile {
                    UserProfileView(user: user) {
                        state.isShowingProfileModal = false
                    }
                    .environment(\.yoruTheme, ThemeManager.shared.currentTheme)
                }
            }
        }
    }
}
