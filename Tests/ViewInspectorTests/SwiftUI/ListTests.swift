import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ListTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = List { sampleView }
        let sut = try view.inspect().list().text(0).content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sampleView = Text("Test")
        let view = List { sampleView }
        XCTAssertThrows(
            try view.inspect().list().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = List { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().list().text(0).content.view as? Text
        let view2 = try view.inspect().list().text(1).content.view as? Text
        let view3 = try view.inspect().list().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testSearch() throws {
        let view = AnyView(List { EmptyView(); Text("abc") })
        XCTAssertEqual(try view.inspect().find(ViewType.List.self).pathToRoot,
                       "anyView().list()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().list().text(1)")
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = List { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().list().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testResetsModifiers() throws {
        let view = List { Text("Test") }.padding()
        let sut = try view.inspect().list().text(0)
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(List { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().list())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = List {
            List { Text("Test") }
            List { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().list().list(0))
        XCTAssertNoThrow(try view.inspect().list().list(1))
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForList: XCTestCase {
    
    func testListRowInsets() throws {
        let sut = EmptyView().listRowInsets(EdgeInsets())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testListRowInsetsInspection() throws {
        let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let sut = EmptyView().listRowInsets(insets)
        XCTAssertEqual(try sut.inspect().listRowInsets(), insets)
    }
    
    func testListRowBackground() throws {
        let sut = EmptyView().listRowBackground(Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testListRowBackgroundInspection() throws {
        let sut = EmptyView().listRowBackground(Text("test").padding())
        XCTAssertEqual(try sut.inspect().listRowBackground().text().string(), "test")
    }
    
    func testListRowBackgroundSearch() throws {
        let sut = EmptyView().listRowBackground(Text("test").padding())
        XCTAssertNoThrow(try sut.inspect().find(text: "test"))
    }

    func testListItemTint() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().listItemTint(.red)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testFixedListItemTint() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().listItemTint(.fixed(.red))
        let tint = try sut.inspect().listItemTint()
        XCTAssertEqual(tint.color, .red)
        XCTAssertTrue(tint.isFixed)
    }

    func testListItemTintColor() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().listItemTint(.red)
        let tint = try sut.inspect().listItemTint()
        XCTAssertEqual(tint.color, .red)
        XCTAssertTrue(tint.isFixed)
    }

    func testPreferredListItemTint() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().listItemTint(.preferred(.red))
        let tint = try sut.inspect().listItemTint()
        XCTAssertEqual(tint.color, .red)
        XCTAssertFalse(tint.isFixed)
    }
    
    func testListStyle() throws {
        let sut = EmptyView().listStyle(DefaultListStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testListStyleInspection() throws {
        let sut = EmptyView().listStyle(DefaultListStyle())
        XCTAssertTrue(try sut.inspect().listStyle() is DefaultListStyle)
    }
}
