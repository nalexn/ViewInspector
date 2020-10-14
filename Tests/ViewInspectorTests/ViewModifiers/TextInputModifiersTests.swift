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
    
    func testFontInspection() throws {
        let sut = EmptyView().font(.body)
        XCTAssertEqual(try sut.inspect().emptyView().font(), .body)
    }
    
    func testTextFontInspection() throws {
        let sut = Group { Text("test").font(.callout) }.font(.footnote)
        let group = try sut.inspect().group()
        XCTAssertEqual(try group.font(), .footnote)
        XCTAssertThrows(try EmptyView().inspect().font(),
                        "EmptyView does not have 'font' modifier")
        XCTAssertEqual(try group.text(0).attributes().font(), .callout)
    }
    
    func testLineLimitInspection() throws {
        let sut = EmptyView().lineLimit(5)
        XCTAssertEqual(try sut.inspect().emptyView().lineLimit(), 5)
    }
    
    func testLineSpacingInspection() throws {
        let sut = EmptyView().lineSpacing(4)
        XCTAssertEqual(try sut.inspect().emptyView().lineSpacing(), 4)
    }
    
    func testDisableAutocorrection() throws {
        let sut = EmptyView().disableAutocorrection(false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testDisableAutocorrectionInspection() throws {
        let sut = EmptyView().disableAutocorrection(false)
        XCTAssertEqual(try sut.inspect().emptyView().disableAutocorrection(), false)
    }
    
    func testFlipsForRightToLeftLayoutDirection() throws {
        let sut = EmptyView().flipsForRightToLeftLayoutDirection(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFlipsForRightToLeftLayoutDirectionInspection() throws {
        let sut = EmptyView().flipsForRightToLeftLayoutDirection(true)
        XCTAssertEqual(try sut.inspect().emptyView().flipsForRightToLeftLayoutDirection(), true)
    }
}
