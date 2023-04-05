import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TimelineViewTests: XCTestCase {
    
    #if !os(watchOS)
    
    func testTimelineViewContext() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        typealias SUT = ViewType.TimelineView.Context
        typealias SpecificTimelineView = TimelineView<EveryMinuteTimelineSchedule, EmptyView>
        let date = Date()
        let value = SUT(date: date, cadence: .minutes)
        let adapted = try SpecificTimelineView.adapt(context: value, to: SpecificTimelineView.Context.self)
        let rebound = try Inspector.unsafeMemoryRebind(value: adapted, type: SpecificTimelineView.Context.self)
        XCTAssertEqual(rebound.date, date)
        XCTAssertEqual(rebound.cadence, .minutes)
    }
    
    func testEnclosedView() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut1 = TimelineView(.everyMinute) { timeline in
            Text("\(timeline.date)")
        }
        let sut2 = TimelineView(.periodic(from: Date(), by: 4)) { timeline in
            Text("\(timeline.date)")
        }
        let sut3 = TimelineView(.animation) { timeline in
            Text("\(timeline.date)")
        }
        let date = Date()
        let context = ViewType.TimelineView.Context(date: date, cadence: .live)
        let text1 = try sut1.inspect().timelineView().contentView(context).text()
        XCTAssertEqual(try text1.string(), "\(date)")
        let text2 = try sut2.inspect().timelineView().contentView(context).text()
        XCTAssertEqual(try text2.string(), "\(date)")
        let text3 = try sut3.inspect().timelineView().contentView(context).text()
        XCTAssertEqual(try text3.string(), "\(date)")
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
