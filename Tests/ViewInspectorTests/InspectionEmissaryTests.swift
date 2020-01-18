import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

final class InspectionEmissaryTests: XCTestCase {
    
    func testDeprecatedOnFunction() throws {
        var sut = TestView(flag: false)
        let exp = sut.on(\.didAppear) { view in
            XCTAssertFalse(view.flag)
            try view.inspect().button().tap()
            XCTAssertTrue(view.flag)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testInspectAfter() throws {
        let sut = TestView(flag: false)
        let exp1 = sut.inspection.inspect { view in
            let text = try view.button().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(after: 0.1) { view in
            let text = try view.button().text().string()
            XCTAssertEqual(text, "true")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 0.2)
    }
    
    func testInspectOnReceive() throws {
        let sut = TestView(flag: false)
        let exp1 = sut.inspection.inspect { view in
            let text = try view.button().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
            let text = try view.button().text().string()
            XCTAssertEqual(text, "true")
            sut.publisher.send(false)
        }
        let exp3 = sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { view in
            let text = try view.button().text().string()
            XCTAssertEqual(text, "false")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2, exp3], timeout: 0.2)
    }
}

class Inspection<V>: InspectionEmissary where V: View & Inspectable {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()
    
    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

private struct TestView: View, Inspectable {
    
    @State private(set) var flag: Bool
    let publisher = PassthroughSubject<Bool, Never>()
    let inspection = Inspection<Self>()
    var didAppear: ((Self) -> Void)?
    
    var body: some View {
        Button(action: {
            self.flag.toggle()
        }, label: { Text(flag ? "true" : "false") })
        .onReceive(publisher) { self.flag = $0 }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onAppear { self.didAppear?(self) }
    }
}
