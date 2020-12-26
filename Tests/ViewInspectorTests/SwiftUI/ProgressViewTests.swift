import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ProgressViewTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = AnyView(ProgressView())
        XCTAssertNoThrow(try view.inspect().anyView().progressView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = HStack {
            Text("")
            ProgressView()
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().progressView(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = AnyView(ProgressView(value: 0, label: { AnyView(Text("abc")) },
                                        currentValueLabel: { Text("xyz") }))
        XCTAssertEqual(try view.inspect().find(ViewType.ProgressView.self).pathToRoot,
                       "anyView().progressView()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().progressView().labelView().anyView().text()")
        XCTAssertEqual(try view.inspect().find(text: "xyz").pathToRoot,
                       "anyView().progressView().currentValueLabelView().text()")
    }
    
    func testFractionCompletedInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view1 = ProgressView()
        let view2 = ProgressView("test", value: 0.35)
        XCTAssertNil(try view1.inspect().progressView().fractionCompleted())
        XCTAssertEqual(try view2.inspect().progressView().fractionCompleted(), 0.35)
    }
    
    func testProgressInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let progress = Progress(totalUnitCount: 100)
        progress.completedUnitCount = 10
        let view = ProgressView(progress)
        let sut = try view.inspect().progressView().progress()
        XCTAssertEqual(sut.completedUnitCount, 10)
        XCTAssertEqual(sut.totalUnitCount, 100)
    }
    
    func testLabelViewInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = ProgressView(value: 0, label: { HStack { Text("abc") } },
                                currentValueLabel: { EmptyView() })
        let sut = try view.inspect().progressView().labelView().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }
    
    func testCurrentValueLabelViewInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = ProgressView(value: 0, label: { EmptyView() },
                                currentValueLabel: { HStack { Text("abc") } })
        let sut = try view.inspect().progressView().currentValueLabelView().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }
    
    func testProgressViewStyleInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let sut = EmptyView().progressViewStyle(CircularProgressViewStyle())
        XCTAssertTrue(try sut.inspect().progressViewStyle() is CircularProgressViewStyle)
    }
    
    func testProgressViewStyleConfiguration() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let sut1 = ProgressViewStyleConfiguration(fractionCompleted: nil)
        XCTAssertNil(sut1.fractionCompleted)
        let sut2 = ProgressViewStyleConfiguration(fractionCompleted: 0.9)
        XCTAssertEqual(sut2.fractionCompleted, 0.9)
    }
    
    func testCustomProgressViewStyleInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let sut = TestProgressViewStyle()
        XCTAssertEqual(try sut.inspect(fractionCompleted: nil)
                        .vStack().styleConfigurationLabel(0).brightness(), 3)
        XCTAssertEqual(try sut.inspect(fractionCompleted: nil)
                        .vStack().styleConfigurationCurrentValueLabel(1).blur().radius, 5)
        XCTAssertThrows(try EmptyView().inspect().styleConfigurationCurrentValueLabel(),
            "styleConfigurationCurrentValueLabel() found EmptyView instead of CurrentValueLabel")
        XCTAssertEqual(try sut.inspect(fractionCompleted: 0.42)
                        .vStack().text(2).string(), "Completed: 42%")
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
private struct TestProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
                .brightness(3)
            configuration.currentValueLabel
                .blur(radius: 5)
            Text("Completed: \(Int(configuration.fractionCompleted.flatMap { $0 * 100 } ?? 0))%")
        }
    }
}
