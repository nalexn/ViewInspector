import XCTest
import SwiftUI
@testable import ViewInspector

#if os(macOS)

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
final class TouchBarTests: XCTestCase {
    
    func testEnclosedView() throws {
        let view = EmptyView().touchBar(TouchBar(content: { Text("Test") }))
        let sut = try view.inspect().emptyView().touchBar().text().string()
        XCTAssertEqual(sut, "Test")
    }
    
    func testTouchBarID() throws {
        let view = EmptyView().touchBar(TouchBar(id: "abc", content: { Text("") }))
        let sut = try view.inspect().emptyView().touchBar().touchBarID()
        XCTAssertEqual(sut, "abc")
    }
    
    func testSearch() throws {
        let view = EmptyView().touchBar { Text("abc") }
        XCTAssertEqual(try view.inspect().find(ViewType.TouchBar.self).pathToRoot,
                       "emptyView().touchBar()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "emptyView().touchBar().text()")
    }
}

// MARK: - View Modifiers

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
final class GlobalModifiersForTouchBar: XCTestCase {
    
    func testTouchBar() throws {
        let sut = EmptyView().touchBar(TouchBar(content: { Text("") }))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTouchBarInspection() throws {
        let view = EmptyView().touchBar(TouchBar(content: { Text("") })).padding()
        let sut = try view.inspect().emptyView().touchBar()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testTouchBarItemPrincipal() throws {
        let sut = EmptyView().touchBarItemPrincipal(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTouchBarItemPrincipalInspection() throws {
        let sut1 = try EmptyView().touchBarItemPrincipal(true)
            .inspect().emptyView().touchBarItemPrincipal()
        XCTAssertTrue(sut1)
        let sut2 = try EmptyView().touchBarItemPrincipal(false)
            .inspect().emptyView().touchBarItemPrincipal()
        XCTAssertFalse(sut2)
    }
    
    func testTouchBarCustomizationLabel() throws {
        let sut = EmptyView().touchBarCustomizationLabel(Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTouchBarCustomizationLabelInspection() throws {
        let sut = try EmptyView().touchBarCustomizationLabel(Text("abc"))
            .inspect().emptyView().touchBarCustomizationLabel().string()
        XCTAssertEqual(sut, "abc")
    }
    
    func testTouchBarItemPresence() throws {
        let sut = EmptyView().touchBarItemPresence(.required(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTouchBarItemPresenceInspection() throws {
        let presence: TouchBarItemPresence = .optional("abc")
        let sut = try EmptyView().touchBarItemPresence(presence)
            .inspect().emptyView().touchBarItemPresence()
        XCTAssertEqual(sut, presence)
    }
}

extension TouchBarItemPresence: BinaryEquatable { }

#else

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TouchBarTests: XCTestCase {
    func testNotSupported() throws {
        let view = try EmptyView().inspect()
        XCTAssertThrows(try view.content.touchBar(parent: view, index: 0),
                        "Not supported on this platform")
    }
}

#endif
