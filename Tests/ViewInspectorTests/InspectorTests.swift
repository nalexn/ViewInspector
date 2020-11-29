import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class InspectorTests: XCTestCase {
    
    private let testString = "abc"
    private let testValue = Struct1(value1: "abc", value2: .init(value3: 42))
    
    func testAttributeLabel() throws {
        let value = try XCTUnwrap(try Inspector
            .attribute(label: "value1", value: testValue) as? String)
        XCTAssertEqual(value, "abc")
    }
    
    func testUnknownAttributeLabel() throws {
        XCTAssertThrows(
            try Inspector.attribute(label: "other", value: testValue),
            "Struct1 does not have 'other' attribute")
    }
    
    func testAttributeLabelTypeMismatch() throws {
        XCTAssertThrows(
            try Inspector.attribute(label: "value1", value: testValue, type: Int.self),
            "Type mismatch: String is not Int")
    }
    
    func testAttributePath() throws {
        let value = try XCTUnwrap(try Inspector
            .attribute(path: "value2|value3", value: testValue) as? Int)
        XCTAssertEqual(value, 42)
    }
    
    func testAttributePathTypeMismatch() throws {
        XCTAssertThrows(
            try Inspector.attribute(path: "value1", value: testValue, type: Int.self),
            "Type mismatch: String is not Int")
    }
    
    func testTypeNameValue() {
        let name1 = Inspector.typeName(value: Struct3<Int>())
        XCTAssertEqual(name1, "Struct3<Int>")
        let name2 = Inspector.typeName(value: testValue)
        XCTAssertEqual(name2, "Struct1")
        let name3 = Inspector.typeName(value: Struct3<Int>(), prefixOnly: true)
        XCTAssertEqual(name3, "Struct3")
    }
    
    func testTypeNameType() {
        let name1 = Inspector.typeName(type: Struct3<Int>.self)
        XCTAssertEqual(name1, "Struct3<Int>")
        let name2 = Inspector.typeName(type: Struct1.self)
        XCTAssertEqual(name2, "Struct1")
    }
    
    func testPrintValue() {
        let sut = TestPrintView()
        let str = """
                TestPrintView
                  body: Text
                    modifiers: Array<Modifier> = []
                    storage: Storage
                      verbatim: String = abc
                  str: Array<String>
                    [0] = abc
                    [1] = def

                """
        XCTAssertEqual(Inspector.print(sut), str)
    }
    
    func testTupleView() throws {
        let view = HStack { Text(""); Text("") }
        let content = try Inspector.attribute(path: "_tree|content", value: view)
        XCTAssertTrue(Inspector.isTupleView(content))
        XCTAssertFalse(Inspector.isTupleView((0, 2)))
    }
    
    func testGuardType() throws {
        let value = "abc"
        XCTAssertNoThrow(try Inspector.guardType(value: value, prefix: "String"))
        XCTAssertThrows(
            try Inspector.guardType(value: value, prefix: "Int"),
            "Type mismatch: String is not Int")
    }
    
    func testUnwrapNoModifiers() throws {
        let view = Text(testString)
        let sut = try Inspector.unwrap(view: view, modifiers: [])
        let text = try (sut.view as? Text)?.inspect().text().string()
        XCTAssertEqual(text, testString)
    }
    
    func testUnwrapOneModifier() throws {
        let view = Text(testString).transition(.offset(.zero))
        let sut = try Inspector.unwrap(view: view, modifiers: [])
        let text = try (sut.view as? Text)?.inspect().text().string()
        XCTAssertEqual(text, testString)
    }
    
    func testUnwrapTwoModifier() throws {
        let publisher = PassthroughSubject<Bool, Never>()
        let view = Text(testString)
            .transition(.offset(.zero))
            .onReceive(publisher) { _ in }
        let sut = try Inspector.unwrap(view: view, modifiers: [])
        let text = try (sut.view as? Text)?.inspect().text().string()
        XCTAssertEqual(text, testString)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class InspectableViewModifiersTests: XCTestCase {
    
    func testModifierIsNotPresent() throws {
        let sut = EmptyView().padding()
        XCTAssertThrows(
            try sut.inspect().emptyView().callOnAppear(),
            "EmptyView does not have 'onAppear' modifier")
    }
    
    func testModifierAttributeIsNotPresent() throws {
        let sut = EmptyView().onDisappear().padding()
        XCTAssertThrows(
            try sut.inspect().emptyView().callOnAppear(),
            "EmptyView does not have 'onAppear' modifier")
    }
    
    func testModifierLookupFailure() throws {
        let sut = EmptyView().padding()
        XCTAssertThrows(try sut.inspect().modifierAttribute(
                            modifierLookup: { _ in true }, path: "wrong",
                            type: Int.self, call: "test"),
                        "EmptyView does not have 'test' modifier")
    }
    
    func testParentInspection() throws {
        let view = HStack { AnyView(Text("test")) }
        let sut = try view.inspect().hStack().anyView(0).text()
        XCTAssertThrows(try sut.parent().group(), "inspect().group() found AnyView instead of Group")
        XCTAssertNoThrow(try sut.parent().anyView())
        XCTAssertNoThrow(try sut.parent().parent().hStack())
        XCTAssertThrows(try sut.parent().parent().parent(), "HStack<AnyView> does not have parent")
        XCTAssertThrows(try view.inspect().parent(), "HStack<AnyView> does not have parent")
    }
    
    func testPathToRoot() throws {
        let view1 = Group { HStack { EmptyView(); AnyView(Text("test")) } }
        let sut1 = try view1.inspect().group().hStack(0).anyView(1).text()
        XCTAssertEqual(sut1.pathToRoot, "inspect().group().hStack().anyView().text()")
        let view2 = EmptyView()
        let sut2 = try view2.inspect()
        XCTAssertEqual(sut2.pathToRoot, "inspect()")
        let sut3 = try view2.inspect().emptyView()
        XCTAssertEqual(sut3.pathToRoot, "inspect().emptyView()")
    }
}

// MARK: - Helpers

private struct Struct1 {
    var value1: String
    var value2: Struct2
    
    struct Struct2 {
        var value3: Int
    }
}

private struct Struct3<T> { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestPrintView: View, Inspectable {
    
    let str = ["abc", "def"]
    
    var body: some View {
        Text(str[0])
    }
}
