import XCTest
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
final class ViewThatFitsTests: XCTestCase {
    func testAllEnclosedChildTextViews() throws {
        let sut = TestViewThatFits()
        let longText = try sut.inspect().find(text: "Very long text that will only get picked if there is available space.")
        let shortText = try sut.inspect().find(text: "Short text")

        XCTAssertEqual(try longText.string(), "Very long text that will only get picked if there is available space.")
        XCTAssertEqual(try shortText.string(), "Short text")
    }
}

// MARK: - TestViewThatFits

@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
struct TestViewThatFits: View {
    var body: some View {
        ViewThatFits {
            Text("Very long text that will only get picked if there is available space.")
            Text("Short text")
        }
    }
}
