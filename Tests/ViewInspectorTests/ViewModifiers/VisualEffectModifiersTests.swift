import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewGraphicalEffectsTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewGraphicalEffectsTests: XCTestCase {
    
    func testBlur() throws {
        let sut = EmptyView().blur(radius: 5, opaque: true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBlurInspection() throws {
        let sut = try EmptyView().blur(radius: 5, opaque: true)
            .inspect().emptyView().blur()
        XCTAssertEqual(sut.radius, 5)
        XCTAssertTrue(sut.isOpaque)
    }
    
    func testOpacity() throws {
        let sut = EmptyView().opacity(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOpacityInspection() throws {
        let sut = try EmptyView().opacity(5).inspect().emptyView().opacity()
        XCTAssertEqual(sut, 5)
    }
    
    func testBrightness() throws {
        let sut = EmptyView().brightness(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBrightnessInspection() throws {
        let sut = try EmptyView().brightness(5).inspect().emptyView().brightness()
        XCTAssertEqual(sut, 5)
    }
    
    func testContrast() throws {
        let sut = EmptyView().contrast(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testContrastInspection() throws {
        let sut = try EmptyView().contrast(5).inspect().emptyView().contrast()
        XCTAssertEqual(sut, 5)
    }
    
    func testColorInvert() throws {
        let sut = EmptyView().colorInvert()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testColorInvertInspection() throws {
        XCTAssertNoThrow(try EmptyView().colorInvert().inspect().emptyView().colorInvert())
        XCTAssertThrows(
            try EmptyView().padding().inspect().emptyView().colorInvert(),
            "EmptyView does not have 'colorInvert' modifier")
    }
    
    func testColorMultiply() throws {
        let sut = EmptyView().colorMultiply(.red)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testColorMultiplyInspection() throws {
        let sut = try EmptyView().colorMultiply(.red).inspect().emptyView().colorMultiply()
        XCTAssertEqual(sut, .red)
    }
    
    func testSaturation() throws {
        let sut = EmptyView().saturation(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testSaturationInspection() throws {
        let sut = try EmptyView().saturation(5).inspect().emptyView().saturation()
        XCTAssertEqual(sut, 5)
    }
    
    func testGrayscale() throws {
        let sut = EmptyView().grayscale(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testGrayscaleInspection() throws {
        let sut = try EmptyView().grayscale(5).inspect().emptyView().grayscale()
        XCTAssertEqual(sut, 5)
    }
    
    func testHueRotation() throws {
        let sut = EmptyView().hueRotation(.degrees(5))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testHueRotationInspection() throws {
        let angle = Angle(degrees: 5)
        let sut = try EmptyView().hueRotation(angle).inspect().emptyView().hueRotation()
        XCTAssertEqual(sut, angle)
    }
    
    func testLuminanceToAlpha() throws {
        let sut = EmptyView().luminanceToAlpha()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLuminanceToAlphaInspection() throws {
        XCTAssertNoThrow(try EmptyView().luminanceToAlpha().inspect().emptyView().luminanceToAlpha())
        XCTAssertThrows(
            try EmptyView().padding().inspect().emptyView().luminanceToAlpha(),
            "EmptyView does not have 'luminanceToAlpha' modifier")
    }
    
    func testShadow() throws {
        let sut = EmptyView().shadow(color: .red, radius: 5, x: 5, y: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testShadowInspection() throws {
        let sut = try EmptyView().shadow(color: .red, radius: 5, x: 6, y: 7)
            .inspect().emptyView().shadow()
        XCTAssertEqual(sut.color, .red)
        XCTAssertEqual(sut.radius, 5)
        XCTAssertEqual(sut.offset, CGSize(width: 6, height: 7))
    }
    
    func testBorder() throws {
        let sut = EmptyView().border(Color.primary, width: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBorderInspection() throws {
        let gradient = LinearGradient(gradient: Gradient(colors: [.red]),
                                      startPoint: .bottom, endPoint: .top)
        let sut = try EmptyView().border(gradient, width: 7)
            .inspect().emptyView().border(LinearGradient.self)
        XCTAssertEqual(sut.content, gradient)
        XCTAssertEqual(sut.width, 7)
    }
    
    func testBlendMode() throws {
        let sut = EmptyView().blendMode(.darken)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBlendModeInspection() throws {
        let sut = try EmptyView().blendMode(.darken).inspect().emptyView().blendMode()
        XCTAssertEqual(sut, .darken)
    }
    
    func testCompositingGroup() throws {
        let sut = EmptyView().compositingGroup()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testDrawingGroup() throws {
        let sut = Rectangle().drawingGroup()
        XCTAssertNoThrow(try sut.inspect().shape())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension LinearGradient: BinaryEquatable { }

// MARK: - ViewMaskingTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewMaskingTests: XCTestCase {
    
    func testClipped() throws {
        let sut = EmptyView().clipped(antialiased: false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testClippedInspection() throws {
        let sut = try EmptyView().clipped(antialiased: false).inspect().emptyView()
        XCTAssertNoThrow(try sut.clipShape(Rectangle.self))
        let isAntialiased = try sut.clipStyle().isAntialiased
        XCTAssertFalse(isAntialiased)
    }
    
    func testClipShape() throws {
        let sut = EmptyView().clipShape(Capsule(), style: FillStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testClipShapeInspection() throws {
        let style = FillStyle()
        let sut = try EmptyView().clipShape(Capsule(), style: style).inspect().emptyView()
        XCTAssertNoThrow(try sut.clipShape(Capsule.self))
        let sutStyle = try sut.clipStyle()
        XCTAssertEqual(sutStyle, style)
    }
    
    func testCornerRadius() throws {
        let sut = EmptyView().cornerRadius(5, antialiased: false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testCornerRadiusInspection() throws {
        let sut = try EmptyView().cornerRadius(5, antialiased: false)
            .inspect().emptyView().cornerRadius()
        XCTAssertEqual(sut, 5)
    }
    
    func testMask() throws {
        let sut = EmptyView().mask(Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMaskInspection() throws {
        let string = "abc"
        let sut = try EmptyView().mask(Text(string))
            .inspect().emptyView().mask().text().string()
        XCTAssertEqual(sut, string)
    }
    
    func testMaskSearch() throws {
        let view = EmptyView().mask(Text("test"))
        XCTAssertNoThrow(try view.inspect().find(text: "test"))
    }
}

// MARK: - ViewHidingTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewHidingTests: XCTestCase {
    
    func testHidden() throws {
        let sut = EmptyView().hidden()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testHiddenInspection() throws {
        let sut1 = try EmptyView().hidden().inspect().emptyView()
        XCTAssertTrue(sut1.isHidden())
        let sut2 = try EmptyView().padding().inspect().emptyView()
        XCTAssertFalse(sut2.isHidden())
    }
    
    func testDisabled() throws {
        let sut = EmptyView().disabled(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testDisabledInspection() throws {
        let sut1 = EmptyView().disabled(true)
        let sut2 = EmptyView().disabled(false)
        let sut3 = EmptyView().padding()
        XCTAssertTrue(try sut1.inspect().emptyView().isDisabled())
        XCTAssertFalse(try sut2.inspect().emptyView().isDisabled())
        XCTAssertThrows(try sut3.inspect().emptyView().isDisabled(),
                        "EmptyView does not have 'disabled' modifier")
    }
}
