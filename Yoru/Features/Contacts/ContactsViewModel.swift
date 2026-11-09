import SwiftUI

@Observable
public final class ContactsViewModel {
    public var contacts: [TelegramUser] = []
    public var searchText: String = ""

    private let telegramService: TelegramService

    public init(telegramService: TelegramService = .shared) {
        self.telegramService = telegramService
        self.contacts = MockDataGenerator.sampleUsers
    }

    public var filteredContacts: [TelegramUser] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return contacts
        }
        return contacts.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) ||
            ($0.username?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
}
