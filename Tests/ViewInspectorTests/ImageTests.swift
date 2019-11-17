import XCTest
import SwiftUI
@testable import ViewInspector

final class ImageTests: XCTestCase {
    
    // MARK: - string()
    
    func testImageByName() throws {
        let imageName = "someImage"
        let view = Image(imageName)
        let sut = try view.inspect().imageName()
        XCTAssertEqual(sut, imageName)
    }
    
    func testExternalImage() throws {
        let image = UIColor.red.image(CGSize(width: 100, height: 80))
        let view = Image(uiImage: image)
        let sut = try view.inspect().uiImage()
        XCTAssertEqual(sut, image)
    }
    
    static var allTests = [
        ("testImageByName", testImageByName),
        ("testExternalImage", testExternalImage),
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
