import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
final class ToolbarTests: XCTestCase {
    
    func testToolbarItemPlacementEquatable() throws {
        #if os(iOS)
        let values: [ToolbarItemPlacement] = [
            .automatic, .principal, .bottomBar, .navigation,
            .navigationBarLeading, .navigationBarTrailing,
            .primaryAction, .cancellationAction, .confirmationAction, .destructiveAction]
        #else
        let values: [ToolbarItemPlacement] = [
            .automatic, .principal, .navigation,
            .primaryAction, .cancellationAction, .confirmationAction, .destructiveAction]
        #endif
        values.enumerated().forEach { lhs in
            values.enumerated().forEach { rhs in
                if lhs.offset == rhs.offset {
                    XCTAssertEqual(lhs.element, rhs.element)
                } else {
                    XCTAssertNotEqual(lhs.element, rhs.element)
                }
            }
        }
    }
    
    func testDoesNotBlockInspection() throws {
        let sut = Group {
            EmptyView().offset().toolbar { Text("") }.padding()
        }
        XCTAssertNoThrow(try sut.inspect().group().emptyView(0).offset())
    }
    
    func testSimpleExtraction() throws {
        let sut = EmptyView()
            .toolbar { ToolbarItem { Text("abc") } }
        let text = try sut.inspect().toolbar().item().text().string()
        XCTAssertEqual(text, "abc")
    }
    
    func testMultipleToolbarsExtraction() throws {
        let sut = EmptyView()
            .toolbar { ToolbarItem { Text("abc1") } }
            .padding()
            .toolbar { ToolbarItem { Text("abc2") } }
        let text1 = try sut.inspect().toolbar().item().text().string()
        XCTAssertEqual(text1, "abc1")
        let text2 = try sut.inspect().toolbar(1).item().text().string()
        XCTAssertEqual(text2, "abc2")
    }
    
    func testMultipleItemsExtraction() throws {
        let sut = EmptyView()
            .toolbar {
                ToolbarItem { Text("1") }
                ToolbarItemGroup {
                    Text("2")
                }
                ToolbarItem { Text("3") }
            }
        let toolbar = try sut.inspect().toolbar()
        XCTAssertEqual(try toolbar.item(0).text().string(), "1")
        XCTAssertEqual(try toolbar.itemGroup(1).text().string(), "2")
        XCTAssertEqual(try toolbar.item(2).text().string(), "3")
    }
    
    func testMultipleChildViewsExtraction() throws {
        let sut = EmptyView()
            .toolbar {
                ToolbarItem { Text("1"); Text("2") }
                ToolbarItemGroup { Text("3"); Text("4") }
            }
        let item = try sut.inspect().toolbar().item(0)
        let itemGroup = try sut.inspect().toolbar().itemGroup(1)
        XCTAssertEqual(try item.text(0).string(), "1")
        XCTAssertEqual(try item.text(1).string(), "2")
        XCTAssertEqual(try itemGroup.text(0).string(), "3")
        XCTAssertEqual(try itemGroup.text(1).string(), "4")
        XCTAssertThrows(try sut.inspect().toolbar().item(2),
                        "View for toolbar item at index 2 is absent")
    }
    
    func testImplicitToolbarItemGroup() throws {
        let sut = EmptyView().toolbar { Text("abc") }
        let text = try sut.inspect().toolbar().itemGroup().text().string()
        XCTAssertEqual(text, "abc")
    }
    
    func testToolbarIdentifier() throws {
        let sut = EmptyView()
            .toolbar { Text("") }
            .toolbar(id: "abc") { ToolbarItem(id: "") { Text("") } }
        XCTAssertNil(try sut.inspect().toolbar(0).identifier())
        XCTAssertEqual(try sut.inspect().toolbar(1).identifier(), "abc")
    }
    
    func testToolbarItemIdentifier() throws {
        let sut = EmptyView().toolbar {
            ToolbarItem(id: "abc") { Text("") }
            ToolbarItem(id: "xyz") { EmptyView() }
        }
        XCTAssertEqual(try sut.inspect().toolbar().item(0).identifier(), "abc")
        XCTAssertEqual(try sut.inspect().toolbar().item(1).identifier(), "xyz")
        XCTAssertThrows(try sut.inspect().toolbar().item(0).id(),
                        "ToolbarItem<String, Text> does not have 'id' modifier")
    }
    
    func testToolbarItemPlacement() throws {
        let sut = EmptyView().toolbar {
            ToolbarItem(placement: .destructiveAction) { EmptyView() }
            ToolbarItem(placement: .principal) { EmptyView() }
            ToolbarItem { EmptyView() }
        }
        let toolbar = try sut.inspect().toolbar()
        XCTAssertEqual(try toolbar.item(0).placement(), .destructiveAction)
        XCTAssertEqual(try toolbar.item(1).placement(), .principal)
        XCTAssertEqual(try toolbar.item(2).placement(), .automatic)
    }
    
    func testToolbarItemGroupPlacement() throws {
        let sut = EmptyView().toolbar {
            ToolbarItemGroup(placement: .destructiveAction) { EmptyView() }
            ToolbarItemGroup(placement: .principal) { EmptyView() }
            ToolbarItemGroup { EmptyView() }
        }
        let toolbar = try sut.inspect().toolbar()
        XCTAssertEqual(try toolbar.itemGroup(0).placement(), .destructiveAction)
        XCTAssertEqual(try toolbar.itemGroup(1).placement(), .principal)
        XCTAssertEqual(try toolbar.itemGroup(2).placement(), .automatic)
    }
    
    func testToolbarItemShowsByDefault() throws {
        let sut = EmptyView().toolbar {
            ToolbarItem(id: "", showsByDefault: false) { EmptyView() }
            ToolbarItem { EmptyView() }
        }
        let toolbar = try sut.inspect().toolbar()
        XCTAssertFalse(try toolbar.item(0).showsByDefault())
        XCTAssertTrue(try toolbar.item(1).showsByDefault())
    }
    
    func testSearchAndPathToRoot() throws {
        let sut = Group {
            EmptyView()
                .toolbar {
                    ToolbarItem { Text("1"); Text("2") }
                    ToolbarItemGroup { HStack { Text("3"); Text("4") } }
                }
                .padding()
                .toolbar {
                    ToolbarItem { Text("5") }
                }
        }
        XCTAssertEqual(try sut.inspect().find(text: "2").pathToRoot,
                       "group().emptyView(0).toolbar().item(0).text(1)")
        XCTAssertEqual(try sut.inspect().find(text: "3").pathToRoot,
                       "group().emptyView(0).toolbar().itemGroup(1).hStack().text(0)")
        XCTAssertEqual(try sut.inspect().find(text: "5").pathToRoot,
                       "group().emptyView(0).toolbar(1).item(0).text()")
    }
}
