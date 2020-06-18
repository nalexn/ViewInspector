import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ModifiedContentTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = sampleView.modifier(TestModifier())
        let sut = try view.inspect().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testAccumulatesModifiers() throws {
        let view = Text("Test")
            .padding().modifier(TestModifier())
            .padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.modifiers.count, 4)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Text("Test").modifier(TestModifier()))
        XCTAssertEqual(try view.inspect().anyView().text().content.modifiers.count, 1)
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
        }
        XCTAssertEqual(try view.inspect().hStack().text(0).content.modifiers.count, 1)
        XCTAssertEqual(try view.inspect().hStack().text(1).content.modifiers.count, 1)
    }
    
    func testModifiedContent() throws {
        var sut = InspectableTestModifier()
        let exp = XCTestExpectation(description: #function)
        sut.didAppear = { body in
            body.inspect { view in
                XCTAssertEqual(try view.padding().top, 15)
            }
            ViewHosting.expel()
            exp.fulfill()
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestModifier: ViewModifier {
    func body(content: Self.Content) -> some View {
        content.onAppear()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableTestModifier: ViewModifier {
    
    var didAppear: ((Self.Body) -> Void)?
    
    func body(content: Self.Content) -> some View {
        content
            .padding(.top, 15)
            .onAppear { self.didAppear?(self.body(content: content)) }
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForModifiedContent: XCTestCase {
    
    func testModifier() throws {
        let sut = EmptyView().modifier(TestModifier())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
