import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ImageTests: XCTestCase {
    
    let testImage = testColor.image(CGSize(width: 100, height: 80))
    
    func testImageByName() throws {
        let imageName = "someImage"
        let view = Image(imageName)
        let sut = try view.inspect().image().imageName()
        XCTAssertEqual(sut, imageName)
    }
    
    func testExternalImage() throws {
        #if os(iOS) || os(tvOS)
        let view = Image(uiImage: testImage)
        let sut = try view.inspect().image().uiImage()
        #else
        let view = Image(nsImage: testImage)
        let sut = try view.inspect().image().nsImage()
        #endif
        XCTAssertEqual(sut, testImage)
    }
    
    func testExtractionWithModifiers() throws {
        let view = AnyView(imageView().resizable().interpolation(.low))
        #if os(iOS) || os(tvOS)
        let image = try view.inspect().anyView().image().uiImage()
        #else
        let image = try view.inspect().anyView().image().nsImage()
        #endif
        XCTAssertEqual(image, testImage)
    }
    
    func testExtractionCGImage() throws {
        let cgImage = testImage.cgImage!
        let view = Image(cgImage, scale: 2.0, orientation: .down, label: Text("CGImage").bold())
        let image = try view.inspect().image().cgImage()
        let scale = try view.inspect().image().scale()
        let orientation = try view.inspect().image().orientation()
        let label = try view.inspect().image().labelView().string()
        XCTAssertEqual(image, cgImage)
        XCTAssertEqual(scale, 2.0)
        XCTAssertEqual(orientation, .down)
        XCTAssertEqual(label, "CGImage")
        #if os(iOS) || os(tvOS)
        let uiImage = try view.inspect().image().uiImage()
        XCTAssertNil(uiImage)
        #else
        let nsImage = try view.inspect().image().nsImage()
        XCTAssertNil(nsImage)
        #endif
    }
    
    func textDeprecatedLabel() throws {
        let cgImage = testImage.cgImage!
        let view = Image(cgImage, scale: 2.0, orientation: .down, label: Text("CGImage").bold())
        XCTAssertNoThrow(try view.inspect().image().label())
    }
    
    func testExtractionNilCGImage() throws {
        let cgImage = unsafeBitCast(testColor.cgColor, to: CGImage.self)
        let view = Image(cgImage, scale: 2.0, orientation: .down, label: Text("CGImage"))
        XCTAssertNil(try view.inspect().image().cgImage())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(imageView())
        XCTAssertNoThrow(try view.inspect().anyView().image())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { imageView(); imageView() }
        XCTAssertNoThrow(try view.inspect().hStack().image(0))
        XCTAssertNoThrow(try view.inspect().hStack().image(1))
    }
    
    private func imageView() -> Image {
        #if os(iOS) || os(tvOS)
        return Image(uiImage: testImage)
        #else
        return Image(nsImage: testImage)
        #endif
    }
}

#if os(iOS) || os(tvOS)
extension UIColor {
    func image(_ size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
            setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
#else
extension NSColor {
    func image(_ size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        drawSwatch(in: NSRect(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
}
extension NSImage {
    var cgImage: CGImage? {
        cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}
#endif

#if os(iOS) || os(tvOS)
let testColor = UIColor.red
#else
let testColor = NSColor.red
#endif
