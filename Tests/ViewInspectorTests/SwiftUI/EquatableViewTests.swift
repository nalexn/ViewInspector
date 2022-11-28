import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class EquatableViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = sampleView.equatable()
        let sut = try view.inspect().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testRetainsModifiers() throws {
        let view = Text("Test").equatable().padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 2)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(EquatableView(content: Text("")))
        XCTAssertNoThrow(try view.inspect().anyView().text())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            EquatableView(content: Text(""))
            EquatableView(content: Text(""))
        }
        XCTAssertNoThrow(try view.inspect().hStack().text(0))
        XCTAssertNoThrow(try view.inspect().hStack().text(1))
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForEquatableView: XCTestCase {
    
    func testEquatable() throws {
        let sut = AnyView(TestView().equatable())
        XCTAssertNoThrow(try sut.inspect().anyView().view(TestView.self))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestView: View, Equatable, InspectableProtocol {
    
    var body: some View { EmptyView() }
    static func == (lhs: Self, rhs: Self) -> Bool { true }
}
