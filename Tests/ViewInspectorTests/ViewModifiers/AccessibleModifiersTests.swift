import XCTest
import SwiftUI
@testable import ViewInspector

final class AccessibleModifiersTests: XCTestCase {
    
    func testOnAppear() throws {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().padding().onAppear {
            exp.fulfill()
        }.padding().onDisappear(perform: { })
        try sut.inspect().emptyView().callOnAppear()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnDisappear() throws {
        let exp = XCTestExpectation(description: "onDisappear")
        let sut = EmptyView().onAppear(perform: { }).padding()
            .onDisappear {
                exp.fulfill()
            }.padding()
        try sut.inspect().emptyView().callOnDisappear()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testModifierIsNotPresent() throws {
        let sut = EmptyView().padding()
        XCTAssertThrowsError(try sut.inspect().emptyView().callOnAppear())
    }
    
    func testModifierAttributeIsNotPresent() throws {
        let sut = EmptyView().onDisappear().padding()
        XCTAssertThrowsError(try sut.inspect().emptyView().callOnAppear())
    }
}
