import XCTest
import SwiftUI
@testable import ViewInspector

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
        let sut = EmptyView().padding(.horizontal, 5)
        XCTAssertEqual(try sut.inspect().emptyView().padding(),
                       EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
    }
    
    func testDefaultPaddingValueError() throws {
        let sut1 = EmptyView().padding()
        let sut2 = EmptyView().padding([.leading])
        let sut3 = EmptyView().offset()
        XCTAssertThrows(try sut1.inspect().emptyView().padding(),
            "Please use `hasPadding(_:)` for inspecting padding without explicit value.")
        XCTAssertThrows(try sut2.inspect().emptyView().padding(),
            """
            Undefined inset for 'leading' edge. Consider calling `hasPadding(_:)` \
            instead to assure a default padding is applied.
            """)
        XCTAssertThrows(try sut3.inspect().emptyView().padding(),
            "EmptyView does not have 'padding' modifier")
    }

    func testHasDefaultPadding() throws {
        let sut = Text("Test").padding()

        XCTAssertTrue(try sut.inspect().hasPadding(.all))
        XCTAssertTrue(try sut.inspect().hasPadding())
    }

    func testHasOnlyTopPadding() throws {
        let sut = Text("Test").padding([.top])

        XCTAssertTrue(try sut.inspect().hasPadding(.top))
        XCTAssertFalse(try sut.inspect().hasPadding(.bottom))
        XCTAssertFalse(try sut.inspect().hasPadding(.leading))
        XCTAssertFalse(try sut.inspect().hasPadding(.trailing))

        XCTAssertFalse(try sut.inspect().hasPadding([.trailing, .bottom]))
        XCTAssertFalse(try sut.inspect().hasPadding([.trailing, .top]))
        XCTAssertFalse(try sut.inspect().hasPadding(.all))
        XCTAssertTrue(try sut.inspect().hasPadding([]))
    }

    func testHasLeadingAndTrailingPadding() throws {
        let sut = Text("Test").padding([.leading, .trailing])

        XCTAssertTrue(try sut.inspect().hasPadding(.leading))
        XCTAssertTrue(try sut.inspect().hasPadding(.trailing))
        XCTAssertTrue(try sut.inspect().hasPadding([.leading, .trailing]))

        XCTAssertFalse(try sut.inspect().hasPadding(.bottom))
        XCTAssertFalse(try sut.inspect().hasPadding(.top))

        XCTAssertFalse(try sut.inspect().hasPadding([.trailing, .bottom]))
        XCTAssertFalse(try sut.inspect().hasPadding([.trailing, .top]))
        XCTAssertFalse(try sut.inspect().hasPadding([.all]))

    }

    func testHasSamePaddingInsetsForAllEdges() {
        let sut = Text("Test").padding(20)
        XCTAssertEqual(try sut.inspect().padding(.top), 20)
        XCTAssertEqual(try sut.inspect().padding(.bottom), 20)
        XCTAssertEqual(try sut.inspect().padding(.leading), 20)
        XCTAssertEqual(try sut.inspect().padding(.trailing), 20)
        XCTAssertEqual(try sut.inspect().padding([.top, .bottom]), 20)
        XCTAssertEqual(try sut.inspect().padding(.all), 20)
    }

    func testHasDifferentPaddingForEdge() throws {
        let sut = Text("Test").padding([.top], 10).padding([.bottom], 20)

        XCTAssertEqual(try sut.inspect().padding([.top]), 10)
        XCTAssertEqual(try sut.inspect().padding([.bottom]), 20)
        XCTAssertThrows(try sut.inspect().padding([.leading]),
                        "Text does not have 'padding' modifier")
        XCTAssertThrows(try sut.inspect().padding([.trailing]),
                        "Text does not have 'padding' modifier")
        XCTAssertThrows(try sut.inspect().padding([.top, .bottom]),
                        """
                        Insets for edges '[SwiftUI.Edge.top, SwiftUI.Edge.bottom]' have \
                        different values, consider calling `padding` individually per edge.
                        """)
        XCTAssertThrows(try sut.inspect().padding([]), "No edge is specified")
    }

    func testHasDifferentPaddingForEdges() throws {
        let sut = Text("Test").padding([.top, .bottom], 10).padding([.leading, .trailing], 20)

        XCTAssertEqual(try sut.inspect().padding(.top), 10)
        XCTAssertEqual(try sut.inspect().padding(.bottom), 10)
        XCTAssertEqual(try sut.inspect().padding(.leading), 20)
        XCTAssertEqual(try sut.inspect().padding(.trailing), 20)
        XCTAssertEqual(try sut.inspect().padding(), .init(top: 10, leading: 20, bottom: 10, trailing: 20))
    }
    
    func testCumulativePadding() throws {
        let sut = Text("Test")
            .padding([.top, .bottom], 10)
            .padding([.top, .trailing], 20)
            .padding(5)

        XCTAssertEqual(try sut.inspect().padding(.top), 35)
        XCTAssertEqual(try sut.inspect().padding(), .init(top: 35, leading: 5, bottom: 15, trailing: 25))
    }
    
    func testCumulativeUndefinedPaddingError() throws {
        let sut = Text("Test")
            .padding(.trailing)
            .padding(.trailing, 10)
        XCTAssertThrows(try sut.inspect().padding(.trailing),
            """
            Undefined inset for 'trailing' edge. Consider calling `hasPadding(_:)` \
            instead to assure a default padding is applied.
            """)
        XCTAssertTrue(try sut.inspect().hasPadding(.trailing))
    }
}
