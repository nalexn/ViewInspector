import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewEventsTests

final class ViewEventsTests: XCTestCase {
    
    func testOnAppear() throws {
        let sut = EmptyView().onAppear { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnAppearInspection() throws {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().padding().onAppear {
            exp.fulfill()
        }.padding().onDisappear(perform: { })
        try sut.inspect().emptyView().callOnAppear()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnDisappear() throws {
        let sut = EmptyView().onDisappear { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDisappearInspection() throws {
        let exp = XCTestExpectation(description: "onDisappear")
        let sut = EmptyView().onAppear(perform: { }).padding()
            .onDisappear {
                exp.fulfill()
            }.padding()
        try sut.inspect().emptyView().callOnDisappear()
        wait(for: [exp], timeout: 0.1)
    }
}

// MARK: - ViewPublisherEventsTests

final class ViewPublisherEventsTests: XCTestCase {
    
    func testOnReceive() throws {
        let publisher = Just<Void>(())
        let sut = EmptyView().onReceive(publisher) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
