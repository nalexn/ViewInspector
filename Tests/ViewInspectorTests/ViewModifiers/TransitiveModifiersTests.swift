import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TransitiveModifiersTests: XCTestCase {
    
    func testHiddenTransitivity() throws {
        let sut = try HittenTestView().inspect()
        XCTAssertFalse(try sut.find(text: "abc").isHidden())
        XCTAssertTrue(try sut.find(text: "123").isHidden())
    }
    
    func testDisabledStateInheritance() throws {
        let sut = try TestDisabledView().inspect()
        XCTAssertFalse(try sut.find(button: "1").isDisabled())
        XCTAssertFalse(try sut.find(button: "2").isDisabled())
        XCTAssertTrue(try sut.find(button: "3").isDisabled())
    }
    
    func testFlipsRightToLeftInheritance() throws {
        let sut = try FlipsRightToLeftTestView().inspect()
        XCTAssertFalse(try sut.find(text: "1").flipsForRightToLeftLayoutDirection())
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
        let sut = try AllowsHitTestingTestView().inspect()
        XCTAssertTrue(try sut.find(button: "1").allowsHitTesting())
        XCTAssertTrue(try sut.find(button: "2").allowsHitTesting())
        XCTAssertFalse(try sut.find(button: "3").allowsHitTesting())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct HittenTestView: View, Inspectable {
    var body: some View {
        VStack {
            Text("abc")
            HStack {
                Text("123")
            }.hidden()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestDisabledView: View, Inspectable {
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct FlipsRightToLeftTestView: View, Inspectable {
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
private struct ColorSchemeTestView: View, Inspectable {
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
private struct AllowsHitTestingTestView: View, Inspectable {
    
    var body: some View {
        VStack {
            Button("1", action: { print("1") })
            VStack {
                Button("2", action: { print("2") })
                VStack {
                    Button("3", action: { print("3") })
                        .allowsHitTesting(true)
                }.allowsHitTesting(false)
            }.allowsHitTesting(true)
        }
    }
}
