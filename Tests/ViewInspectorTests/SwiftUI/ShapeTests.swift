import XCTest
import SwiftUI
@testable import ViewInspector

final class ShapeTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Rectangle())
        XCTAssertNoThrow(try view.inspect().anyView().shape())
        XCTAssertThrows(
            try EmptyView().inspect().shape(),
            "Type mismatch: EmptyView is not InspectableShape")
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { Rectangle(); Circle() }
        XCTAssertNoThrow(try view.inspect().hStack().shape(0))
        XCTAssertNoThrow(try view.inspect().hStack().shape(1))
        XCTAssertThrows(
            try HStack { EmptyView() }.inspect().hStack().shape(0),
            "Type mismatch: EmptyView is not InspectableShape")
    }
    
    func testActualShape() throws {
        let shape = RoundedRectangle(cornerRadius: 3, style: .continuous)
            .offset().rotation(.degrees(30))
        let sut = try shape.inspect().shape().actualShape(RoundedRectangle.self)
        XCTAssertEqual(sut.cornerSize, CGSize(width: 3, height: 3))
        XCTAssertThrows(
            try shape.inspect().shape().actualShape(Circle.self),
            "Type mismatch: RoundedRectangle is not Circle")
    }
    
    func testShapeModifiers() throws {
        XCTAssertNoThrow(try Ellipse().inset(by: 5).inspect().shape()) // _Inset
        XCTAssertNoThrow(try Ellipse().size(width: 10, height: 20).inspect().shape()) // _SizedShape
        XCTAssertNoThrow(try Ellipse().stroke().inspect().shape()) // _StrokedShape
        XCTAssertNoThrow(try Ellipse().trim(from: 5, to: 10).inspect().shape()) // _TrimmedShape
        XCTAssertNoThrow(try Ellipse().fill().inspect().shape()) // _ShapeView
    }
    
    func testPath() throws {
        let shape = Ellipse().inset(by: 50)
            .offset(x: 10, y: 20).rotation(.degrees(30))
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
    
    func testInset() throws {
        let shape = Ellipse().inset(by: 10)
        let sut = try shape.inspect().shape().inset()
        XCTAssertEqual(sut, 10)
    }
    
    func testInsetBlockingInspection() throws {
        let shape1 = Ellipse().inset(by: 5)
        let shape2 = Ellipse().offset().inset(by: 5)
        let sut1 = try shape1.inspect().shape()
        let sut2 = try shape2.inspect().shape()
        let rect = CGRect(x: 0, y: 0, width: 5, height: 5)
        XCTAssertThrows(
            try sut1.path(in: rect),
            "ViewInspector: Please put a void '.offset()' modifier before or after '.inset(by:)'")
        XCTAssertThrows(
            try sut1.actualShape(Ellipse.self),
            "ViewInspector: Modifier '.inset(by:)' is blocking Shape inspection")
        XCTAssertNoThrow(try sut2.path(in: rect))
        XCTAssertThrows(
            try sut2.actualShape(Ellipse.self),
            "ViewInspector: Modifier '.inset(by:)' is blocking Shape inspection")
    }
    
    func testOffset() throws {
        let offset = CGSize(width: 10, height: 20)
        let view = Ellipse().offset(offset)
        let sut = try view.inspect().shape().offset()
        XCTAssertEqual(sut, offset)
    }
    
    func testScale() throws {
        let scaleFactor = CGPoint(x: 0.4, y: 0.9)
        let anchor = UnitPoint.topLeading
        let view = Ellipse().scale(x: scaleFactor.x, y: scaleFactor.y, anchor: anchor)
        let sut = try view.inspect().shape().scale()
        XCTAssertEqual(sut.x, scaleFactor.x)
        XCTAssertEqual(sut.y, scaleFactor.y)
        XCTAssertEqual(sut.anchor, anchor)
    }
    
    func testRotation() throws {
        let angle = Angle(degrees: 35)
        let anchor = UnitPoint.topLeading
        let view = Ellipse().rotation(angle, anchor: anchor)
        let sut = try view.inspect().shape().rotation()
        XCTAssertEqual(sut.angle, angle)
        XCTAssertEqual(sut.anchor, anchor)
    }
    
    func testTransform() throws {
        let transform = CGAffineTransform(translationX: 40, y: -3)
        let view = Ellipse().transform(transform)
        let sut = try view.inspect().shape().transform()
        XCTAssertEqual(sut, transform)
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
        XCTAssertThrows(
            try sut.inspect().shape().size(),
            "Ellipse does not have 'size' attribute")
    }
    
    func testMultipleModifiers() throws {
        let angle = Angle(degrees: 20)
        let offset = CGSize(width: 10, height: 30)
        let inset: CGFloat = 5
        let shape = Ellipse().rotation(angle).offset(offset).inset(by: inset)
        let sut = try shape.inspect().shape()
        XCTAssertEqual(try sut.offset(), offset)
        XCTAssertEqual(try sut.inset(), inset)
        XCTAssertEqual(try sut.rotation().angle, angle)
    }
}
