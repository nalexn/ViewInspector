import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - TextInputModifiersTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TextInputModifiersTests: XCTestCase {
    
    #if !os(macOS)
    func testTextContentType() throws {
        let sut = EmptyView().textContentType(.emailAddress)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTextContentTypeInspection() throws {
        let sut = EmptyView().textContentType(.emailAddress)
        XCTAssertEqual(try sut.inspect().emptyView().textContentType(), .emailAddress)
    }
    #endif
    
    #if os(iOS) || os(tvOS)
    func testKeyboardType() throws {
        let sut = EmptyView().keyboardType(.namePhonePad)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testKeyboardTypeInspection() throws {
        let sut = EmptyView().keyboardType(.namePhonePad)
        XCTAssertEqual(try sut.inspect().emptyView().keyboardType(), .namePhonePad)
    }
    
    func testAutocapitalization() throws {
        let sut = EmptyView().autocapitalization(.words)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAutocapitalizationInspection() throws {
        let sut = EmptyView().autocapitalization(.words)
        XCTAssertEqual(try sut.inspect().emptyView().autocapitalization(), .words)
    }
    #endif
    
    func testDisableAutocorrection() throws {
        let sut = EmptyView().disableAutocorrection(false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
