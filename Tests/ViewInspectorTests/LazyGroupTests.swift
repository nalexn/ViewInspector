import XCTest
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class LazyGroupTests: XCTestCase {
    
    func testEmpty() {
        let sut = LazyGroup<Int>.empty
        XCTAssertEqual(sut.count, 0)
    }
    
    func testElementAtIndex() {
        let count = 3
        let sut = LazyGroup<Int>(count: count) { $0 }
        for index in 0..<count {
            XCTAssertEqual(try sut.element(at: index), index)
        }
        XCTAssertThrows(try sut.element(at: -1),
                        "Enclosed view index '-1' is out of bounds: '0 ..< 3'")
        XCTAssertThrows(try sut.element(at: count),
                        "Enclosed view index '3' is out of bounds: '0 ..< 3'")
    }
    
    func testPlusOperator() throws {
        let group1 = LazyGroup<Int>(count: 2) { $0 }
        let group2 = LazyGroup<Int>(count: 3) { $0 }
        let sut = group1 + group2
        XCTAssertEqual(sut.count, group1.count + group2.count)
        XCTAssertEqual(try sut.element(at: 0), 0)
        XCTAssertEqual(try sut.element(at: 1), 1)
        XCTAssertEqual(try sut.element(at: 2), 0)
        XCTAssertEqual(try sut.element(at: 3), 1)
        XCTAssertEqual(try sut.element(at: 4), 2)
    }
}
