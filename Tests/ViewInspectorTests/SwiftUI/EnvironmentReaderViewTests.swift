import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(tvOS)
@available(iOS 13.0, tvOS 13.0, *)
final class EnvironmentReaderViewTests: XCTestCase {
    
    func skipForiOS15(file: StaticString = #file, line: UInt = #line) throws {
        if #available(iOS 15.0, tvOS 15.0, *) {
            throw XCTSkip("Not relevant for iOS 15", file: file, line: line)
        }
    }
    
    func testUnaryViewAdaptor() throws {
        guard #available(iOS 15.0, tvOS 15.0, *) else { return }
        let sut = EmptyView()
            .navigationBarItems(trailing: Text("abc"))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testIncorrectUnwrap() throws {
        try skipForiOS15()
        let view = NavigationView {
            List { Text("") }
                .navigationBarItems(trailing: Text(""))
        }
        XCTAssertThrows(
            try view.inspect().navigationView().list(0).text(0),
            "Please insert '.navigationBarItems()' before list(0) for unwrapping the underlying view hierarchy.")
    }
    
    func testUnknownHierarchyTypeUnwrap() throws {
        try skipForiOS15()
        let view = NavigationView {
            List { Text("") }
                .navigationBarItems(trailing: Text(""))
        }
        XCTAssertThrows(
            try view.inspect().navigationView().navigationBarItems().list(),
            "Please substitute 'List<Never, Text>.self' as the parameter for 'navigationBarItems()' inspection call")
    }
    
    func testKnownHierarchyTypeUnwrap() throws {
        try skipForiOS15()
        let string = "abc"
        let view = NavigationView {
            List { Text(string) }
                .navigationBarItems(trailing: Text(""))
        }
        let value = try view.inspect().navigationView()
            .navigationBarItems(List<Never, Text>.self)
            .list().text(0).string()
        XCTAssertEqual(value, string)
    }
    
    func testSearchBlocker() throws {
        try skipForiOS15()
        let view = AnyView(NavigationView {
            Text("abc")
                .navigationBarItems(trailing: Text(""))
        })
        XCTAssertThrows(try view.inspect().find(text: "abc"),
                        "Search did not find a match. Possible blockers: navigationBarItems")
        XCTAssertNoThrow(try view.inspect().find(where: { (try? $0.navigationBarItems(Text.self)) != nil }))
    }
    
    func testRetainsModifiers() throws {
        try skipForiOS15()
        let view = NavigationView {
            Text("")
                .padding()
                .navigationBarItems(trailing: Text(""))
                .padding().padding()
        }
        let sut = try view.inspect().navigationView()
            .navigationBarItems(ModifiedContent<Text, _PaddingLayout>.self)
            .text()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 4)
    }
    
    func testMissingModifier() throws {
        try skipForiOS15()
        let sut = EmptyView().padding()
        XCTAssertThrows(
            try sut.inspect().navigationBarItems(),
            "EmptyView does not have 'navigationBarItems' modifier")
    }
    
    func testCustomViewUnwrapStepOne() throws {
        try skipForiOS15()
        let sut = TestView()
        let exp = sut.inspection.inspect { view in
            XCTAssertThrows(try view.vStack(),
            "Please insert '.navigationBarItems()' before vStack() for unwrapping the underlying view hierarchy.")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testCustomViewUnwrapStepTwo() throws {
        try skipForiOS15()
        let sut = TestView()
        let exp = sut.inspection.inspect { view in
            XCTAssertThrows(try view.navigationBarItems().vStack(),
            "Please substitute 'VStack<Text>.self' as the parameter for 'navigationBarItems()' inspection call")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testCustomViewUnwrapStepThree() throws {
        try skipForiOS15()
        let sut = TestView()
        let exp = sut.inspection.inspect { view in
            typealias WrappedView = VStack<Text>
            let value = try view.navigationBarItems(WrappedView.self).vStack().text(0).string()
            XCTAssertEqual(value, "abc")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestView: View, Inspectable {
    
    let inspection = Inspection<Self>()
        
    var body: some View {
        VStack {
            Text("abc")
        }
        .navigationBarItems(trailing: button)
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
        
    private var button: some View {
        Button("", action: { })
    }
}
#endif
