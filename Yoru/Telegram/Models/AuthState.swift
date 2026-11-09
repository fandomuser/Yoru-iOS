import Foundation

public enum AuthCodeType: Equatable, Hashable {
    case telegramApp
    case sms
    case call
    case flashCall
    case other(String)

    public var title: String {
        switch self {
        case .telegramApp: return "Telegram App"
        case .sms: return "SMS"
        case .call: return "Phone Call"
        case .flashCall: return "Flash Call"
        case .other(let name): return name
        }
    }
}

public enum TelegramAuthState: Equatable {
    case uninitialized
    case waitingForParameters
    case waitingForPhoneNumber
    case waitingForCode(type: AuthCodeType, nextCodeType: AuthCodeType?, timeout: Int)
    case waitingForPassword(hint: String?, hasRecovery: Bool)
    case waitingForRegistration
    case ready(user: TelegramUser)
    case loggingOut
    case closed
    case error(String)
}
