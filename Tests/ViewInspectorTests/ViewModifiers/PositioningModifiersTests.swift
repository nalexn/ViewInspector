import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewPositioningTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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

    func testIgnoresSafeArea() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().ignoresSafeArea()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testIgnoresSafeAreaInspection() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let sut = try EmptyView().ignoresSafeArea(.container, edges: .bottom).inspect().emptyView().ignoresSafeArea()
        XCTAssertEqual(sut.regions, .container)
        XCTAssertEqual(sut.edges, .bottom)
    }

    func testIgnoresSafeAreaDefaultsInspection() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { throw XCTSkip() }
        let sut = try EmptyView().ignoresSafeArea().inspect().emptyView().ignoresSafeArea()
        XCTAssertEqual(sut.regions, .all)
        XCTAssertEqual(sut.edges, .all)
    }
}

// MARK: - ViewAligningTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewLayeringTests: XCTestCase {
    
    func testOverlay() throws {
        let sut = EmptyView().overlay(Text(""), alignment: .center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testOverlayAlignmentIsCenter() throws {
        let sut = EmptyView().overlay(Text(""), alignment: .center)
        let overlay = try sut.inspect().emptyView().overlay()
        XCTAssertEqual(try overlay.alignment(), .center)
    }

    func testOverlayAlignmentIsBottom() throws {
        let sut = EmptyView().overlay(Text(""), alignment: .bottom)
        let overlay = try sut.inspect().emptyView().overlay()
        XCTAssertEqual(try overlay.alignment(), .bottom)
    }

    func testOverlayInspection() throws {
        let text = "Abc"
        let sut = try EmptyView().overlay(Text(text).padding(), alignment: .center)
            .inspect().emptyView().overlay().text()
        XCTAssertEqual(try sut.string(), text)
        XCTAssertEqual(sut.pathToRoot, "emptyView().overlay().text()")
    }
    
    func testOverlaySearch() throws {
        let view = EmptyView().overlay(Text("test").padding(), alignment: .center)
        XCTAssertNoThrow(try view.inspect().find(text: "test"))
    }
    
    func testBackground() throws {
        let sut = EmptyView().background(Text(""), alignment: .center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testBackgroundAlignmentIsCenter() throws {
        let sut = EmptyView().background(Text(""), alignment: .center)
        let background = try sut.inspect().emptyView().background()
        XCTAssertEqual(try background.alignment(), .center)
    }

    func testBackgroundAlignmentIsBottom() throws {
        let sut = EmptyView().background(Text(""), alignment: .bottom)
        let background = try sut.inspect().emptyView().background()
        XCTAssertEqual(try background.alignment(), .bottom)
    }
    
    func testOverlayAndBackgroundStyle() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = Spacer()
            .overlay(Color.red, alignment: .leading)
            .background(Color.green, alignment: .top)
            .overlay(Color.blue, ignoresSafeAreaEdges: [.trailing])
            .background(Color.yellow, ignoresSafeAreaEdges: [.bottom])
        let fg1 = try sut.inspect().spacer().overlay(0)
        let fg2 = try sut.inspect().spacer().overlay(1)
        XCTAssertEqual(try fg1.color().value(), Color.red)
        XCTAssertEqual(try fg1.alignment(), .leading)
        XCTAssertEqual(try fg1.ignoresSafeAreaEdges(), .all)
        XCTAssertEqual(try fg2.color().value(), Color.blue)
        XCTAssertEqual(try fg2.alignment(), .center)
        XCTAssertEqual(try fg2.ignoresSafeAreaEdges(), [.trailing])
        let bg1 = try sut.inspect().spacer().background(0)
        let bg2 = try sut.inspect().spacer().background(1)
        XCTAssertEqual(try bg1.color().value(), Color.green)
        XCTAssertEqual(try bg1.alignment(), .top)
        XCTAssertEqual(try bg1.ignoresSafeAreaEdges(), .all)
        XCTAssertEqual(try bg2.color().value(), Color.yellow)
        XCTAssertEqual(try bg2.alignment(), .center)
        XCTAssertEqual(try bg2.ignoresSafeAreaEdges(), [.bottom])
    }
    
    func testBackgroundInspection() throws {
        let text = "Abc"
        let sut = try EmptyView().background(Text(text), alignment: .center)
            .inspect().emptyView().background().text()
        XCTAssertEqual(try sut.string(), text)
        XCTAssertEqual(sut.pathToRoot, "emptyView().background().text()")
    }
    
    func testBackgroundSearch() throws {
        let view = EmptyView().background(Text("test").padding(), alignment: .center)
        XCTAssertNoThrow(try view.inspect().find(text: "test"))
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
