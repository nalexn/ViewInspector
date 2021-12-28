import XCTest
import SwiftUI
import AuthenticationServices.ASAuthorizationAppleIDButton
@testable import ViewInspector

@available(iOS 15.0, watchOS 8.0, *)
@available(tvOS, unavailable)
@available(macOS, unavailable)
final class SignInWithAppleButtonTests: XCTestCase {
    
    private var newButton: SignInWithAppleButton {
        SignInWithAppleButton(onRequest: { _ in }, onCompletion: { _ in })
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let sut = AnyView(newButton)
        XCTAssertNoThrow(try sut.inspect().anyView().signInWithAppleButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let sut = HStack { newButton; newButton }
        XCTAssertNoThrow(try sut.inspect().hStack().signInWithAppleButton(0))
        XCTAssertNoThrow(try sut.inspect().hStack().signInWithAppleButton(1))
    }
    
    func testSearch() throws {
        let sut = AnyView(newButton)
        XCTAssertEqual(try sut.inspect().find(ViewType.SignInWithAppleButton.self).pathToRoot,
            "anyView().signInWithAppleButton()")
    }
    
    func testLabelType() throws {
        let sut1 = SignInWithAppleButton(.signIn, onRequest: { _ in }, onCompletion: { _ in })
        let sut2 = SignInWithAppleButton(.signUp, onRequest: { _ in }, onCompletion: { _ in })
        XCTAssertEqual(try sut1.inspect().signInWithAppleButton().labelType(), .signIn)
        XCTAssertEqual(try sut2.inspect().signInWithAppleButton().labelType(), .signUp)
    }
    
    func testTap() throws {
        let onRequest = XCTestExpectation(description: "onRequest")
        let onCompletion = XCTestExpectation(description: "onCompletion")
        let credential = ASAuthorizationAppleIDCredential(user: "abc", email: "abc@mail.com", fullName: nil)
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
            XCTAssertNil(value.fullName)
            onCompletion.fulfill()
        })
        try sut.inspect().signInWithAppleButton().tap(.appleIDCredential(credential))
        wait(for: [onRequest, onCompletion], timeout: 0.1)
    }
}
