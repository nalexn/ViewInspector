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
    
    func testUnsafeMemoryBindError() throws {
        XCTAssertThrows(
            try Inspector.unsafeMemoryRebind(value: Int(8), type: Bool.self),
            """
            Unable to rebind value of type Swift.Int to Swift.Bool. This is \
            an internal library error, please open a ticket with these details.
            """)
    }
    
    func testTypeNameValue() {
        let name1 = Inspector.typeName(value: Struct3<Int>())
        XCTAssertEqual(name1, "Struct3<Int>")
        let name2 = Inspector.typeName(value: testValue)
        XCTAssertEqual(name2, "Struct1")
        let name3 = Inspector.typeName(value: Struct3<Int>(), generics: .remove)
        XCTAssertEqual(name3, "Struct3")
        let name4 = Inspector.typeName(value: Struct3<(String) -> Void>(), generics: .remove)
        XCTAssertEqual(name4, "Struct3")
        let name5 = Inspector.typeName(value: (Struct3<Int>(), Struct3<String>()), generics: .remove)
        XCTAssertEqual(name5, "(Struct3, Struct3)")
    }
    
    func testTypeNameType() {
        let name1 = Inspector.typeName(type: Struct3<Int>.self)
        XCTAssertEqual(name1, "Struct3<Int>")
        let name2 = Inspector.typeName(type: Struct1.self)
        XCTAssertEqual(name2, "Struct1")
        let name3 = Inspector.typeName(
            type: ModifiedContent<EmptyView, _EnvironmentKeyWritingModifier<(String) -> Void>>.self,
            generics: .remove)
        XCTAssertEqual(name3, "ModifiedContent")
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
    
    func testPrintClassHierarchy() {
        let sut = TestDerivedClass()
        let str = """
                TestDerivedClass
                  reference: Optional<AnyObject> = nil
                  value: Int = 5
                
                """
        XCTAssertEqual(Inspector.print(sut), str)
    }
    
    func testPrintCyclicReferences() {
        let obj1 = TestBaseClass()
        obj1.reference = obj1
        let obj2 = TestBaseClass(), obj3 = TestBaseClass(), obj4 = TestBaseClass()
        obj2.reference = obj3
        obj3.reference = obj4
        obj4.reference = obj2
        let str1 = """
                TestBaseClass
                  reference: Optional<AnyObject>
                    some: TestBaseClass = { cyclic reference }

                """
        let str2 = """
                TestBaseClass
                  reference: Optional<AnyObject>
                    some: TestBaseClass
                      reference: Optional<AnyObject>
                        some: TestBaseClass
                          reference: Optional<AnyObject>
                            some: TestBaseClass = { cyclic reference }

                """
        XCTAssertEqual(Inspector.print(obj1), str1)
        XCTAssertEqual(Inspector.print(obj2), str2)
    }
    
    func testPrintTypeReference() {
        let sut = ViewWithTypeReference()
        XCTAssertEqual(Inspector.print(sut), """
            ViewWithTypeReference
              body: EmptyView = EmptyView()
              ref: Any.Type
            
            """)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTupleView() throws {
        let view = HStack { Text(""); Text("") }
        let content = try Inspector.attribute(path: "_tree|content", value: view)
        XCTAssertTrue(Inspector.isTupleView(content))
        XCTAssertFalse(Inspector.isTupleView((0, 2)))
    }
    
    func testGuardType() throws {
        let value = "abc"
        XCTAssertNoThrow(try Inspector.guardType(
                            value: value, namespacedPrefixes: ["Swift.String"], inspectionCall: ""))
        XCTAssertThrows(
            try Inspector.guardType(value: value, namespacedPrefixes: ["Swift.Int"], inspectionCall: ""),
            "Type mismatch: Swift.String is not Swift.Int")
    }
    
    func testUnwrapNoModifiers() throws {
        let view = Text(testString)
        let sut = try Inspector.unwrap(view: view, medium: .empty)
        let text = try (sut.view as? Text)?.inspect().text().string()
        XCTAssertEqual(text, testString)
    }
    
    func testUnwrapOneModifier() throws {
        let view = Text(testString).transition(.offset(.zero))
        let sut = try Inspector.unwrap(view: view, medium: .empty)
        let text = try (sut.view as? Text)?.inspect().text().string()
        XCTAssertEqual(text, testString)
    }
    
    func testUnwrapTwoModifier() throws {
        let publisher = PassthroughSubject<Bool, Never>()
        let view = Text(testString)
            .transition(.offset(.zero))
            .onReceive(publisher) { _ in }
        let sut = try Inspector.unwrap(view: view, medium: .empty)
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
    
    func testParentModifierAttribute() throws {
        let sut1 = AnyView(EmptyView()).onAppear { }
        XCTAssertNoThrow(try sut1.inspect().anyView().callOnAppear())
        XCTAssertNoThrow(try sut1.inspect().anyView().emptyView().parent().callOnAppear())
        XCTAssertNoThrow(try sut1.inspect().anyView().emptyView().parent().anyView().callOnAppear())
        
        let sut2 = EmptyView()
            .onAppear { }
            .overlay(
                HStack { EmptyView() }
            )
            .onDisappear { }
        XCTAssertNoThrow(try sut2.inspect().emptyView().overlay().hStack())
        XCTAssertNoThrow(try sut2.inspect().emptyView().overlay().parent())
        XCTAssertNoThrow(try sut2.inspect().emptyView().overlay().parent().callOnAppear())
        XCTAssertNoThrow(try sut2.inspect().emptyView().overlay().parent().emptyView().callOnDisappear())
    }
    
    func testParentInspection() throws {
        let view = AnyView(Group {
            Text("")
            EmptyView()
                .padding()
                .overlay(HStack {
                    EmptyView()
                    TestPrintView().padding()
                })
           })
        let sut = try view.inspect().anyView().group().emptyView(1).overlay()
            .hStack().view(TestPrintView.self, 1).text()
        // Cannot use `XCTAssertThrows` because test target changes name
        // between ViewInspectorTests and ViewInspector_Unit_Tests under cocoapods tests
        // ViewInspectorTests.TestPrintView vs ViewInspector_Unit_Tests.TestPrintView
        do {
            _ = try sut.parent().group()
            XCTFail("Expected to throw")
        } catch let error {
            let message = error.localizedDescription
            XCTAssertTrue(message
                .hasPrefix("anyView().group().emptyView(1).overlay().hStack().group() found "))
            XCTAssertTrue(message
                .hasSuffix(".TestPrintView instead of Group"))
        }
        XCTAssertNoThrow(try sut.parent().view(TestPrintView.self))
        let hStack = try sut.parent().parent().hStack()
        XCTAssertNoThrow(try hStack.parent().overlay())
        XCTAssertNoThrow(try hStack.parent().parent().emptyView())
        let group = try hStack.parent().parent().parent().group()
        let anyView = try group.parent()
        XCTAssertNoThrow(try anyView.anyView())
        XCTAssertThrows(try anyView.parent(), "AnyView does not have parent")
        XCTAssertThrows(try view.inspect().parent(), "AnyView does not have parent")
    }
    
    func testPathToRootSimpleHierarchy() throws {
        let view1 = EmptyView()
        let sut1 = try view1.inspect()
        XCTAssertEqual(sut1.pathToRoot, "")
        let sut2 = try view1.inspect().emptyView()
        XCTAssertEqual(sut2.pathToRoot, "emptyView()")
        let view2 = TestPrintView()
        let sut3 = try view2.inspect()
        XCTAssertEqual(sut3.pathToRoot, "")
        let sut4 = try view2.inspect().text()
        XCTAssertEqual(sut4.pathToRoot, "view(TestPrintView.self).text()")
        let sut5 = try view2.inspect().text(0)
        XCTAssertEqual(sut5.pathToRoot, "view(TestPrintView.self).text(0)")
    }
    
    func testPathToRootComplexHierarchy() throws {
        let view1 = AnyView(Group {
            Text("")
            EmptyView()
                .padding()
                .overlay(HStack {
                    EmptyView()
                    TestPrintView().padding()
                })
           })
        let sut1 = try view1.inspect().anyView().group().emptyView(1).overlay()
            .hStack().view(TestPrintView.self, 1).text()
        XCTAssertEqual(sut1.pathToRoot,
        "anyView().group().emptyView(1).overlay().hStack().view(TestPrintView.self, 1).text()")
        XCTAssertEqual(try sut1.parent().pathToRoot,
        "anyView().group().emptyView(1).overlay().hStack().view(TestPrintView.self, 1)")
        XCTAssertEqual(try sut1.parent().parent().pathToRoot,
        "anyView().group().emptyView(1).overlay().hStack()")
        XCTAssertEqual(try sut1.parent().parent().hStack().pathToRoot,
        "anyView().group().emptyView(1).overlay().hStack()")
        XCTAssertEqual(try sut1.parent().parent().parent().pathToRoot,
        "anyView().group().emptyView(1).overlay()")
        XCTAssertEqual(try sut1.parent().parent().parent().parent().pathToRoot,
        "anyView().group().emptyView(1)")
        XCTAssertEqual(try sut1.parent().parent().parent().parent().emptyView().pathToRoot,
        "anyView().group().emptyView()")
        XCTAssertEqual(try sut1.parent().parent().parent().parent().emptyView().overlay().pathToRoot,
        "anyView().group().emptyView().overlay()")
        XCTAssertEqual(try sut1.parent().view(TestPrintView.self)
                        .parent().hStack() .parent().overlay().parent().pathToRoot,
        "anyView().group().emptyView(1)")
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
private struct TestPrintView: View {
    
    let str = ["abc", "def"]
    
    var body: some View {
        Text(str[0])
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ViewWithTypeReference: View {
    
    let ref = ViewWithTypeReference.self
    
    var body: some View {
        EmptyView()
    }
}

private class TestBaseClass {
    weak var reference: AnyObject?
}
private final class TestDerivedClass: TestBaseClass {
    var value: Int = 5
}
