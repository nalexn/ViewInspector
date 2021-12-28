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

#if canImport(AuthenticationServices)

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
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
    
    func tap(_ outcome: ViewType.SignInWithAppleButton.SignInOutcome) throws {
        let button = try buttonSurrogate()
        DispatchQueue.main.async {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            button.onRequest(request)
            let auth = VIASAuthorization()
            let result: Result<ASAuthorization, Error>
            switch outcome {
            case .appleIDCredential(let credential):
                auth.setProvider(ASAuthorizationAppleIDProvider())
                auth.setCredential(credential)
                result = .success(auth)
            case .passwordCredential(let credential):
                auth.setProvider(ASAuthorizationPasswordProvider())
                auth.setCredential(credential)
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
        return withUnsafeBytes(of: button) { bytes in
            return bytes.baseAddress!
                .assumingMemoryBound(to: ButtonSurrogate.self).pointee
        }
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
public extension ASAuthorizationAppleIDCredential {
    convenience init(user: String, email: String?,
                     fullName: PersonNameComponents?,
                     state: String? = nil,
                     authorizedScopes: [ASAuthorization.Scope] = [.fullName, .email],
                     authorizationCode: Data? = nil,
                     identityToken: Data? = nil) {
        self.init(user: user, email: email, fullName: fullName,
                  state: state, authorizedScopes: authorizedScopes,
                  authorizationCode: authorizationCode,
                  identityToken: identityToken, realUserStatus: .unknown)
    }
}
#endif
