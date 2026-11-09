import SwiftUI

public enum YoruAnimations {
    // Dynamic spring physics tuned for iPhone 17 Pro Max 120Hz ProMotion display
    public static let snappySpring = Animation.spring(response: 0.28, dampingFraction: 0.72, blendDuration: 0)
    public static let gentleSpring = Animation.spring(response: 0.42, dampingFraction: 0.82, blendDuration: 0)
    public static let cyberPulse = Animation.easeInOut(duration: 1.6).repeatForever(autoreverses: true)
    public static let modalSlide = Animation.interpolatingSpring(mass: 0.8, stiffness: 120, damping: 14)
}
