import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewAnimationsTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewAnimationsTests: XCTestCase {
    
    func testAnimation() throws {
        let sut = EmptyView().animation(.easeInOut)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAnimationValue() throws {
        let sut = EmptyView().animation(.easeInOut, value: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransition() throws {
        let sut = EmptyView().transition(.slide)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransaction() throws {
        let sut = EmptyView().transaction { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransactionInspection() throws {
        let exp = XCTestExpectation(description: "transaction")
        let sut = EmptyView().transaction { _ in
            exp.fulfill()
        }
        try sut.inspect().emptyView().callTransaction()
        wait(for: [exp], timeout: 0.1)
    }
}
