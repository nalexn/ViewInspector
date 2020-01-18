import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

final class InspectorTests: XCTestCase {
    
    private let testString = "abc"
    private let testValue = Struct1(value1: "abc", value2: .init(value3: 42))
    
    func testAttributeLabel() throws {
        guard let value = try Inspector.attribute(label: "value1", value: testValue) as? String
            else { XCTFail(); return }
        XCTAssertEqual(value, "abc")
    }
    
    func testUnknownAttributeLabel() throws {
        XCTAssertThrowsError(try Inspector.attribute(label: "other", value: testValue))
    }
    
    func testAttributePath() throws {
        guard let value = try Inspector.attribute(path: "value2|value3", value: testValue) as? Int
            else { XCTFail(); return }
        XCTAssertEqual(value, 42)
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
    
    func testTupleView() throws {
        let view = HStack { Text(""); Text("") }
        let content = try Inspector.attribute(path: "_tree|content", value: view)
        XCTAssertTrue(Inspector.isTupleView(content))
        XCTAssertFalse(Inspector.isTupleView((0, 2)))
    }
    
    func testGuardType() throws {
        let value = "abc"
        XCTAssertNoThrow(try Inspector.guardType(value: value, prefix: "String"))
        XCTAssertThrowsError(try Inspector.guardType(value: value, prefix: "Int"))
    }
    
    func testUnwrapNoModifiers() throws {
        let view = Text(testString)
        let sut = try Inspector.unwrap(view: view, modifiers: [])
        let text = try (sut.view as? Text)?.inspect().string()
        XCTAssertEqual(text, testString)
    }
    
    func testUnwrapOneModifier() throws {
        let view = Text(testString).transition(.offset(.zero))
        let sut = try Inspector.unwrap(view: view, modifiers: [])
        let text = try (sut.view as? Text)?.inspect().string()
        XCTAssertEqual(text, testString)
    }
    
    func testUnwrapTwoModifier() throws {
        let publisher = PassthroughSubject<Bool, Never>()
        let view = Text(testString)
            .transition(.offset(.zero))
            .onReceive(publisher) { _ in }
        let sut = try Inspector.unwrap(view: view, modifiers: [])
        let text = try (sut.view as? Text)?.inspect().string()
        XCTAssertEqual(text, testString)
    }
}

final class InspectableViewModifiersTests: XCTestCase {
    
    func testModifierIsNotPresent() throws {
        let sut = EmptyView().padding()
        XCTAssertThrowsError(try sut.inspect().emptyView().callOnAppear())
    }
    
    func testModifierAttributeIsNotPresent() throws {
        let sut = EmptyView().onDisappear().padding()
        XCTAssertThrowsError(try sut.inspect().emptyView().callOnAppear())
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
