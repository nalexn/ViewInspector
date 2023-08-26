import XCTest
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewThatFitsTests: XCTestCase {
    
    func testAllEnclosedChildTextViews() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
        else { throw XCTSkip() }
        let sut = TestViewThatFits()
        let shortString = TestViewThatFits.shortString
        let longString = TestViewThatFits.longString
        let longText = try sut.inspect().find(text: longString)
        let shortText = try sut.inspect().find(text: shortString)

        XCTAssertEqual(try longText.string(), longString)
        XCTAssertEqual(try shortText.string(), shortString)
    }
}

// MARK: - TestViewThatFits

@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
private struct TestViewThatFits: View {
    
    static var longString: String {
        "Very long text that will only get picked if there is available space."
    }
    
    static var shortString: String {
        "Short text"
    }
    
    var body: some View {
        ViewThatFits {
            Text(Self.longString)
            Text(Self.shortString)
        }
    }
}
