import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewSizingTests

final class ViewSizingTests: XCTestCase {
    
    func testFrameWidthHeightAlignment() throws {
        let sut = EmptyView().frame(width: 5, height: 5, alignment:
            Alignment(horizontal: .center, vertical: .center))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFrameWidthHeightAlignmentInspection() throws {
        let frame = FixedFrameLayout(width: 5, height: 6, alignment:
            Alignment(horizontal: .center, vertical: .center))
        let sut = try EmptyView().frame(width: frame.width, height: frame.height,
                                        alignment: frame.alignment)
            .inspect().emptyView().fixedFrame()
        XCTAssertEqual(sut, frame)
    }
    
    func testFrameMinIdealMax() throws {
        let sut = EmptyView().frame(minWidth: 5, idealWidth: 5, maxWidth: 5,
                                    minHeight: 5, idealHeight: 5, maxHeight: 5,
                                    alignment: .topTrailing)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFrameMinIdealMaxInspection() throws {
        let frame = FlexFrameLayout(minWidth: 1, idealWidth: 2, maxWidth: 3,
                                    minHeight: 4, idealHeight: 5, maxHeight: 6,
                                    alignment: .bottomLeading)
        let sut = try EmptyView().frame(
            minWidth: frame.minWidth, idealWidth: frame.idealWidth, maxWidth: frame.maxWidth,
            minHeight: frame.minHeight, idealHeight: frame.idealHeight, maxHeight: frame.maxHeight,
            alignment: frame.alignment)
            .inspect().emptyView().flexFrame()
        XCTAssertEqual(sut, frame)
    }
    
    func testFixedSize() throws {
        let sut = EmptyView().fixedSize()
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFixedSizeInspection() throws {
        let sut = try EmptyView().fixedSize().inspect().emptyView().fixedSize()
        XCTAssertEqual(sut, FixedSize(horizontal: true, vertical: true))
    }
    
    func testFixedSizeHorizontalVertical() throws {
        let sut = EmptyView().fixedSize(horizontal: true, vertical: false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFixedSizeHorizontalVerticalInspection() throws {
        let fixed = FixedSize(horizontal: true, vertical: false)
        let sut = try EmptyView().fixedSize(horizontal: fixed.horizontal, vertical: fixed.vertical)
            .inspect().emptyView().fixedSize()
        XCTAssertEqual(sut, fixed)
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
