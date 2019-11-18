import XCTest
import SwiftUI
@testable import ViewInspector

final class ImageTests: XCTestCase {
    
    let testImage = UIColor.red.image(CGSize(width: 100, height: 80))
    
    func testImageByName() throws {
        let imageName = "someImage"
        let view = Image(imageName)
        let sut = try view.inspect().imageName()
        XCTAssertEqual(sut, imageName)
    }
    
    func testExternalImage() throws {
        let view = Image(uiImage: testImage)
        let sut = try view.inspect().uiImage()
        XCTAssertEqual(sut, testImage)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Image(uiImage: testImage))
        XCTAssertNoThrow(try view.inspect().image())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { Image(uiImage: testImage); Image(uiImage: testImage) }
        XCTAssertNoThrow(try view.inspect().image(0))
        XCTAssertNoThrow(try view.inspect().image(1))
    }
    
    static var allTests = [
        ("testImageByName", testImageByName),
        ("testExternalImage", testExternalImage),
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
    ]
}

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
