import XCTest
import SwiftUI
@testable import ViewInspector

final class OptionalViewTests: XCTestCase {
    
    func testOptionalViewWhenExists() throws {
        let view = OptionalView(flag: true)
        let string = try view.inspect().hStack().text(0).string()
        XCTAssertEqual(string, "ABC")
    }
    
    func testOptionalViewWhenIsAbsent() throws {
        let view = OptionalView(flag: false)
        XCTAssertThrows(
            try view.inspect().hStack().text(0),
            "View for Optional<Text> is absent")
    }
    
    func testMixedOptionalViewWhenExists() throws {
        let view = MixedOptionalView(flag: true)
        let string1 = try view.inspect().hStack().text(0).string()
        XCTAssertEqual(string1, "ABC")
        let string2 = try view.inspect().hStack().text(1).string()
        XCTAssertEqual(string2, "XYZ")
    }
    
    func testMixedOptionalViewWhenIsAbsent() throws {
        let view = MixedOptionalView(flag: false)
        XCTAssertThrows(
            try view.inspect().hStack().text(0),
            "View for Optional<Text> is absent")
        let string = try view.inspect().hStack().text(1).string()
        XCTAssertEqual(string, "XYZ")
    }
    
    func testResetsModifiers() throws {
        let view = Group {
            if true { Text("ABC") }
        }.padding()
        let sut = try view.inspect().group().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
}

private struct OptionalView: View, Inspectable {
    
    let flag: Bool
    var body: some View {
        HStack {
            if flag { Text("ABC") }
        }
    }
}

private struct MixedOptionalView: View, Inspectable {
    
    let flag: Bool
    var body: some View {
        HStack {
            if flag { Text("ABC") }
            Text("XYZ")
        }
    }
}
