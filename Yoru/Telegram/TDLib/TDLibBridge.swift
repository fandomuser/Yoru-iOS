import Foundation

#if canImport(TDLibFramework)
import TDLibFramework
#endif

/// C function pointer signatures corresponding to TDLib's official C JSON API
public typealias TdJsonClientCreate = @convention(c) () -> UnsafeMutableRawPointer?
public typealias TdJsonClientSend = @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CChar>?) -> Void
public typealias TdJsonClientReceive = @convention(c) (UnsafeMutableRawPointer?, Double) -> UnsafePointer<CChar>?
public typealias TdJsonClientExecute = @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CChar>?) -> UnsafePointer<CChar>?
public typealias TdJsonClientDestroy = @convention(c) (UnsafeMutableRawPointer?) -> Void

public enum TDLibBridgeError: LocalizedError, Equatable {
    case libraryUnavailable
    case sendFailed(String)
    case clientNotInitialized

    public var errorDescription: String? {
        switch self {
        case .libraryUnavailable:
            return "TDLib native binary is not linked. Execute Scripts/build_tdlib_ios.sh on macOS and ensure TDLibFramework.xcframework is embedded in the Xcode project."
        case .sendFailed(let reason):
            return "TDLib packet dispatch failed: \(reason)"
        case .clientNotInitialized:
            return "TDLib JSON client instance is not initialized."
        }
    }
}

/// Low-level actor wrapping raw TDLib C pointer invocations.
/// Supports both direct Clang module symbols (`import TDLibFramework`)
/// and dynamic symbol loader fallback (`dlsym`) for maximum linking resilience.
public actor TDLibBridge {
    private var clientPointer: UnsafeMutableRawPointer?
    private var isRunning: Bool = false

    // Dynamic function pointers resolved via dlsym if module symbols are linked dynamically
    private var dynamicCreate: TdJsonClientCreate?
    private var dynamicSend: TdJsonClientSend?
    private var dynamicReceive: TdJsonClientReceive?
    private var dynamicDestroy: TdJsonClientDestroy?

    public init() {
        let symbols = Self.resolveDynamicSymbols()
        self.dynamicCreate = symbols.create
        self.dynamicSend = symbols.send
        self.dynamicReceive = symbols.receive
        self.dynamicDestroy = symbols.destroy
    }

    private nonisolated static func resolveDynamicSymbols() -> (
        create: TdJsonClientCreate?,
        send: TdJsonClientSend?,
        receive: TdJsonClientReceive?,
        destroy: TdJsonClientDestroy?
    ) {
        #if canImport(Darwin)
        let handle = UnsafeMutableRawPointer(bitPattern: -2) // RTLD_DEFAULT
        var fnCreatePtr: TdJsonClientCreate?
        var fnSendPtr: TdJsonClientSend?
        var fnReceivePtr: TdJsonClientReceive?
        var fnDestroyPtr: TdJsonClientDestroy?

        if let fnCreate = dlsym(handle, "td_json_client_create") {
            fnCreatePtr = unsafeBitCast(fnCreate, to: TdJsonClientCreate.self)
        }
        if let fnSend = dlsym(handle, "td_json_client_send") {
            fnSendPtr = unsafeBitCast(fnSend, to: TdJsonClientSend.self)
        }
        if let fnReceive = dlsym(handle, "td_json_client_receive") {
            fnReceivePtr = unsafeBitCast(fnReceive, to: TdJsonClientReceive.self)
        }
        if let fnDestroy = dlsym(handle, "td_json_client_destroy") {
            fnDestroyPtr = unsafeBitCast(fnDestroy, to: TdJsonClientDestroy.self)
        }
        return (fnCreatePtr, fnSendPtr, fnReceivePtr, fnDestroyPtr)
        #else
        return (nil, nil, nil, nil)
        #endif
    }

    public var isAvailable: Bool {
        #if canImport(TDLibFramework)
        return true
        #else
        return dynamicCreate != nil
        #endif
    }

    public var isInitialized: Bool {
        clientPointer != nil
    }

    public func createClient() throws {
        guard clientPointer == nil else { return }

        #if canImport(TDLibFramework)
        guard let client = td_json_client_create() else {
            throw TDLibBridgeError.clientNotInitialized
        }
        self.clientPointer = client
        self.isRunning = true
        return
        #else
        if let fnCreate = dynamicCreate, let client = fnCreate() {
            self.clientPointer = client
            self.isRunning = true
            return
        }
        throw TDLibBridgeError.libraryUnavailable
        #endif
    }

    public func send(request: String) throws {
        guard let client = clientPointer else {
            throw TDLibBridgeError.clientNotInitialized
        }

        #if canImport(TDLibFramework)
        request.withCString { cStr in
            td_json_client_send(client, cStr)
        }
        #else
        if let fnSend = dynamicSend {
            request.withCString { cStr in
                fnSend(client, cStr)
            }
        } else {
            throw TDLibBridgeError.libraryUnavailable
        }
        #endif
    }

    public func receive(timeout: Double = 1.0) -> String? {
        guard let client = clientPointer else { return nil }

        #if canImport(TDLibFramework)
        if let cResponse = td_json_client_receive(client, timeout) {
            return String(cString: cResponse)
        }
        return nil
        #else
        if let fnReceive = dynamicReceive, let cResponse = fnReceive(client, timeout) {
            return String(cString: cResponse)
        }
        return nil
        #endif
    }

    public func destroy() {
        guard let client = clientPointer else { return }

        #if canImport(TDLibFramework)
        td_json_client_destroy(client)
        #else
        dynamicDestroy?(client)
        #endif

        self.clientPointer = nil
        self.isRunning = false
    }
}
