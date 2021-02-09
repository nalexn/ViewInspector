import XCTest
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class LazyGroupTests: XCTestCase {
    
    func testLazyGroupEmpty() {
        let sut = LazyGroup<Int>.empty
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.underestimatedCount, 0)
    }
    
    func testLazyGroupSequence() {
        let count = 3
        let sut = LazyGroup<Int>(count: count) { $0 }
        XCTAssertEqual(sut.map { $0 }, [0, 1, 2])
        var iterator = sut.makeIterator()
        for _ in 0 ..< count {
            XCTAssertNotNil(iterator.next())
        }
        XCTAssertNil(iterator.next())
    }
    
    func testLazyGroupIterator() throws {
        let sut = LazyGroup<Int>(count: 1) { $0 }
        var iterator = sut.makeIterator()
        XCTAssertNotNil(iterator.next())
        XCTAssertNil(iterator.next())
    }
    
    func testLazyGroupPlusOperator() throws {
        let group1 = LazyGroup<Int>(count: 2) { $0 }
        let group2 = LazyGroup<Int>(count: 3) { $0 }
        let sut = group1 + group2
        XCTAssertEqual(sut.count, group1.count + group2.count)
        XCTAssertEqual(sut.map { $0 }, [0, 1, 0, 1, 2])
    }
}
