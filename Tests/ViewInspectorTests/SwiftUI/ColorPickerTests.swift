import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class ColorPickerTests: XCTestCase {
    
    func testInspect() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let binding = Binding<CGColor>(wrappedValue: .test)
        XCTAssertNoThrow(try ColorPicker("Test", selection: binding).inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let binding = Binding<CGColor>(wrappedValue: .test)
        let view = AnyView(ColorPicker("Test", selection: binding))
        XCTAssertNoThrow(try view.inspect().anyView().colorPicker())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let binding = Binding<CGColor>(wrappedValue: .test)
        let view = HStack {
            Text("")
            ColorPicker("Test", selection: binding)
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().colorPicker(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let binding = Binding<CGColor>(wrappedValue: .test)
        let view = Group { ColorPicker(selection: binding, label: {
            HStack { Text("abc") }
        }) }
        XCTAssertEqual(try view.inspect().find(ViewType.ColorPicker.self).pathToRoot,
                       "group().colorPicker(0)")
        XCTAssertEqual(try view.inspect().find(ViewType.Text.self).pathToRoot,
                       "group().colorPicker(0).labelView().hStack().text(0)")
    }
    
    func testLabelInspection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let binding = Binding<Color>(wrappedValue: .red)
        let sut = ColorPicker(selection: binding, label: {
            HStack { Text("abc") }
        })
        let string = try sut.inspect().colorPicker().labelView().hStack().text(0).string()
        XCTAssertEqual(string, "abc")
    }
    
    func testColorSelection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        
        let cgColor = CGColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 0.1)
        let binding1 = Binding<CGColor>(wrappedValue: cgColor)
        let sut1 = ColorPicker(selection: binding1) { Text("") }
        XCTAssertEqual(binding1.wrappedValue.rgba(), cgColor.rgba())
        try sut1.inspect().colorPicker().select(color: CGColor.test)
        XCTAssertEqual(binding1.wrappedValue.rgba(), CGColor.test.rgba())
        
        let binding2 = Binding<Color>(wrappedValue: .red)
        let sut2 = ColorPicker(selection: binding2) { Text("") }
        XCTAssertEqual(binding2.wrappedValue.rgba(), Color.red.rgba())
        try sut2.inspect().colorPicker().select(color: Color.yellow)
        XCTAssertEqual(binding2.wrappedValue.rgba(), Color.yellow.rgba())
    }
    
    func testRGBA() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        #if os(macOS)
        XCTAssertNotEqual(NSColor.red.rgba(), Color.red.rgba())
        #else
        XCTAssertNotEqual(UIColor.red.rgba(), Color.red.rgba())
        XCTAssertEqual(CGColor(gray: 1, alpha: 1).rgba(), UIColor.white.rgba())
        XCTAssertEqual(UIColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 0.6).rgba(),
                       CGColor(srgbRed: 0.3, green: 0.4, blue: 0.5, alpha: 0.6).rgba())
        #endif
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private extension CGColor {
    static var test: CGColor {
        return CGColor(gray: 0.4, alpha: 0.9)
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private extension CGColor {
    func rgba() -> ViewType.ColorPicker.RGBA {
        return .init(color: self)
    }
}

#if os(macOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private extension NSColor {
    func rgba() -> ViewType.ColorPicker.RGBA {
        return .init(color: self)
    }
}
#else
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private extension UIColor {
    func rgba() -> ViewType.ColorPicker.RGBA {
        return .init(color: self)
    }
}
#endif

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private extension Color {
    @available(tvOS 14.0, *)
    func rgba() -> ViewType.ColorPicker.RGBA {
        return .init(color: self)
    }
}
