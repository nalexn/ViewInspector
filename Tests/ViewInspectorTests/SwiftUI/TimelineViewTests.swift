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
        typealias REF = TimelineView<EveryMinuteTimelineSchedule, EmptyView>.Context
        typealias SUTMemLayout = MemoryLayout<SUT>
        typealias REFMemLayout = MemoryLayout<REF>
        XCTAssertEqual(SUTMemLayout.size, REFMemLayout.size)
        XCTAssertEqual(SUTMemLayout.alignment, REFMemLayout.alignment)
        XCTAssertEqual(SUTMemLayout.stride, REFMemLayout.stride)
        let date = Date()
        let value = SUT(date: date, cadence: .minutes)
        let rebound = try Inspector.unsafeMemoryRebind(value: value, type: REF.self)
        XCTAssertEqual(rebound.date, date)
        XCTAssertEqual(rebound.cadence, .minutes)
    }
    
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
