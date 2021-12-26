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
    
    func testCallOnRequest() throws {
        let exp = XCTestExpectation(description: #function)
        let sut = SignInWithAppleButton(onRequest: { request in
            // Does not work yet: reference to object is corrupted inside closure
            // Any request to the object causes a crash:
            request.requestedScopes = [.email, .fullName]
            exp.fulfill()
        }, onCompletion: { _ in })
        let request = try sut.inspect().signInWithAppleButton().callOnRequest()
        XCTAssertEqual(request.requestedScopes, [.email, .fullName])
        XCTAssertEqual(request.requestedScopes, nil)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testCallOnCompletion() throws {
        let exp = XCTestExpectation(description: #function)
        let sut = SignInWithAppleButton(onRequest: { _ in }, onCompletion: { res in
            switch res {
            case .success(let auth):
                if let cred = auth.credential as? ASAuthorizationAppleIDCredential {
                    print(">>>> \(cred.user)")
                }
            case .failure:
                break
            }
            exp.fulfill()
        })
        let dd = VIASAuthorization.appleID()
        let cred = ASAuthorizationAppleIDCredential(user: "lesha")
        dd.setCredential(cred)
        try sut.inspect().signInWithAppleButton()
            .callOnCompletion(.success(dd))
//        ASAuthorization
        // authorization.credential as? ASAuthorizationAppleIDCredential
        // else if let passwordCredential = authorization.credential as? ASPasswordCredential
        wait(for: [exp], timeout: 0.1)
    }
}
