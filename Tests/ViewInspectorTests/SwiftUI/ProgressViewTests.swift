import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class ProgressViewTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(ProgressView())
        XCTAssertNoThrow(try view.inspect().anyView().progressView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            ProgressView()
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().progressView(1))
    }
    
    func testFractionCompletedInspection() throws {
        let view1 = ProgressView()
        let view2 = ProgressView("test", value: 0.35)
        XCTAssertNil(try view1.inspect().progressView().fractionCompleted())
        XCTAssertEqual(try view2.inspect().progressView().fractionCompleted(), 0.35)
    }
    
    func testProgressInspection() throws {
        let progress = Progress(totalUnitCount: 100)
        progress.completedUnitCount = 10
        let view = ProgressView(progress)
        let sut = try view.inspect().progressView().progress()
        XCTAssertEqual(sut.completedUnitCount, 10)
        XCTAssertEqual(sut.totalUnitCount, 100)
    }
    
    func testLabelViewInspection() throws {
        let view = ProgressView(value: 0, label: { HStack { Text("abc") } },
                                currentValueLabel: { EmptyView() })
        let sut = try view.inspect().progressView().labelView().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }
    
    func testCurrentValueLabelViewInspection() throws {
        let view = ProgressView(value: 0, label: { EmptyView() },
                                currentValueLabel: { HStack { Text("abc") } })
        let sut = try view.inspect().progressView().currentValueLabelView().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }
}
#endif
