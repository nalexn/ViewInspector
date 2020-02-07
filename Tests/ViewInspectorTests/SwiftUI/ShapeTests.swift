import XCTest
import SwiftUI
@testable import ViewInspector

final class ShapeTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Rectangle())
        XCTAssertNoThrow(try view.inspect().anyView().shape())
        XCTAssertThrowsError(try EmptyView().inspect().shape())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { Rectangle(); Circle() }
        XCTAssertNoThrow(try view.inspect().hStack().shape(0))
        XCTAssertNoThrow(try view.inspect().hStack().shape(1))
        XCTAssertThrowsError(try HStack { EmptyView() }.inspect().hStack().shape(0))
    }
    
    func testInsetShape() throws {
        let sut1 = Rectangle().inset(by: 10)
        let sut2 = HStack { Rectangle().inset(by: 10) }
        XCTAssertThrowsError(try sut1.inspect().shape())
        XCTAssertThrowsError(try sut2.inspect().hStack().shape(0))
    }
    
    func testSpecialShapes() throws {
        XCTAssertNoThrow(try Ellipse().size(width: 10, height: 20).inspect().shape()) // _SizedShape
        XCTAssertNoThrow(try Ellipse().stroke().inspect().shape()) // _StrokedShape
        XCTAssertNoThrow(try Ellipse().trim(from: 5, to: 10).inspect().shape()) // _TrimmedShape
        XCTAssertNoThrow(try Ellipse().fill().inspect().shape()) // _ShapeView
    }
    
    func testPath() throws {
        let shape = Ellipse().inset(by: 50)
            .offset(x: 10, y: 20).rotation(.init(degrees: 30))
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let sut = try shape.inspect().shape().path(in: rect)
        XCTAssertEqual(sut, shape.path(in: rect))
    }
}
