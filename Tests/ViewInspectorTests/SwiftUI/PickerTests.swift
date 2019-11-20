import XCTest
import SwiftUI
@testable import ViewInspector

final class PickerTests: XCTestCase {
    
    @State private var selection: Int?
    
    func testEnclosedView() throws {
        let view = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let text = try view.inspect().text(0).string()
        XCTAssertEqual(text, "First Option")
    }
    
    func testLabelView() throws {
        let view = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let text = try view.inspect().label().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let picker = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let view = AnyView(picker)
        XCTAssertNoThrow(try view.inspect().picker())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let picker = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let view = HStack { picker; picker }
        XCTAssertNoThrow(try view.inspect().picker(0))
        XCTAssertNoThrow(try view.inspect().picker(1))
    }
}

private struct TestView: View, Inspectable {
    @ObservedObject var state = State()
    
    var tag1: String { "tag1" }
    var tag2: String { "tag2" }
    
    var body: some View {
        Picker(selection: $state.selection, label: Text("Title")) {
            Text("First Option").tag(tag1)
            Text("Second Option").tag(tag2)
        }
    }
}

extension TestView {
    class State: ObservableObject {
        @Published var selection: String?
    }
}
