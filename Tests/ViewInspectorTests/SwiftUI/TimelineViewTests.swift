import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class TimelineViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sut = TimelineView(.everyMinute) { timeline in
            Text("\(timeline.date)")
        }
        let date = Date()
        let context = ViewType.TimelineView.Context(date: date, cadence: .live)
        let text = try sut.inspect().timelineView().contentView(context).text()
        XCTAssertEqual(try text.string(), "\(date)")
    }
    
    func testResetsModifiers() throws {
        let sut = TimelineView(.everyMinute) { _ in
            EmptyView()
        }.padding()
        let view = try sut.inspect().timelineView().contentView()
        XCTAssertEqual(view.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = Button(action: { }, label: {
            TimelineView(.everyMinute) { _ in EmptyView() }
        })
        XCTAssertNoThrow(try view.inspect().button().labelView().timelineView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            TimelineView(.everyMinute) { _ in EmptyView() }
            TimelineView(.everyMinute) { _ in EmptyView() }
        }
        XCTAssertNoThrow(try view.inspect().hStack().timelineView(0))
        XCTAssertNoThrow(try view.inspect().hStack().timelineView(1))
    }
    
    func testSearch() throws {
        let sut = try AnyView(TimelineView(.everyMinute) { _ in
            EmptyView()
        }).inspect()
        XCTAssertEqual(try sut.find(ViewType.EmptyView.self).pathToRoot,
            "anyView().timelineView().contentView().emptyView()")
    }
}
