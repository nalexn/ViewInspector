import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ImageTests: XCTestCase {
    
    let testImage = testColor.image(CGSize(width: 100, height: 80))
    
    func testImageByName() throws {
        let imageName = "someImage"
        let image1 = Image(imageName)
        let sut1 = try image1.inspect().image().actualImage().name()
        XCTAssertEqual(sut1, imageName)
        let image2 = Image(testImage.cgImage!, scale: 2.0, orientation: .down, label: Text("abc"))
        XCTAssertThrows(try image2.name(),
                        "CGImageProvider does not have 'name' attribute")
    }
    
    func testRootImage() throws {
        let original = Image("abc")
        let wrapped = original.resizable().antialiased(true)
        XCTAssertNotEqual(original, wrapped)
        let sut = try wrapped.rootImage()
        XCTAssertEqual(sut, original)
    }
    
    func testExternalImage() throws {
        #if !os(macOS)
        let sut = Image(uiImage: testImage)
        let image = try sut.uiImage()
        #else
        let sut = Image(nsImage: testImage)
        let image = try sut.nsImage()
        #endif
        XCTAssertEqual(image, testImage)
    }
    
    func testExtractionWithModifiers() throws {
        let view = AnyView(imageView().resizable().interpolation(.low))
        #if !os(macOS)
        let image = try view.inspect().anyView().image().actualImage().uiImage()
        #else
        let image = try view.inspect().anyView().image().actualImage().nsImage()
        #endif
        XCTAssertEqual(image, testImage)
    }
    
    func testExtractionCGImage() throws {
        let cgImage = testImage.cgImage!
        let image = Image(cgImage, scale: 2.0, orientation: .down, label: Text("CGImage").bold())
        let extractedCGImage = try image.cgImage()
        let scale = try image.scale()
        let orientation = try image.orientation()
        let label = try image.inspect().image().labelView().string()
        XCTAssertEqual(extractedCGImage, cgImage)
        XCTAssertEqual(scale, 2.0)
        XCTAssertEqual(orientation, .down)
        XCTAssertEqual(label, "CGImage")
        #if !os(macOS)
        XCTAssertThrows(try image.uiImage(), "Type mismatch: CGImageProvider is not UIImage")
        #else
        XCTAssertThrows(try image.nsImage(), "Type mismatch: CGImageProvider is not NSImage")
        #endif
    }
    
    func testLabelImageText() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = Label("tx", image: "img")
        let text = try view.inspect().label().icon().image().labelView()
        XCTAssertEqual(try text.string(), "img")
    }
    
    func testLabelSystemImageText() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = Label("tx", systemImage: "img")
        let text = try view.inspect().label().icon().image().labelView()
        XCTAssertEqual(try text.string(), "img")
    }
    
    func testImageSystemName() throws {
        let sut = Image(systemName: "img")
        let text = try sut.inspect().image().labelView()
        XCTAssertEqual(try text.string(), "img")
    }
    
    func testSearch() throws {
        let cgImage = testImage.cgImage!
        let view = AnyView(Image(cgImage, scale: 2.0, orientation: .down, label: Text("abc")).resizable())
        XCTAssertEqual(try view.inspect().find(ViewType.Image.self).pathToRoot,
                       "anyView().image()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().image().labelView().text()")
    }
    
    func testExtractionNilCGImage() throws {
        let cgImage = unsafeBitCast(testColor.cgColor, to: CGImage.self)
        let image = Image(cgImage, scale: 2.0, orientation: .down, label: Text("CGImage"))
        XCTAssertNotNil(try image.cgImage())
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
        #if !os(macOS)
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
#elseif os(watchOS)
extension UIColor {
    func image(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        self.setFill()
        UIRectFill(.init(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
#elseif os(macOS)
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

#if !os(macOS)
let testColor = UIColor.red
#else
let testColor = NSColor.red
#endif
