import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewGestureActionTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewGestureActionTests: XCTestCase {
    
    #if !os(tvOS)
    func testOnTapGesture() throws {
        let sut = EmptyView().onTapGesture(count: 5, perform: { })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnTapGestureInspection() throws {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().onTapGesture {
            exp.fulfill()
        }.onLongPressGesture { }
        try sut.inspect().emptyView().callOnTapGesture()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnLongPressGesture() throws {
        let sut = EmptyView().onLongPressGesture { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnLongPressGestureInspection() throws {
        let exp = XCTestExpectation(description: "onLongPressGesture")
        let sut = EmptyView().onLongPressGesture {
            exp.fulfill()
        }.onTapGesture { }
        try sut.inspect().emptyView().callOnLongPressGesture()
        wait(for: [exp], timeout: 0.1)
    }
    #endif
}
