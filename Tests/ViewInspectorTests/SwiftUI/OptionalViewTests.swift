import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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
    
    func testSearch() throws {
        let view1 = AnyView(MixedOptionalView(flag: true))
        let view2 = AnyView(MixedOptionalView(flag: false))
        XCTAssertEqual(try view1.inspect().find(text: "ABC").pathToRoot,
                       "anyView().view(MixedOptionalView.self).hStack().text(0)")
        XCTAssertEqual(try view1.inspect().find(text: "XYZ").pathToRoot,
                       "anyView().view(MixedOptionalView.self).hStack().text(1)")
        XCTAssertThrows(try view2.inspect().find(text: "ABC"), "Search did not find a match")
        XCTAssertEqual(try view2.inspect().find(text: "XYZ").pathToRoot,
                       "anyView().view(MixedOptionalView.self).hStack().text(1)")
    }
    
    func testRetainsModifiers() throws {
        let view = Group {
            if true { Text("ABC").padding().blur(radius: 4) }
        }.padding()
        let sut = try view.inspect().group().text(0)
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 2)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct OptionalView: View {
    
    let flag: Bool
    var body: some View {
        HStack {
            if flag { Text("ABC") }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct MixedOptionalView: View {
    
    let flag: Bool
    var body: some View {
        HStack {
            if flag { Text("ABC") }
            Text("XYZ")
        }
    }
}
