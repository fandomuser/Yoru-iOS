import Foundation
import LocalAuthentication

public final class BiometricAuthService {
    public static let shared = BiometricAuthService()

    private init() {}

    public var canEvaluateBiometrics: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public var biometricType: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Passcode"
        }
    }

    public func authenticate(reason: String = "Authenticate to unlock Yoru Neural Terminal") async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        return await withCheckedContinuation { continuation in
            // Evaluate device owner with biometrics or fallback to device passcode
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
}
