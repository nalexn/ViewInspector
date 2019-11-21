import XCTest
import SwiftUI
@testable import ViewInspector

final class InspectorTests: XCTestCase {
    
    private let testString = "abc"
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
        XCTAssertEqual(name1, "Test3<Int>")
        let name2 = Inspector.typeName(value: testValue)
        XCTAssertEqual(name2, "Test1")
        let name3 = Inspector.typeName(value: Test3<Int>(), prefixOnly: true)
        XCTAssertEqual(name3, "Test3")
    }
    
    func testTypeNameType() {
        let name1 = Inspector.typeName(type: Test3<Int>.self)
        XCTAssertEqual(name1, "Test3<Int>")
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
        XCTAssertFalse(Inspector.isTupleView((0, 2)))
    }
    
    func testGuardType() throws {
        let value = "abc"
        XCTAssertNoThrow(try Inspector.guardType(value: value, prefix: "String"))
        XCTAssertThrowsError(try Inspector.guardType(value: value, prefix: "Int"))
    }
    
    func testUnwrapNoModifiers() throws {
        let view = Text(testString)
        let sut = try Inspector.unwrap(view: view)
        let text = try (sut as? Text)?.inspect().string()
        XCTAssertEqual(text, testString)
    }
    
    func testUnwrapOneModifier() throws {
        let view = Text(testString).transition(.offset(.zero))
        let sut = try Inspector.unwrap(view: view)
        let text = try (sut as? Text)?.inspect().string()
        XCTAssertEqual(text, testString)
    }
    
    func testUnwrapTwoModifier() throws {
        let view = Text(testString)
            .transition(.offset(.zero)).accessibility(hint: Text(""))
        let sut = try Inspector.unwrap(view: view)
        let text = try (sut as? Text)?.inspect().string()
        XCTAssertEqual(text, testString)
    }
    
    #if os(iOS)
    func testUnwrapEnvironmentReaderView() throws {
        let view = NavigationView {
            List { Text("") }
                .navigationBarItems(trailing: Text(""))
        }
        XCTAssertThrowsError(try view.inspect().list(0))
    }
    #endif
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
