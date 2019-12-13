import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewPresentationTests

final class ViewPresentationTests: XCTestCase {
    
    @State private var value: Bool = false
    
    func testSheet() throws {
        let sut = EmptyView().sheet(isPresented: $value) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testActionSheet() throws {
        let sut = EmptyView().actionSheet(isPresented: $value) { ActionSheet(title: Text("")) }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testAlert() throws {
        let sut = EmptyView().alert(isPresented: $value) { Alert(title: Text("")) }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(tvOS)
    func testPopover() throws {
        let sut = EmptyView().popover(isPresented: $value) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}

// MARK: - ViewColorTests

final class ViewColorTests: XCTestCase {
    
    func testForegroundColor() throws {
        let sut = EmptyView().foregroundColor(.purple)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testAccentColor() throws {
        let sut = EmptyView().accentColor(.purple)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testColorScheme() throws {
        let sut = EmptyView().colorScheme(.light)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testPreferredColorScheme() throws {
        let sut = EmptyView().preferredColorScheme(.dark)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}

// MARK: - ViewGraphicalEffectsTests

final class ViewGraphicalEffectsTests: XCTestCase {
    
    func testBlur() throws {
        let sut = EmptyView().blur(radius: 5, opaque: true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOpacity() throws {
        let sut = EmptyView().opacity(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBrightness() throws {
        let sut = EmptyView().brightness(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testContrast() throws {
        let sut = EmptyView().contrast(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testColorInvert() throws {
        let sut = EmptyView().colorInvert()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testColorMultiply() throws {
        let sut = EmptyView().colorMultiply(.red)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testSaturation() throws {
        let sut = EmptyView().saturation(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testGrayscale() throws {
        let sut = EmptyView().grayscale(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testHueRotation() throws {
        let sut = EmptyView().hueRotation(Angle(degrees: 5))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLuminanceToAlpha() throws {
        let sut = EmptyView().luminanceToAlpha()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testShadow() throws {
        let sut = EmptyView().shadow(color: .red, radius: 5, x: 5, y: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBorder() throws {
        let sut = EmptyView().border(Color.primary, width: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBlendMode() throws {
        let sut = EmptyView().blendMode(.darken)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testCompositingGroup() throws {
        let sut = EmptyView().compositingGroup()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - ViewHidingTests

final class ViewHidingTests: XCTestCase {
    
    func testHidden() throws {
        let sut = EmptyView().hidden()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testDisabled() throws {
        let sut = EmptyView().disabled(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
