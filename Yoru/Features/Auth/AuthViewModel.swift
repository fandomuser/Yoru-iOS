import SwiftUI

@Observable
public final class AuthViewModel {
    public var phoneNumber: String = "+1 "
    public var authCode: String = ""
    public var password: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?

    private let telegramService: TelegramService

    public init(telegramService: TelegramService = .shared) {
        self.telegramService = telegramService
    }

    public func submitPhoneNumber() {
        let cleanNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanNumber.count > 5 else {
            errorMessage = "Please enter a valid international phone number."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await telegramService.sendPhoneNumber(cleanNumber)
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    public func submitAuthCode() {
        let cleanCode = authCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanCode.isEmpty else {
            errorMessage = "Please enter the code sent to your Telegram app or SMS."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await telegramService.sendAuthCode(cleanCode)
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    public func submitPassword() {
        guard !password.isEmpty else {
            errorMessage = "Please enter your 2-Step Verification password."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await telegramService.sendPassword(password)
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
