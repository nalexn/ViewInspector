import SwiftUI
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct SignInWithAppleButton: KnownViewType {
        public static let typePrefix: String = "SignInWithAppleButton"
        public static var namespacedPrefixes: [String] {
            return ["_AuthenticationServices_SwiftUI." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "signInWithAppleButton(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func signInWithAppleButton() throws -> InspectableView<ViewType.SignInWithAppleButton> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func signInWithAppleButton(_ index: Int) throws -> InspectableView<ViewType.SignInWithAppleButton> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

#if canImport(AuthenticationServices) && !os(watchOS)

@available(iOS 14.0, macOS 11.0, tvOS 15.0, watchOS 7.0, *)
public extension ViewType.SignInWithAppleButton {
    enum SignInOutcome {
        case appleIDCredential(ASAuthorizationAppleIDCredential)
        case passwordCredential(ASPasswordCredential)
        case failure(Error)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.SignInWithAppleButton {
    
    func labelType() throws -> SignInWithAppleButton.Label {
        let type = try buttonSurrogate().type
        return SignInWithAppleButton.Label(type: type)
    }
    
    @available(tvOS 15.0, *)
    func tap(_ outcome: ViewType.SignInWithAppleButton.SignInOutcome) throws {
        let button = try buttonSurrogate()
        DispatchQueue.main.async {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            button.onRequest(request)
            let result: Result<ASAuthorization, Error>
            switch outcome {
            case .appleIDCredential(let credential):
                let surrogate = VIASAuthorization(
                    provider: ASAuthorizationAppleIDProvider(),
                    credential: credential)
                let auth = unsafeBitCast(surrogate, to: ASAuthorization.self)
                result = .success(auth)
            case .passwordCredential(let credential):
                let surrogate = VIASAuthorization(
                    provider: ASAuthorizationPasswordProvider(),
                    credential: credential)
                let auth = unsafeBitCast(surrogate, to: ASAuthorization.self)
                result = .success(auth)
            case .failure(let error):
                result = .failure(error)
            }
            DispatchQueue.main.async {
                button.onCompletion(result)
            }
        }
    }
    
    private typealias ButtonSurrogate = SignInWithAppleButton.Surrogate
    private func buttonSurrogate() throws -> ButtonSurrogate {
        let button = try Inspector.cast(value: content.view, type: SignInWithAppleButton.self)
        return try Inspector.unsafeMemoryRebind(value: button, type: ButtonSurrogate.self)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension SignInWithAppleButton.Label: BinaryEquatable {
    init(type: ASAuthorizationAppleIDButton.ButtonType) {
        switch type {
        case .signIn:
            self = .signIn
        case .continue:
            self = .continue
        case .signUp:
            self = .signUp
        @unknown default:
            self = .signIn
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension SignInWithAppleButton {
    struct Surrogate {
        let type: ASAuthorizationAppleIDButton.ButtonType
        let onRequest: (ASAuthorizationAppleIDRequest) -> Void
        let onCompletion: (Result<ASAuthorization, Error>) -> Void
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private final class VIASAuthorization: NSObject {
    @objc let provider: ASAuthorizationProvider
    @objc let credential: ASAuthorizationCredential
    
    init(provider: ASAuthorizationProvider, credential: ASAuthorizationCredential) {
        self.provider = provider
        self.credential = credential
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension ASAuthorizationAppleIDCredential {
    convenience init(user: String, email: String?,
                     fullName: PersonNameComponents?,
                     state: String? = nil,
                     authorizedScopes: [ASAuthorization.Scope] = [.fullName, .email],
                     authorizationCode: Data? = nil, identityToken: Data? = nil,
                     realUserStatus: ASUserDetectionStatus = .unknown) {
        let data = Data(base64Encoded:
        """
        YnBsaXN0MDDUAQIDBAUGBxhYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF\
        8QD05TS2V5ZWRBcmNoaXZlctgICQoLDA0ODxAREBAUEBYQVl9lbWFpbF8QEV9hdXRob3JpemVk\
        U2NvcGVzWV9mdWxsTmFtZVZfc3RhdGVfEA9fcmVhbFVzZXJTdGF0dXNfEBJfYXV0aG9yaXphdG\
        lvbkNvZGVVX3VzZXJeX2lkZW50aXR5VG9rZW6AAIACgACAABABgACAAYAApBkaGyBVJG51bGxQ\
        0hwdHh9aTlMub2JqZWN0c1YkY2xhc3OggAPSISIjJFokY2xhc3NuYW1lWCRjbGFzc2VzV05TQX\
        JyYXmiIyVYTlNPYmplY3QACAARABoAJAApADIANwBJAFoAYQB1AH8AhgCYAK0AswDCAMQAxgDI\
        AMoAzADOANAA0gDXAN0A3gDjAO4A9QD2APgA/QEIAREBGQEcAAAAAAAAAgEAAAAAAAAAJgAAAA\
        AAAAAAAAAAAAAAASU=
        """)
        // swiftlint:disable force_try
        let decoder = try! NSKeyedUnarchiver(forReadingFrom: data!)
        self.init(coder: decoder)!
        // swiftlint:enable force_try
        setValue(user, forKey: "user")
        setValue(email, forKey: "email")
        setValue(fullName, forKey: "fullName")
        setValue(state, forKey: "state")
        setValue(authorizedScopes, forKey: "authorizedScopes")
        setValue(authorizationCode, forKey: "authorizationCode")
        setValue(identityToken, forKey: "identityToken")
        setValue(realUserStatus.rawValue, forKey: "realUserStatus")
    }
}
#endif
