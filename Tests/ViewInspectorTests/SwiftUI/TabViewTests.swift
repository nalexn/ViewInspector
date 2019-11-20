import XCTest
import SwiftUI
@testable import ViewInspector

final class TabViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let view = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }
        let text = try view.inspect().text(0).string()
        XCTAssertEqual(text, "First View")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let tabView = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }
        let view = AnyView(tabView)
        XCTAssertNoThrow(try view.inspect().tabView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let tabView = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }
        let view = HStack { tabView; tabView }
        XCTAssertNoThrow(try view.inspect().tabView(0))
        XCTAssertNoThrow(try view.inspect().tabView(1))
    }
}

private struct TestView: View, Inspectable {
    @ObservedObject var state = NavigationState()
    
    var tag1: String { "tag1" }
    var tag2: String { "tag2" }
    
    var body: some View {
        TabView(selection: $state.selection) {
            Text("First View").tabItem({ Text("First") }).tag(tag1)
            Text("Second View").tabItem({ Text("Second") }).tag(tag2)
        }
    }
}

extension TestView {
    class NavigationState: ObservableObject {
        @Published var selection: String?
    }
}
