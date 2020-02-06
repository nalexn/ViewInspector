import XCTest
import SwiftUI
@testable import ViewInspector

final class EnvironmentReaderViewTests: XCTestCase {
    
    #if os(iOS) || os(tvOS)
    
    func testIncorrectUnwrap() throws {
        let view = NavigationView {
            List { Text("") }
                .navigationBarItems(trailing: Text(""))
        }
        XCTAssertThrowsError(try view.inspect().navigationView().list(0))
    }
    
    func testUnknownHierarchyTypeUnwrap() throws {
        let view = NavigationView {
            List { Text("") }
                .navigationBarItems(trailing: Text(""))
        }
        XCTAssertThrowsError(try view.inspect().navigationView().navigationBarItems().list())
    }
    
    func testKnownHierarchyTypeUnwrap() throws {
        let string = "abc"
        let view = NavigationView {
            List { Text(string) }
                .navigationBarItems(trailing: Text(""))
        }
        let value = try view.inspect().navigationView()
            .navigationBarItems(List<Never, Text>.self)
            .list().text(0).string()
        XCTAssertEqual(value, string)
    }
    
    func testRetainsModifiers() throws {
        let view = NavigationView {
            Text("")
                .padding()
                .navigationBarItems(trailing: Text(""))
                .padding().padding()
        }
        let sut = try view.inspect().navigationView()
            .navigationBarItems(ModifiedContent<Text, _PaddingLayout>.self)
            .text()
        XCTAssertEqual(sut.content.modifiers.count, 4)
    }
    
    func testMissingModifier() throws {
        let sut = EmptyView().padding()
        XCTAssertThrowsError(try sut.inspect().navigationBarItems())
    }
    #endif
}
