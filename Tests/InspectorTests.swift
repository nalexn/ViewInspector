import XCTest
import SwiftUI
@testable import ViewInspector

final class InspectorTests: XCTestCase {
    
    private let testValue = Test1(
        value1: "abc", value2:
        Test1.Test2(value3: 42), view: TestView())
    
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
        let name1 = Inspector.typeName(value: Test3<Int>())
        XCTAssertEqual(name1, "Test3")
        let name2 = Inspector.typeName(value: testValue)
        XCTAssertEqual(name2, "Test1")
    }
    
    func testTypeNameType() {
        let name1 = Inspector.typeName(type: Test3<Int>.self)
        XCTAssertEqual(name1, "Test3")
        let name2 = Inspector.typeName(type: Test1.self)
        XCTAssertEqual(name2, "Test1")
    }
    
    func testAttributesTree() {
        let tree = Inspector.attributesTree(value: testValue)
        let expected: [String: Any] = [
            ">>> Test1 <<<": [
            ["value1":
                [">>> String <<<": "abc"]],
            ["value2":
                [">>> Test2 <<<": [
                    ["value3":
                        [">>> Int <<<": "42"]]]]],
            ["view":
                [">>> TestView <<<": [
                    ["body":
                        [">>> EmptyView <<<": "EmptyView()"]]]]]
            ]]
        XCTAssertEqual("\(tree)", "\(expected)")
    }
    
    func testTupleView() throws {
        let view = HStack { Text(""); Text("") }
        let content = try Inspector.attribute(path: "_tree|content", value: view)
        XCTAssertTrue(Inspector.isTupleView(content))
        XCTAssertFalse(Inspector.isTupleView((0,2)))
    }
    
    func testGuardType() throws {
        let value = "abc"
        XCTAssertNoThrow(try Inspector.guardType(value: value, prefix: "String"))
        XCTAssertThrowsError(try Inspector.guardType(value: value, prefix: "Int"))
    }
    
    static var allTests = [
        ("testAttributeLabel", testAttributeLabel),
        ("testUnknownAttributeLabel", testUnknownAttributeLabel),
        ("testAttributePath", testAttributePath),
        ("testTypeNameValue", testTypeNameValue),
        ("testTypeNameType", testTypeNameType),
        ("testAttributesTree", testAttributesTree),
        ("testTupleView", testTupleView),
        ("testGuardType", testGuardType)
    ]
}

private struct Test1 {
    var value1: String
    var value2: Test2
    var view: TestView
}

private extension Test1 {
    struct Test2 {
        var value3: Int
    }
}

private struct TestView: View, Inspectable {
    var body: some View {
        EmptyView()
    }
}

private struct Test3<T> { }
