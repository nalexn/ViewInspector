import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TransitiveModifiersTests: XCTestCase {
    
    func testHiddenTransitivity() throws {
        let sut = try HittenTestView().inspect()
        XCTAssertFalse(try sut.find(text: "abc").isHidden())
        XCTAssertTrue(try sut.find(text: "123").isHidden())
        XCTAssertThrows(try sut.find(button: "123").tap(),
            "Button is unresponsive: view(HittenTestView.self).vStack().hStack(1) is hidden")
    }
    
    func testDisabledStateInheritance() throws {
        let sut = try TestDisabledView().inspect()
        XCTAssertFalse(try sut.find(button: "1").isDisabled())
        XCTAssertFalse(try sut.find(button: "2").isDisabled())
        XCTAssertTrue(try sut.find(button: "3").isDisabled())
        XCTAssertThrows(try sut.find(button: "3").tap(),
            "Button is unresponsive: view(TestDisabledView.self).vStack().vStack(1).vStack(1) is disabled")
    }
    
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    func testFlipsRightToLeftInheritance() throws {
        let sut = try FlipsRightToLeftTestView().inspect()
        if #available(iOS 14.0, tvOS 14.0, *) {
            XCTAssertFalse(try sut.find(text: "1").flipsForRightToLeftLayoutDirection())
        } else {
            // Prior to iOS 14 flipsForRightToLeftLayoutDirection is ignoring the Bool parameter
            XCTAssertTrue(try sut.find(text: "1").flipsForRightToLeftLayoutDirection())
        }
        XCTAssertTrue(try sut.find(text: "2").flipsForRightToLeftLayoutDirection())
    }
    
    @available(macOS 11.0, *)
    func testColorSchemeInheritance() throws {
        let sut = try ColorSchemeTestView().inspect()
        let text1 = try sut.find(text: "1")
        let text2 = try sut.find(text: "2")
        let text3 = try sut.find(text: "3")
        let text4 = try sut.find(text: "4")
        XCTAssertEqual(try text1.preferredColorScheme(), .light)
        XCTAssertEqual(try text2.preferredColorScheme(), .light)
        XCTAssertEqual(try text3.preferredColorScheme(), .light)
        XCTAssertEqual(try text4.preferredColorScheme(), .light)
        XCTAssertEqual(try text1.colorScheme(), .light)
        XCTAssertEqual(try text2.colorScheme(), .light)
        XCTAssertEqual(try text3.colorScheme(), .dark)
        XCTAssertEqual(try text4.colorScheme(), .light)
    }
    
    func testAllowsHitTestingInheritance() throws {
        guard #available(macOS 11.0, *) else { throw XCTSkip() }
        let sut = try AllowsHitTestingTestView().inspect()
        XCTAssertTrue(try sut.find(button: "1").allowsHitTesting())
        XCTAssertTrue(try sut.find(button: "2").allowsHitTesting())
        XCTAssertFalse(try sut.find(button: "3").allowsHitTesting())
        XCTAssertThrows(try sut.find(button: "3").tap(),
            """
            Button is unresponsive: view(AllowsHitTestingTestView.self).vStack()\
            .vStack(1).vStack(1) has allowsHitTesting set to false
            """)
    }
    
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    func testLabelsHiddenInheritance() throws {
        let sut = try TestLabelsHiddenView().inspect()
        let text1 = try sut.find(text: "1")
        let text2 = try sut.find(text: "2")
        XCTAssertFalse(text1.labelsHidden())
        XCTAssertFalse(text1.isHidden())
        XCTAssertTrue(text2.labelsHidden())
        XCTAssertTrue(text2.isHidden())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct HittenTestView: View {
    var body: some View {
        VStack {
            Button("abc", action: { })
            HStack {
                Button("123", action: { })
            }.hidden()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestDisabledView: View {
    var body: some View {
        VStack {
            Button(action: { }, label: {
                Text("1")
            })
            VStack {
                Button(action: { }, label: {
                    Text("2")
                })
                VStack {
                    Button(action: { }, label: {
                        Text("3").disabled(false)
                    }).disabled(false)
                }.disabled(true)
            }.disabled(false)
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct FlipsRightToLeftTestView: View {
    var body: some View {
        VStack {
            Stepper("1", onIncrement: nil, onDecrement: nil)
            VStack {
                Stepper("2", onIncrement: nil, onDecrement: nil)
                    .flipsForRightToLeftLayoutDirection(false)
            }.flipsForRightToLeftLayoutDirection(true)
        }.flipsForRightToLeftLayoutDirection(false)
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
private struct ColorSchemeTestView: View {
    var body: some View {
        VStack {
            Text("1")
            VStack {
                Text("2")
                VStack {
                    Text("3")
                    VStack {
                        Text("4")
                    }.colorScheme(.light)
                }.colorScheme(.dark)
            }.preferredColorScheme(.dark)
        }.preferredColorScheme(.light)
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
private struct AllowsHitTestingTestView: View {
    
    var body: some View {
        VStack {
            Button("1", action: { })
            VStack {
                Button("2", action: { })
                VStack {
                    Button("3", action: { })
                        .allowsHitTesting(true)
                }.allowsHitTesting(false)
            }.allowsHitTesting(true)
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct TestLabelsHiddenView: View {
    var body: some View {
        VStack {
            Stepper(onIncrement: nil, onDecrement: nil, label: {
                VStack { HStack { Text("1") } }
            })
            VStack {
                Stepper(onIncrement: nil, onDecrement: nil, label: {
                    VStack { HStack { Text("2") } }
                })
            }.labelsHidden()
        }
    }
}
