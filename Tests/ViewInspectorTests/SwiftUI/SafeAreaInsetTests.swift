import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS) // requires macOS SDK 12.0
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class SafeAreaInsetTests: XCTestCase {
    
    func testInspectionNotBlocked() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut = EmptyView().safeAreaInset(edge: .bottom) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testInspectionErrorNoModifier() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().safeAreaInset(),
                        "EmptyView does not have 'safeAreaInset' modifier")
    }
    
    func testSimpleUnwrap() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut = EmptyView().safeAreaInset(edge: .bottom) { Text("") }
        XCTAssertEqual(try sut.inspect().emptyView().safeAreaInset().pathToRoot,
                       "emptyView().safeAreaInset()")
    }
    
    func testContentUnwrap() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut = EmptyView().safeAreaInset(edge: .bottom) { Text("abc") }
        let text = try sut.inspect().safeAreaInset().text()
        XCTAssertEqual(try text.string(), "abc")
    }
    
    func testEdge() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut = EmptyView().safeAreaInset(edge: .bottom) { Text("") }
        XCTAssertEqual(try sut.inspect().safeAreaInset().edge(), .bottom)
    }
    
    func testSpacing() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut1 = EmptyView().safeAreaInset(edge: .bottom, spacing: 19) { Text("") }
        let sut2 = EmptyView().safeAreaInset(edge: .bottom) { Text("") }
        XCTAssertEqual(try sut1.inspect().safeAreaInset().spacing(), 19)
        XCTAssertNil(try sut2.inspect().safeAreaInset().spacing())
    }
    
    func testRegions() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut = EmptyView().safeAreaInset(edge: .bottom) { Text("") }
        XCTAssertEqual(try sut.inspect().safeAreaInset().regions(), .container)
    }
    
    func testSearch() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut = Group {
            EmptyView()
            Text("")
                .safeAreaInset(edge: .top) { EmptyView(); Text("1") }
                .padding()
                .safeAreaInset(edge: .leading) { Text("2") }
        }
        XCTAssertEqual(try sut.inspect().find(text: "1").pathToRoot,
                       "group().text(1).safeAreaInset().text(1)")
        XCTAssertEqual(try sut.inspect().find(text: "2").pathToRoot,
                       "group().text(1).safeAreaInset(1).text()")
    }
}
#endif
