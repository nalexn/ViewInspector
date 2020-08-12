import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewSizingTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewSizingTests: XCTestCase {
    
    func testFrameWidthHeightAlignment() throws {
        let sut = EmptyView().frame(width: 5, height: 5, alignment:
            Alignment(horizontal: .center, vertical: .center))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFrameWidthHeightAlignmentInspection() throws {
        let frame: (CGFloat, CGFloat, Alignment) = (5, 6, .center)
        let sut = try EmptyView().frame(width: frame.0, height: frame.1, alignment: frame.2)
            .inspect().emptyView().fixedFrame()
        XCTAssertEqual(sut.width, frame.0)
        XCTAssertEqual(sut.height, frame.1)
        XCTAssertEqual(sut.alignment, frame.2)
    }

    func testFrameHeightInspection() throws {
        let height: CGFloat = 5
        let sut = try EmptyView().frame(height: height)
            .inspect().emptyView().fixedHeight()
        XCTAssertEqual(sut, height)
    }

    func testFrameWidthInspection() throws {
        let width: CGFloat = 10
        let sut = try EmptyView().frame(width: width)
            .inspect().emptyView().fixedWidth()
        XCTAssertEqual(sut, width)
    }
    
    func testFrameMinIdealMax() throws {
        let sut = EmptyView().frame(minWidth: 5, idealWidth: 5, maxWidth: 5,
                                    minHeight: 5, idealHeight: 5, maxHeight: 5,
                                    alignment: .topTrailing)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFrameMinIdealMaxInspection() throws {
        let frame: (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, Alignment) =
            (1, 2, 3, 4, 5, 6, .bottomLeading)
        let sut = try EmptyView().frame(
            minWidth: frame.0, idealWidth: frame.1, maxWidth: frame.2,
            minHeight: frame.3, idealHeight: frame.4, maxHeight: frame.5,
            alignment: frame.6)
            .inspect().emptyView().flexFrame()
        XCTAssertEqual(sut.minWidth, frame.0); XCTAssertEqual(sut.idealWidth, frame.1)
        XCTAssertEqual(sut.maxWidth, frame.2); XCTAssertEqual(sut.minHeight, frame.3)
        XCTAssertEqual(sut.idealHeight, frame.4); XCTAssertEqual(sut.maxHeight, frame.5)
        XCTAssertEqual(sut.alignment, frame.6)
    }
    
    func testFixedSize() throws {
        let sut = EmptyView().fixedSize()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFixedSizeInspection() throws {
        let sut = try EmptyView().fixedSize().inspect().emptyView().fixedSize()
        XCTAssertTrue(sut.horizontal); XCTAssertTrue(sut.vertical)
    }
    
    func testFixedSizeHorizontalVertical() throws {
        let sut = EmptyView().fixedSize(horizontal: true, vertical: false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFixedSizeHorizontalVerticalInspection() throws {
        let fixed = (horizontal: true, vertical: false)
        let sut = try EmptyView().fixedSize(horizontal: fixed.horizontal, vertical: fixed.vertical)
            .inspect().emptyView().fixedSize()
        XCTAssertTrue(sut.horizontal); XCTAssertFalse(sut.vertical)
    }
    
    func testLayoutPriority() throws {
        let sut = EmptyView().layoutPriority(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLayoutPriorityInspection() throws {
        let priority: Double = 10
        let sut = try EmptyView().layoutPriority(priority)
            .inspect().emptyView().layoutPriority()
        XCTAssertEqual(sut, priority)
    }
}

// MARK: - ViewPaddingTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewPaddingTests: XCTestCase {
    
    func testPadding() throws {
        let sut = EmptyView().padding(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPaddingInspection() throws {
        let sut = try EmptyView().padding(5).inspect().emptyView().padding()
        XCTAssertEqual(sut, EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
    
    func testPaddingEdgeInsets() throws {
        let sut = EmptyView().padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPaddingEdgeInsetsInspection() throws {
        let edges = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let sut = try EmptyView().padding(edges).inspect().emptyView().padding()
        XCTAssertEqual(sut, edges)
    }
    
    func testPaddingEdgeSet() throws {
        let sut = EmptyView().padding([.top], 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPaddingEdgeSetInspection() throws {
        let sut = try EmptyView().padding(.horizontal, 5).inspect().emptyView().padding()
        // Looks like a bug in SwiftUI. All edges are set:
        XCTAssertEqual(sut, EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}
