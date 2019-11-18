import XCTest
import SwiftUI
@testable import ViewInspector

final class ImageTests: XCTestCase {
    
    let testImage = testColor.image(CGSize(width: 100, height: 80))
    
    func testImageByName() throws {
        let imageName = "someImage"
        let view = Image(imageName)
        let sut = try view.inspect().imageName()
        XCTAssertEqual(sut, imageName)
    }
    
    func testExternalImage() throws {
        #if os(iOS) || os(watchOS) || os(tvOS)
        let view = Image(uiImage: testImage)
        let sut = try view.inspect().uiImage()
        #else
        let view = Image(nsImage: testImage)
        let sut = try view.inspect().nsImage()
        #endif
        XCTAssertEqual(sut, testImage)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(imageView())
        XCTAssertNoThrow(try view.inspect().image())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { imageView(); imageView() }
        XCTAssertNoThrow(try view.inspect().image(0))
        XCTAssertNoThrow(try view.inspect().image(1))
    }
    
    private func imageView() -> Image {
        #if os(iOS) || os(watchOS) || os(tvOS)
        return Image(uiImage: testImage)
        #else
        return Image(nsImage: testImage)
        #endif
    }
    
    static var allTests = [
        ("testImageByName", testImageByName),
        ("testExternalImage", testExternalImage),
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
    ]
}

#if os(iOS) || os(watchOS) || os(tvOS)
private extension UIColor {
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
private extension NSColor {
    func image(_ size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        drawSwatch(in: NSRect(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
}
#endif

#if os(iOS) || os(watchOS) || os(tvOS)
let testColor = UIColor.red
#else
let testColor = NSColor.red
#endif
