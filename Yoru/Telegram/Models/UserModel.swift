import Foundation

public enum UserStatus: Equatable {
    case empty
    case online(expires: Date)
    case offline(wasOnline: Date?)
    case recently
    case lastWeek
    case lastMonth
}

public struct TelegramUser: Identifiable, Equatable, Hashable {
    public let id: Int64
    public let firstName: String
    public let lastName: String
    public let username: String?
    public let phoneNumber: String
    public let avatarUrl: String?
    public let bio: String?
    public let isVerified: Bool
    public let isPremium: Bool
    public let isBot: Bool
    public let status: UserStatus

    public var fullName: String {
        if lastName.isEmpty {
            return firstName
        }
        return "\(firstName) \(lastName)"
    }

    public var initials: String {
        let firstInitial = firstName.prefix(1)
        let lastInitial = lastName.prefix(1)
        return "\(firstInitial)\(lastInitial)".uppercased()
    }

    public init(
        id: Int64,
        firstName: String,
        lastName: String = "",
        username: String? = nil,
        phoneNumber: String = "",
        avatarUrl: String? = nil,
        bio: String? = nil,
        isVerified: Bool = false,
        isPremium: Bool = false,
        isBot: Bool = false,
        status: UserStatus = .recently
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.phoneNumber = phoneNumber
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.isVerified = isVerified
        self.isPremium = isPremium
        self.isBot = isBot
        self.status = status
    }

    public static func == (lhs: TelegramUser, rhs: TelegramUser) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
