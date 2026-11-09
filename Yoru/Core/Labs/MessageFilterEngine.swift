import Foundation

public enum MessageFilterResult: Equatable {
    case allowed
    case blurred(reason: String)
    case collapsed(reason: String)
    case hidden(reason: String)
}

public final class MessageFilterEngine {
    public static let shared = MessageFilterEngine()

    private init() {}

    public func evaluate(
        text: String,
        settings: MessageFilterSettings
    ) -> MessageFilterResult {
        guard settings.filterEnabled else { return .allowed }
        let lowerText = text.lowercased()

        // 1. Keyword matching
        for keyword in settings.blockedKeywords {
            let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if !trimmed.isEmpty && lowerText.contains(trimmed) {
                return applyAction(settings.action, reason: "Matched Keyword: '\(keyword)'")
            }
        }

        // 2. Regex matching
        for pattern in settings.regexPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: text.utf16.count)
                if regex.firstMatch(in: text, options: [], range: range) != nil {
                    return applyAction(settings.action, reason: "Matched Pattern Filter")
                }
            }
        }

        return .allowed
    }

    private func applyAction(_ action: FilterAction, reason: String) -> MessageFilterResult {
        switch action {
        case .blur:
            return .blurred(reason: reason)
        case .collapse:
            return .collapsed(reason: reason)
        case .hide:
            return .hidden(reason: reason)
        }
    }
}
