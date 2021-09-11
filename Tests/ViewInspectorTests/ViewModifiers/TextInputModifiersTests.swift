import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - TextInputModifiersTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TextInputModifiersTests: XCTestCase {
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    func testTextContentType() throws {
        let sut = EmptyView().textContentType(.emailAddress)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(iOS) || os(tvOS)
    func testTextContentTypeInspection() throws {
        let sut = AnyView(EmptyView()).textContentType(.emailAddress)
        XCTAssertEqual(try sut.inspect().anyView().textContentType(), .emailAddress)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().textContentType(), .emailAddress)
    }
    #endif
    
    #if os(iOS) || os(tvOS)
    func testKeyboardType() throws {
        let sut = EmptyView().keyboardType(.namePhonePad)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testKeyboardTypeInspection() throws {
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            throw XCTSkip(
                """
                Implementation should be similar to 'autocapitalization', but new \
                'KeyboardType' is a private type in SwiftUI
                """)
        }
        let sut = AnyView(EmptyView()).keyboardType(.namePhonePad)
        XCTAssertEqual(try sut.inspect().anyView().keyboardType(), .namePhonePad)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().keyboardType(), .namePhonePad)
    }
    
    func testAutocapitalization() throws {
        let sut = EmptyView().autocapitalization(.words)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAutocapitalizationInspection() throws {
        let sut = AnyView(EmptyView()).autocapitalization(.words)
        XCTAssertEqual(try sut.inspect().anyView().autocapitalization(), .words)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().autocapitalization(), .words)
    }
    #endif
    
    func testFont() throws {
        let sut = EmptyView().font(.body)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFontInspection() throws {
        let sut = AnyView(EmptyView()).font(.largeTitle)
        XCTAssertEqual(try sut.inspect().anyView().font(), .largeTitle)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().font(), .largeTitle)
    }
    
    func testTextFontOverrideWithNativeModifier() throws {
        let sut = Group { Text("test").font(.callout) }.font(.footnote)
        let group = try sut.inspect().group()
        XCTAssertEqual(try group.font(), .footnote)
        XCTAssertThrows(try EmptyView().inspect().font(),
                        "EmptyView does not have 'font' modifier")
        XCTAssertEqual(try group.text(0).attributes().font(), .callout)
    }
    
    func testTextFontOverrideWithInnerModifier() throws {
        let sut = AnyView(AnyView(Text("test")).font(.footnote)).font(.callout)
        let text = try sut.inspect().find(text: "test")
        XCTAssertEqual(try text.attributes().font(), .footnote)
    }
    
    func testLineLimit() throws {
        let sut = EmptyView().lineLimit(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLineLimitInspection() throws {
        let sut = AnyView(EmptyView()).lineLimit(5)
        XCTAssertEqual(try sut.inspect().anyView().lineLimit(), 5)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().lineLimit(), 5)
    }
    
    func testLineSpacing() throws {
        let sut = EmptyView().lineSpacing(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLineSpacingInspection() throws {
        let sut = AnyView(EmptyView()).lineSpacing(4)
        XCTAssertEqual(try sut.inspect().anyView().lineSpacing(), 4)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().lineSpacing(), 4)
    }
    
    func testMultilineTextAlignment() throws {
        let sut = EmptyView().multilineTextAlignment(.center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMultilineTextAlignmentInspection() throws {
        let sut = AnyView(EmptyView()).multilineTextAlignment(.center)
        XCTAssertEqual(try sut.inspect().anyView().multilineTextAlignment(), .center)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().multilineTextAlignment(), .center)
    }
    
    func testMinimumScaleFactor() throws {
        let sut = EmptyView().minimumScaleFactor(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMinimumScaleFactorInspection() throws {
        let sut = AnyView(EmptyView()).minimumScaleFactor(2)
        XCTAssertEqual(try sut.inspect().anyView().minimumScaleFactor(), 2)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().minimumScaleFactor(), 2)
    }
    
    func testTruncationMode() throws {
        let sut = EmptyView().truncationMode(.tail)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTruncationModeInspection() throws {
        let sut = AnyView(EmptyView()).truncationMode(.tail)
        XCTAssertEqual(try sut.inspect().anyView().truncationMode(), .tail)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().truncationMode(), .tail)
    }
    
    func testAllowsTightening() throws {
        let sut = EmptyView().allowsTightening(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAllowsTighteningInspection() throws {
        let sut = AnyView(EmptyView()).allowsTightening(true)
        XCTAssertTrue(try sut.inspect().anyView().allowsTightening())
        XCTAssertTrue(try sut.inspect().anyView().emptyView().allowsTightening())
    }
    
    @available(watchOS, unavailable)
    func testDisableAutocorrection() throws {
        let sut = EmptyView().disableAutocorrection(false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    @available(watchOS, unavailable)
    func testDisableAutocorrectionInspection() throws {
        let sut = AnyView(EmptyView()).disableAutocorrection(false)
        XCTAssertEqual(try sut.inspect().anyView().disableAutocorrection(), false)
        XCTAssertEqual(try sut.inspect().anyView().emptyView().disableAutocorrection(), false)
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
