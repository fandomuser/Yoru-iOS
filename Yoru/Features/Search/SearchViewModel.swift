import SwiftUI

@Observable
public final class SearchViewModel {
    public var query: String = ""
    public var results: [TelegramChat] = []
    public var isSearching: Bool = false

    private let telegramService: TelegramService

    public init(telegramService: TelegramService = .shared) {
        self.telegramService = telegramService
    }

    public func executeSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            results = []
            return
        }

        isSearching = true
        Task {
            let res = try? await telegramService.client.searchGlobal(query: q)
            await MainActor.run {
                self.results = res ?? []
                self.isSearching = false
            }
        }
    }
}
