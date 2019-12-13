import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewTextAdjustingTests

final class ViewTextAdjustingTests: XCTestCase {
    
    #if os(iOS) || os(tvOS)
    func testKeyboardType() throws {
        let sut = EmptyView().keyboardType(.namePhonePad)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testFont() throws {
        let sut = EmptyView().font(.body)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLineLimit() throws {
        let sut = EmptyView().lineLimit(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLineSpacing() throws {
        let sut = EmptyView().lineSpacing(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMultilineTextAlignment() throws {
        let sut = EmptyView().multilineTextAlignment(.center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMinimumScaleFactor() throws {
        let sut = EmptyView().minimumScaleFactor(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTruncationMode() throws {
        let sut = EmptyView().truncationMode(.tail)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAllowsTightening() throws {
        let sut = EmptyView().allowsTightening(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testTextContentType() throws {
        let sut = EmptyView().textContentType(.emailAddress)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testFlipsForRightToLeftLayoutDirection() throws {
        let sut = EmptyView().flipsForRightToLeftLayoutDirection(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if os(iOS) || os(tvOS)
    func testAutocapitalization() throws {
        let sut = EmptyView().autocapitalization(.words)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testDisableAutocorrection() throws {
        let sut = EmptyView().disableAutocorrection(false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - ViewControlAttributesTests

final class ViewControlAttributesTests: XCTestCase {
    
    func testLabelsHidden() throws {
        let sut = EmptyView().labelsHidden()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if os(watchOS)
    func testDefaultWheelPickerItemHeight() throws {
        let sut = EmptyView().defaultWheelPickerItemHeight(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(macOS)
    func testHorizontalRadioGroupLayout() throws {
        let sut = EmptyView().horizontalRadioGroupLayout()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testControlSize() throws {
        let sut = EmptyView().controlSize(.mini)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}

// MARK: - ViewStylingTests

final class ViewStylingTests: XCTestCase {
    
    func testButtonStyle() throws {
        let sut = EmptyView().buttonStyle(PlainButtonStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if os(macOS)
    func testMenuButtonStyle() throws {
        let sut = EmptyView().menuButtonStyle(PullDownMenuButtonStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testPickerStyle() throws {
        let sut = EmptyView().pickerStyle(DefaultPickerStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if os(macOS) || os(iOS)
    func testDatePickerStyle() throws {
        let sut = EmptyView().datePickerStyle(DefaultDatePickerStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testTextFieldStyle() throws {
        let sut = EmptyView().textFieldStyle(DefaultTextFieldStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testToggleStyle() throws {
        let sut = EmptyView().toggleStyle(DefaultToggleStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testNavigationViewStyle() throws {
        let sut = EmptyView().navigationViewStyle(DefaultNavigationViewStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
