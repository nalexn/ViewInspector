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
public extension InspectableView where View == ViewType.SignInWithAppleButton {
    
    func labelType() throws -> SignInWithAppleButton.Label {
        let type = try Inspector.attribute(
            path: "configuration|type", value: content.view,
            type: ASAuthorizationAppleIDButton.ButtonType.self)
        return SignInWithAppleButton.Label(type: type)
    }
    
    @discardableResult
    internal // no official support, see the comment in the test
    func callOnRequest() throws -> ASAuthorizationAppleIDRequest {
        typealias Closure = (ASAuthorizationAppleIDRequest) -> Void
        let closure = try Inspector.attribute(
            path: "configuration|onRequest", value: content.view, type: Closure.self)
        let request = ASAuthorizationAppleIDProvider().createRequest()
        VIASAuthorization.pass(request, block: closure)
//        closure(request)
        return request
    }
    
    func callOnCompletion(_ result: Result<ASAuthorization, Error>) throws {
        typealias Closure = (Result<ASAuthorization, Error>) -> Void
        let closure = try Inspector.attribute(
            path: "configuration|onCompletion", value: content.view, type: Closure.self)
        closure(result)
    }
}
#endif

#if canImport(AuthenticationServices)
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
#endif
