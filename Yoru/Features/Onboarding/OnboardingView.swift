import SwiftUI

public struct OnboardingView: View {
    @Environment(\.yoruTheme) private var theme
    @State private var viewModel = OnboardingViewModel()
    private let onComplete: () -> Void

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            // Cyber gradient background
            theme.backgroundPrimary
                .ignoresSafeArea()

            // Ambient background glow
            Circle()
                .fill(theme.accentPrimary.opacity(0.18))
                .blur(radius: 80)
                .offset(y: -120)

            VStack(spacing: 32) {
                // Header Brand
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PROJECT YORU")
                            .font(.yoruCyberBadge)
                            .foregroundColor(theme.accentSecondary)
                            .tracking(2)
                        Text("夜 — TELEGRAM")
                            .font(.yoruHeadline)
                            .foregroundColor(theme.textPrimary)
                    }
                    Spacer()
                    CyberTag("v0.1.0", kanji: "開発版")
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // Slides Carousel
                TabView(selection: $viewModel.currentSlideIndex) {
                    ForEach(0..<viewModel.slides.count, id: \.self) { index in
                        let slide = viewModel.slides[index]
                        VStack(spacing: 24) {
                            MangaGraphicView(kanji: slide.kanji, icon: slide.icon)
                                .scaleEffect(1.2)
                                .padding(.bottom, 20)

                            VStack(spacing: 12) {
                                Text(slide.title)
                                    .font(.yoruTitle)
                                    .foregroundColor(theme.textPrimary)
                                    .multilineTextAlignment(.center)

                                Text(slide.subtitle)
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 380)

                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.slides.count, id: \.self) { index in
                        Capsule()
                            .fill(viewModel.currentSlideIndex == index ? theme.accentPrimary : Color.white.opacity(0.2))
                            .frame(width: viewModel.currentSlideIndex == index ? 24 : 8, height: 6)
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.currentSlideIndex)
                    }
                }

                Spacer()

                // Actions
                VStack(spacing: 14) {
                    if viewModel.isLastSlide {
                        YoruButton("ENTER THE MATRIX", kanji: "接続開始", icon: "arrow.right.circle.fill", style: .primary) {
                            onComplete()
                        }
                    } else {
                        YoruButton("CONTINUE", kanji: "次へ", icon: "chevron.right", style: .primary) {
                            viewModel.nextSlide()
                        }
                    }

                    Button(action: onComplete) {
                        Text("Skip Initialization")
                            .font(.yoruCaption)
                            .foregroundColor(theme.textTertiary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}
