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
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 4)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Text("Test").modifier(TestModifier()))
        XCTAssertEqual(try view.inspect().anyView().text().content.medium.viewModifiers.count, 1)
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
        }
        XCTAssertEqual(try view.inspect().hStack().text(0).content.medium.viewModifiers.count, 1)
        XCTAssertEqual(try view.inspect().hStack().text(1).content.medium.viewModifiers.count, 1)
    }
    
    func testModifiedContent() throws {
        var sut = InspectableTestModifier()
        let exp = XCTestExpectation(description: #function)
        sut.didAppear = { body in
            body.inspect { view in
                XCTAssertEqual(try view.hStack().viewModifierContent(1).padding().top, 15)
            }
            ViewHosting.expel()
            exp.fulfill()
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testAppliedModifierInspection() throws {
        let view1 = EmptyView().modifier(TestModifier())
        let sut1 = try view1.inspect().emptyView().modifier(TestModifier.self)
        let content1 = try sut1.viewModifierContent()
        XCTAssertNoThrow(try content1.callOnAppear())
        XCTAssertEqual(content1.pathToRoot,
                       "emptyView().modifier(TestModifier.self).viewModifierContent()")
        let view2 = EmptyView().modifier(InspectableTestModifier())
        let sut2 = try view2.inspect().emptyView().modifier(InspectableTestModifier.self)
        let content2 = try sut2.hStack().viewModifierContent(1)
        XCTAssertEqual(try content2.padding().top, 15)
        XCTAssertEqual(content2.pathToRoot,
        "emptyView().modifier(InspectableTestModifier.self).hStack().viewModifierContent(1)")
        let view3 = EmptyView().padding()
        XCTAssertThrows(try view3.inspect().emptyView().modifier(TestModifier.self),
                        "EmptyView does not have 'TestModifier' modifier")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestModifier: ViewModifier, Inspectable {
    func body(content: Self.Content) -> some View {
        content.onAppear(perform: { })
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableTestModifier: ViewModifier, Inspectable {
    
    var didAppear: ((Self) -> Void)?
    
    func body(content: Self.Content) -> some View {
        HStack {
            EmptyView()
            content
                .padding(.top, 15)
        }
        .onAppear { self.didAppear?(self) }
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
