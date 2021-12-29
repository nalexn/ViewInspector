#if os(iOS) || os(watchOS)

import XCTest
import SwiftUI
import AuthenticationServices.ASAuthorizationAppleIDButton
@testable import ViewInspector

@available(iOS 13.0, watchOS 6.0, *)
@available(tvOS, unavailable)
@available(macOS, unavailable)
final class SignInWithAppleButtonTests: XCTestCase {
    
    @available(iOS 15.0, watchOS 8.0, *)
    private var newButton: SignInWithAppleButton {
        SignInWithAppleButton(onRequest: { _ in }, onCompletion: { _ in })
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let sut = AnyView(newButton)
        XCTAssertNoThrow(try sut.inspect().anyView().signInWithAppleButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let sut = HStack { newButton; newButton }
        XCTAssertNoThrow(try sut.inspect().hStack().signInWithAppleButton(0))
        XCTAssertNoThrow(try sut.inspect().hStack().signInWithAppleButton(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let sut = AnyView(newButton)
        XCTAssertEqual(try sut.inspect().find(ViewType.SignInWithAppleButton.self).pathToRoot,
            "anyView().signInWithAppleButton()")
    }
    
    func testLabelType() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let sut1 = SignInWithAppleButton(.signIn, onRequest: { _ in }, onCompletion: { _ in })
        let sut2 = SignInWithAppleButton(.signUp, onRequest: { _ in }, onCompletion: { _ in })
        XCTAssertEqual(try sut1.inspect().signInWithAppleButton().labelType(), .signIn)
        XCTAssertEqual(try sut2.inspect().signInWithAppleButton().labelType(), .signUp)
    }
    
    func testTap() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let onRequest = XCTestExpectation(description: "onRequest")
        let onCompletion = XCTestExpectation(description: "onCompletion")
        let credential = ASAuthorizationAppleIDCredential(
            user: "abc", email: "xyz@mail.com",
            fullName: PersonNameComponents(givenName: "A", familyName: "B"),
            state: "s", authorizedScopes: [.email],
            authorizationCode: Data(count: 2),
            identityToken: Data(count: 5),
            realUserStatus: .likelyReal)
        let sut = SignInWithAppleButton(onRequest: { request in
            request.requestedScopes = [.email, .fullName]
            onRequest.fulfill()
        }, onCompletion: { result in
            guard case let .success(auth) = result,
                  let value = auth.credential as? ASAuthorizationAppleIDCredential
            else {
                XCTFail(); return
            }
            XCTAssertEqual(value.user, credential.user)
            XCTAssertEqual(value.email, credential.email)
            XCTAssertEqual(value.fullName, credential.fullName)
            XCTAssertEqual(value.state, credential.state)
            XCTAssertEqual(value.authorizedScopes, credential.authorizedScopes)
            XCTAssertEqual(value.authorizationCode, credential.authorizationCode)
            XCTAssertEqual(value.identityToken, credential.identityToken)
            XCTAssertEqual(value.realUserStatus, credential.realUserStatus)
            onCompletion.fulfill()
        })
        try sut.inspect().signInWithAppleButton().tap(.appleIDCredential(credential))
        wait(for: [onRequest, onCompletion], timeout: 0.1)
    }
}
#endif
