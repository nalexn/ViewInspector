import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
final class OutlineGroupTests: XCTestCase {
    
    struct TestTree<Value: Hashable>: Hashable {
        let testValue: Value
        var testChildren: [TestTree]?
    }
    
    let values: [TestTree<String>] = [
        .init(
            testValue: "l1",
            testChildren: [
                .init(testValue: "l1v1"),
                .init(testValue: "v2v2"),
                .init(
                    testValue: "l2",
                    testChildren: [
                        .init(testValue: "l2v2"),
                        .init(testValue: "l2v2")
                    ]
                ),
            ]
        )
    ]
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(OutlineGroup(values[0], id: \.testValue, children: \.testChildren) { _ in
            EmptyView()
        })
        XCTAssertNoThrow(try view.inspect().anyView().outlineGroup())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            EmptyView()
            OutlineGroup(values[0], id: \.testValue, children: \.testChildren) { _ in
                EmptyView()
            }
            EmptyView()
        }
        XCTAssertNoThrow(try view.inspect().hStack().outlineGroup(1))
    }
    
    func testSourceDataInspection() throws {
        let view1 = OutlineGroup(values, id: \.testValue, children: \.testChildren) { _ in
            EmptyView()
        }
        let view2 = OutlineGroup(values[0], id: \.testValue, children: \.testChildren) { _ in
            EmptyView()
        }
        XCTAssertThrows(try view1.inspect().outlineGroup().sourceData(TestTree<String>.self),
                        "Type mismatch: Array<TestTree<String>> is not TestTree<String>")
        XCTAssertEqual(try view1.inspect().outlineGroup().sourceData([TestTree<String>].self), values)
        XCTAssertEqual(try view2.inspect().outlineGroup().sourceData(TestTree<String>.self), values[0])
        XCTAssertThrows(try view2.inspect().outlineGroup().sourceData([TestTree<String>].self),
                        "Type mismatch: TestTree<String> is not Array<TestTree<String>>")
    }
    
    func testLeafInspection() throws {
        let view = OutlineGroup(values[0], id: \.testValue, children: \.testChildren) { element in
            Text(element.testValue)
        }
        let data = values[0].testChildren![2]
        let sut = try view.inspect().outlineGroup().leaf(data, Text.self).text().string()
        XCTAssertEqual(sut, "l2")
    }
}
#endif
