import SwiftUI

@Observable
public final class OnboardingViewModel {
    public var currentSlideIndex: Int = 0

    public struct Slide: Identifiable {
        public let id = UUID()
        public let title: String
        public let kanji: String
        public let subtitle: String
        public let icon: String
    }

    public let slides: [Slide] = [
        Slide(
            title: "WELCOME TO YORU",
            kanji: "夜へようこそ",
            subtitle: "A next-generation native iOS Telegram client engineered with a high-octane Japanese Cyber-Anime visual engine.",
            icon: "sparkles.tv.fill"
        ),
        Slide(
            title: "OFFICIAL TDLIB CORE",
            kanji: "公式通信基盤",
            subtitle: "Direct MTProto encryption and Telegram network synchronization. No middleman, zero third-party telemetry.",
            icon: "shield.checkered"
        ),
        Slide(
            title: "5 ICONIC THEMES",
            kanji: "五大美学テーマ",
            subtitle: "Switch seamlessly between Tokyo Night, Sakura Dream, Midnight Blue, Crimson Moon, and Manga Mono.",
            icon: "paintpalette.fill"
        )
    ]

    public var isLastSlide: Bool {
        currentSlideIndex == slides.count - 1
    }

    public func nextSlide() {
        if currentSlideIndex < slides.count - 1 {
            withAnimation(.snappy) {
                currentSlideIndex += 1
            }
        }
    }
}
