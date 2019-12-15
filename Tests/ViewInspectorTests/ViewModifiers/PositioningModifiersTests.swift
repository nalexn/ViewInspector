import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewPositioningTests

final class ViewPositioningTests: XCTestCase {
    
    func testPosition() throws {
        let sut = EmptyView().position(CGPoint(x: 5, y: 5))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPositionInspection() throws {
        let point = CGPoint(x: 5, y: 6)
        let sut = try EmptyView().position(point).inspect().emptyView().position()
        XCTAssertEqual(sut, point)
    }
    
    func testPositionXY() throws {
        let sut = EmptyView().position(x: 5, y: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPositionXYInspection() throws {
        let point = CGPoint(x: 5, y: 6)
        let sut = try EmptyView().position(x: point.x, y: point.y)
            .inspect().emptyView().position()
        XCTAssertEqual(sut, point)
    }
    
    func testOffset() throws {
        let sut = EmptyView().offset(CGSize(width: 5, height: 5))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOffsetInspection() throws {
        let size = CGSize(width: 5, height: 6)
        let sut = try EmptyView().offset(size).inspect().emptyView().offset()
        XCTAssertEqual(sut, size)
    }
    
    func testOffsetXY() throws {
        let sut = EmptyView().offset(x: 5, y: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOffsetXYInspection() throws {
        let size = CGSize(width: 5, height: 6)
        let sut = try EmptyView().offset(x: size.width, y: size.height)
            .inspect().emptyView().offset()
        XCTAssertEqual(sut, size)
    }
    
    func testEdgesIgnoringSafeArea() throws {
        let sut = EmptyView().edgesIgnoringSafeArea([.leading])
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testEdgesIgnoringSafeAreaInspection() throws {
        let edges: Edge.Set = [.leading]
        let sut = try EmptyView().edgesIgnoringSafeArea(edges)
            .inspect().emptyView().edgesIgnoringSafeArea()
        XCTAssertEqual(sut, edges)
    }
    
    func testCoordinateSpace() throws {
        let sut = EmptyView().coordinateSpace(name: "")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testCoordinateSpaceInspection() throws {
        let name = "abc"
        let sut = try EmptyView().coordinateSpace(name: name)
            .inspect().emptyView().coordinateSpaceName()
        XCTAssertEqual(sut, name)
    }
}

// MARK: - ViewAligningTests

final class ViewAligningTests: XCTestCase {
    
    func testHorizontalAlignmentGuide() throws {
        let sut = EmptyView().alignmentGuide(.leading) { _ in 5 }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testVerticalAlignmentGuide() throws {
        let sut = EmptyView().alignmentGuide(.top) { _ in 5 }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - ViewLayeringTests

final class ViewLayeringTests: XCTestCase {
    
    func testOverlay() throws {
        let sut = EmptyView().overlay(Text(""), alignment: .center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOverlayInspection() throws {
        let text = "Abc"
        let sut = try EmptyView().overlay(Text(text), alignment: .center)
            .inspect().emptyView().overlay().text().string()
        XCTAssertEqual(sut, text)
    }
    
    func testBackground() throws {
        let sut = EmptyView().background(Text(""), alignment: .center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBackgroundInspection() throws {
        let text = "Abc"
        let sut = try EmptyView().background(Text(text), alignment: .center)
            .inspect().emptyView().background().text().string()
        XCTAssertEqual(sut, text)
    }
    
    func testZIndex() throws {
        let sut = EmptyView().zIndex(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testZIndexInspection() throws {
        let index: Double = 6
        let sut = try EmptyView().zIndex(index).inspect().emptyView().zIndex()
        XCTAssertEqual(sut, index)
    }
}

// MARK: - ViewMaskingTests

final class ViewMaskingTests: XCTestCase {
    
    func testClipped() throws {
        let sut = EmptyView().clipped(antialiased: false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testClipShape() throws {
        let sut = EmptyView().clipShape(Capsule(), style: FillStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testCornerRadius() throws {
        let sut = EmptyView().cornerRadius(5, antialiased: false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMask() throws {
        let sut = EmptyView().mask(Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
