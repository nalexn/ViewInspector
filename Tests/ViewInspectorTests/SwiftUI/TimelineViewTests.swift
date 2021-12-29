import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TimelineViewTests: XCTestCase {
    
    #if !os(watchOS)
    func testEnclosedView() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = TimelineView(.everyMinute) { timeline in
            Text("\(timeline.date)")
        }
        let date = Date()
        let context = ViewType.TimelineView.Context(date: date, cadence: .live)
        let text = try sut.inspect().timelineView().contentView(context).text()
        XCTAssertEqual(try text.string(), "\(date)")
    }
    
    func testResetsModifiers() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = TimelineView(.everyMinute) { _ in
            EmptyView()
        }.padding()
        let view = try sut.inspect().timelineView().contentView()
        XCTAssertEqual(view.content.medium.viewModifiers.count, 0)
    }
    #endif
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let view = Button(action: { }, label: {
            TimelineView(.everyMinute) { _ in EmptyView() }
        })
        XCTAssertNoThrow(try view.inspect().button().labelView().timelineView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            TimelineView(.everyMinute) { _ in EmptyView() }
            TimelineView(.everyMinute) { _ in EmptyView() }
        }
        XCTAssertNoThrow(try view.inspect().hStack().timelineView(0))
        XCTAssertNoThrow(try view.inspect().hStack().timelineView(1))
    }
    
    #if !os(watchOS)
    func testSearch() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = try AnyView(TimelineView(.everyMinute) { _ in
            EmptyView()
        }).inspect()
        XCTAssertEqual(try sut.find(ViewType.EmptyView.self).pathToRoot,
            "anyView().timelineView().contentView().emptyView()")
    }
    #endif
}
