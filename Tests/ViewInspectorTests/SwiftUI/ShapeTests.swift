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
    
    func testActualShape() throws {
        let shape = RoundedRectangle(cornerRadius: 3, style: .continuous)
            .offset().rotation(.init(degrees: 30))
        let sut = try shape.inspect().shape().actualShape(RoundedRectangle.self)
        XCTAssertEqual(sut.cornerSize, CGSize(width: 3, height: 3))
        XCTAssertThrowsError(try shape.inspect().shape().actualShape(Circle.self))
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
    
    func testPathForFilledShape() throws {
        let shape = Ellipse()
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let sut = (shape.fill() as? InspectableShape)?.path(in: rect)
        XCTAssertEqual(sut, shape.path(in: rect))
    }
    
    func testSize() throws {
        let size = CGSize(width: 10, height: 20)
        let view = Ellipse().size(size).offset()
        let sut = try view.inspect().shape().size()
        XCTAssertEqual(sut, size)
    }
    
    func testStrokeStyle() throws {
        let style = StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .miter,
                                miterLimit: 4, dash: [3, 2], dashPhase: 1)
        let view = Ellipse().stroke(style: style).offset()
        let sut = try view.inspect().shape().strokeStyle()
        XCTAssertEqual(sut, style)
    }
    
    func testTrim() throws {
        let view = Ellipse().trim(from: 0.25, to: 0.9).offset()
        let sut = try view.inspect().shape().trim()
        XCTAssertEqual(sut.from, 0.25)
        XCTAssertEqual(sut.to, 0.9)
    }
    
    func testShapeStyle() throws {
        let view = Ellipse().fill(LinearGradient(gradient: Gradient(colors: []),
            startPoint: .top, endPoint: .bottomLeading))
        let gradient = try view.inspect().shape().fillShapeStyle(LinearGradient.self)
        let sut = try gradient.inspect().linearGradient()
        XCTAssertEqual(try sut.startPoint(), UnitPoint.top)
        XCTAssertEqual(try sut.endPoint(), UnitPoint.bottomLeading)
    }
    
    func testFillStyle() throws {
        let fillStyle = FillStyle(eoFill: true, antialiased: false)
        let view = Ellipse().fill(style: fillStyle)
        let sut = try view.inspect().shape().fillStyle()
        XCTAssertEqual(sut, fillStyle)
    }
    
    func testMissingAttribute() throws {
        let sut = Ellipse().offset()
        XCTAssertThrowsError(try sut.inspect().shape().size())
    }
}
