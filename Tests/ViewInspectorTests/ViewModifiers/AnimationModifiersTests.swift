import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewAnimationsTests

@MainActor
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
    
    func testAnimationValueInspection() throws {
        let sut = try EmptyView().animation(.easeIn, value: 3).inspect().emptyView()
        XCTAssertEqual(try sut.animation(), .easeIn, "animation of animation(_:value:)")
        XCTAssertEqual(try sut.animationValue(Int.self), 3, "value of animation(_:value:)")
    }

    func testAnimationValueNilAnimationInspection() throws {
        let sut = try EmptyView().animation(nil, value: "s").inspect().emptyView()
        XCTAssertNil(try sut.animation(), "a nil animation is reported as nil")
        XCTAssertEqual(try sut.animationValue(String.self), "s", "value next to a nil animation")
    }

    func testAnimationValueOptionalValueInspection() throws {
        let size: CGSize? = CGSize(width: 1, height: 2)
        let none: CGSize? = nil
        XCTAssertEqual(try EmptyView().animation(.easeIn, value: size)
            .inspect().emptyView().animationValue(CGSize?.self), size, "optional value that is set")
        XCTAssertNil(try EmptyView().animation(.easeIn, value: none)
            .inspect().emptyView().animationValue(CGSize?.self), "optional value that is nil")
    }

    func testAnimationValueChainInspection() throws {
        let sut = try EmptyView()
            .animation(.easeIn, value: 1)
            .animation(.easeOut, value: true)
            .animation(.linear, value: 3)
            .inspect().emptyView()
        XCTAssertEqual(try sut.animation(), .easeIn, "animation() reads the first applied modifier")
        XCTAssertEqual(try sut.animationValue(Int.self), 1, "animationValue(Int.self) reads the first Int value")
        XCTAssertEqual(try sut.animationValue(Bool.self), true, "animationValue(Bool.self) reads the Bool value")
    }

    func testAnimationValueInspectionError() throws {
        let absent = try EmptyView().inspect()
        XCTAssertThrows(try absent.animation(),
                        "EmptyView does not have 'animation' modifier")
        XCTAssertThrows(try absent.animationValue(Int.self),
                        "EmptyView does not have 'animation' modifier")
        let sut = try EmptyView().animation(.easeIn, value: 3).inspect()
        XCTAssertThrows(try sut.animationValue(String.self),
                        "EmptyView does not have 'animation' modifier")
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
