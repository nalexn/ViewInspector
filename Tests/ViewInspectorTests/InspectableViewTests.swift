import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class InspectableViewTests: XCTestCase {
    
    func testBasicInspectionFunctions() throws {
        let view = Text("abc")
        XCTAssertEqual(try view.inspect().text().string(), "abc")
        view.inspect { view in
            XCTAssertEqual(try view.text().string(), "abc")
        }
    }
    
    func testIsResponsive() throws {
        let view1 = Button("", action: { }).padding()
        let view2 = Button("", action: { }).allowsHitTesting(true).padding()
        let view3 = Button("", action: { }).disabled(false).padding()
        
        let view4 = Button("", action: { }).allowsHitTesting(false).padding()
        let view5 = Button("", action: { }).disabled(true).padding()
        let view6 = Button("", action: { }).hidden().padding()
        
        XCTAssertTrue(try view1.inspect().isResponsive())
        XCTAssertTrue(try view2.inspect().isResponsive())
        XCTAssertTrue(try view3.inspect().isResponsive())
        XCTAssertFalse(try view4.inspect().isResponsive())
        XCTAssertFalse(try view5.inspect().isResponsive())
        XCTAssertFalse(try view6.inspect().isResponsive())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class InspectableViewTestsAccessTests: XCTestCase {
    
    func testSequence() throws {
        let view = HStack { Text("Test") }
        var sut = try view.inspect().hStack().makeIterator()
        XCTAssertNotNil(sut.next())
        XCTAssertNil(sut.next())
    }
    
    func testRandomAccessCollection() throws {
        let view = HStack {
            Text("1").padding(); Text("2"); Text("3")
        }
        let sut = try view.inspect().hStack()
        let array = try sut.map { try $0.text().string() }
        XCTAssertEqual(array, ["1", "2", "3"])
        var iterator = sut.makeIterator()
        for _ in 0 ..< 3 {
            XCTAssertNotNil(iterator.next())
        }
        XCTAssertNil(iterator.next())
        XCTAssertEqual(sut.underestimatedCount, 3)
    }
}
