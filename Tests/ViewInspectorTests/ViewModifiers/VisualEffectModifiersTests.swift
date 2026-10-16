import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewGraphicalEffectsTests

@MainActor
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
        let sut1 = try EmptyView().border(gradient, width: 7)
            .inspect().emptyView().border(LinearGradient.self)
        XCTAssertEqual(sut1.shapeStyle, gradient)
        XCTAssertEqual(sut1.width, 7)
        
        let borderSimulator = Rectangle()
            .strokeBorder(Color.red, lineWidth: 3, antialiased: true)
        let sut2 = try EmptyView().overlay(borderSimulator).inspect()
        let border = try sut2.border(Color.self)
        XCTAssertEqual(border.width, 3)
        XCTAssertNoThrow(try sut2.overlay().shape())
        
        let sut3 = EmptyView().padding()
        XCTAssertThrows(try sut3.inspect().border(LinearGradient.self),
            "EmptyView does not have 'border' modifier")
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
extension LinearGradient: @retroactive BinaryEquatable { }

// MARK: - ViewMaskingTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct MaskingModifier: ViewModifier {
    func body(content: MaskingModifier.Content) -> some View {
        AnyView(content.mask(Text("inner")))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct ClosureMaskingModifier: ViewModifier {
    func body(content: ClosureMaskingModifier.Content) -> some View {
        AnyView(content.mask { Text("inner") })
    }
}

@MainActor
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
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func testCornerRadii() throws {
        let sut = EmptyView().clipShape(UnevenRoundedRectangle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func testCornerRadiiInspection() throws {
        let cornerRadii: RectangleCornerRadii = .init(topLeading: 1, bottomLeading: 2, bottomTrailing: 3, topTrailing: 4)
        let sut = try EmptyView().clipShape(UnevenRoundedRectangle(cornerRadii: cornerRadii))
            .inspect().emptyView().cornerRadii()
        XCTAssertEqual(sut, cornerRadii)
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

    func testMaskInspectionError() throws {
        let sut = try EmptyView().inspect()
        XCTAssertThrows(try sut.mask(), "EmptyView does not have 'mask' modifier")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMaskClosureInspection() throws {
        let sut = try EmptyView().mask { Text("abc") }.inspect().emptyView()
        XCTAssertEqual(try sut.mask().text().string(), "abc")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMaskAlignmentClosureInspection() throws {
        let sut = try EmptyView().mask(alignment: .bottomTrailing) { Text("abc") }
            .inspect().emptyView()
        XCTAssertEqual(try sut.mask().text().string(), "abc")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMaskClosureMultipleViewsInspection() throws {
        let sut = try EmptyView().mask { Text("1"); Text("2") }.inspect().emptyView()
        XCTAssertEqual(try sut.mask().text(0).string(), "1", "the first view of the mask closure")
        XCTAssertEqual(try sut.mask().text(1).string(), "2", "the second view of the mask closure")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMaskClosureSearch() throws {
        let view = EmptyView().mask { Text("test") }
        XCTAssertEqual(try view.inspect().find(text: "test").pathToRoot,
                       "emptyView().mask().text()", "path to the content of a closure mask")
        XCTAssertEqual(try view.inspect().findAll(ViewType.Text.self).count, 1,
                       "a closure mask is reported once")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMasksOfClosureOverloadInspection() throws {
        let view = EmptyView().mask { Text("X") }.mask { Text("Y") }
        let sut = try view.inspect().emptyView()
        XCTAssertEqual(try sut.mask(0).text().string(), "X", "the closure mask applied first")
        XCTAssertEqual(try sut.mask(1).text().string(), "Y", "the closure mask applied second")
        XCTAssertEqual(try view.inspect().findAll(ViewType.Text.self).count, 2,
                       "each closure mask is reported once")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMasksOfBothOverloadsOldFirstInspection() throws {
        let view = EmptyView().mask(Text("A")).mask { Text("B") }
        let sut = try view.inspect().emptyView()
        XCTAssertEqual(try sut.mask(0).text().string(), "A", "the mask(_:) mask")
        XCTAssertEqual(try sut.mask(1).text().string(), "B", "the closure mask")
        XCTAssertThrows(try sut.mask(2), "EmptyView does not have 'mask' modifier at index 2")
        XCTAssertEqual(try view.inspect().findAll(ViewType.Text.self).count, 2,
                       "each mask is reported once")
        XCTAssertEqual(try view.inspect().find(text: "A").pathToRoot,
                       "emptyView().mask().text()", "path to the mask(_:) mask")
        XCTAssertTrue(try view.inspect().find(text: "B").pathToRoot.hasPrefix("emptyView().mask(1)"),
                      "path to the closure mask goes through mask(1)")
    }

    // The masks of `mask(_:)` keep their indexes, the masks of the closure overload follow them
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMasksOfBothOverloadsClosureFirstInspection() throws {
        let view = EmptyView().mask { Text("B") }.mask(Text("A"))
        let sut = try view.inspect().emptyView()
        XCTAssertEqual(try sut.mask(0).text().string(), "A", "the mask(_:) mask keeps index 0")
        XCTAssertEqual(try sut.mask(1).text().string(), "B", "the closure mask follows")
        XCTAssertEqual(try view.inspect().findAll(ViewType.Text.self).count, 2,
                       "each mask is reported once")
        XCTAssertEqual(try view.inspect().find(text: "A").pathToRoot,
                       "emptyView().mask().text()", "path to the mask(_:) mask")
        XCTAssertTrue(try view.inspect().find(text: "B").pathToRoot.hasPrefix("emptyView().mask(1)"),
                      "path to the closure mask goes through mask(1)")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMasksNestedInMaskContentInspection() throws {
        let view = EmptyView().mask(Text("A").mask { Text("B") }).mask { Text("C") }
        let sut = try view.inspect().emptyView()
        XCTAssertEqual(try sut.mask(0).text().string(), "A", "the mask(_:) mask that has a closure mask inside")
        XCTAssertEqual(try sut.mask(1).text().string(), "C", "the closure mask")
        XCTAssertThrows(try sut.mask(2), "EmptyView does not have 'mask' modifier at index 2")
        XCTAssertEqual(try view.inspect().findAll(ViewType.Text.self).map { try $0.string() }.sorted(),
                       ["A", "B", "C"], "every text is reported once")
    }

    func testMaskInCustomModifierInspection() throws {
        let view = EmptyView().modifier(MaskingModifier()).mask(Text("outer"))
        XCTAssertEqual(try view.inspect().emptyView().mask().text().string(), "outer",
                       "the mask applied outside of the modifier")
        XCTAssertEqual(try view.inspect().findAll(ViewType.Text.self).count, 2,
                       "the outer mask and the mask inside of the modifier, each once")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testMaskClosureInCustomModifierInspection() throws {
        let view = EmptyView().modifier(ClosureMaskingModifier()).mask { Text("outer") }
        XCTAssertEqual(try view.inspect().emptyView().mask().text().string(), "outer",
                       "the closure mask applied outside of the modifier")
        XCTAssertEqual(try view.inspect().findAll(ViewType.Text.self).count, 2,
                       "the outer mask and the mask inside of the modifier, each once")
    }
}

// MARK: - ViewHidingTests

@MainActor
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
        XCTAssertFalse(try sut3.inspect().emptyView().isDisabled())
    }
}

// MARK: - ViewCompositingTests

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewCompositingTests: XCTestCase {

    func testCompositingGroup() throws {
        let sut = EmptyView().compositingGroup()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testCompositingGroupInspection() throws {
        let sut = try EmptyView().compositingGroup().inspect().emptyView()
        XCTAssertNoThrow(try sut.compositingGroup())
    }

    func testCompositingGroupInspectionError() throws {
        let sut = try EmptyView().inspect()
        XCTAssertThrows(try sut.compositingGroup(),
                        "EmptyView does not have 'compositingGroup' modifier")
    }

    func testDrawingGroup() throws {
        let sut = EmptyView().drawingGroup(opaque: true, colorMode: .extendedLinear)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testDrawingGroupInspection() throws {
        XCTAssertEqual(try EmptyView().drawingGroup(opaque: true, colorMode: .extendedLinear)
            .inspect().emptyView().drawingGroup(), .extendedLinear)
        XCTAssertEqual(try EmptyView().drawingGroup()
            .inspect().emptyView().drawingGroup(), .nonLinear)
    }

    func testDrawingGroupInspectionError() throws {
        let sut = try EmptyView().inspect()
        XCTAssertThrows(try sut.drawingGroup(),
                        "EmptyView does not have 'drawingGroup' modifier")
    }
}
