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
