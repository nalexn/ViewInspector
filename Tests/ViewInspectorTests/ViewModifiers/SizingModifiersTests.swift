import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewPaddingTests

final class ViewPaddingTests: XCTestCase {
    
    func testPadding() throws {
        let sut = EmptyView().padding(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPaddingInspection() throws {
        let sut = try EmptyView().padding(5).inspect().emptyView().padding()
        XCTAssertEqual(sut, EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
    
    func testPaddingEdgeInsets() throws {
        let sut = EmptyView().padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPaddingEdgeInsetsInspection() throws {
        let edges = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let sut = try EmptyView().padding(edges).inspect().emptyView().padding()
        XCTAssertEqual(sut, edges)
    }
    
    func testPaddingEdgeSet() throws {
        let sut = EmptyView().padding([.top], 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPaddingEdgeSetInspection() throws {
        let sut = try EmptyView().padding(.horizontal, 5).inspect().emptyView().padding()
        // Looks like a bug in SwiftUI. All edges are set:
        XCTAssertEqual(sut, EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}
