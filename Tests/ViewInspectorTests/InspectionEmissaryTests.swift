import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class InspectionEmissaryTests: XCTestCase {
    
    func testOnFunction() throws {
        var sut = TestView(flag: false)
        let exp = sut.on(\.didAppear) { view in
            XCTAssertFalse(try view.actualView().flag)
            try view.button().tap()
            XCTAssertTrue(try view.actualView().flag)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testInspectAfter() throws {
        let sut = TestView(flag: false)
        let exp1 = sut.inspection.inspect { view in
            let text = try view.button().labelView().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(after: 0.1) { view in
            let text = try view.button().labelView().text().string()
            XCTAssertEqual(text, "true")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 0.2)
    }
    
    func testInspectOnReceive() throws {
        let sut = TestView(flag: false)
        let exp1 = sut.inspection.inspect { view in
            let text = try view.button().labelView().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
            let text = try view.button().labelView().text().string()
            XCTAssertEqual(text, "true")
            sut.publisher.send(false)
        }
        let exp3 = sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { view in
            let text = try view.button().labelView().text().string()
            XCTAssertEqual(text, "false")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2, exp3], timeout: 0.2)
    }
    
    func testViewModifierOnFunction() throws {
        let title = Title()
        @Binding var flag = false
        var sut = InspectableTestModifier(title: title, flag: $flag)
        let exp = sut.on(\.didAppear) { body in
            let content = try body.hStack().viewModifierContent(0)
            XCTAssertEqual(try content.offset(), CGSize(width: 10, height: 10))
            let object = content.content.medium.environmentObjects[0] as? Title
            XCTAssertEqual(object?.value, "Monkey Wrench")
            
            XCTAssertEqual(try body.hStack().button(1).labelView().text().string(), "false")
            try body.hStack().button(1).tap()
            XCTAssertEqual(try body.hStack().button(1).labelView().text().string(), "true")
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.2)
    }

    func testViewModifierInspectAfter() throws {
        let title = Title()
        let flag = Binding<Bool>(wrappedValue: false)

        let sut = InspectableTestModifier(title: title, flag: flag)
        let exp1 = sut.inspection.inspect { body in
            let content = try body.hStack().viewModifierContent(0)
            XCTAssertEqual(try content.offset(), CGSize(width: 10, height: 10))
            let object = content.content.medium.environmentObjects[0] as? Title
            XCTAssertEqual(object?.value, "Monkey Wrench")

            let text = try body.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(after: 0.1) { body in
            let text = try body.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "true")
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func testViewModifierOnReceive() throws {
        let title = Title()
        let flag = Binding<Bool>(wrappedValue: false)
        
        let sut = InspectableTestModifier(title: title, flag: flag)
        let exp1 = sut.inspection.inspect { body in
            let text = try body.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { body in
            let content = try body.hStack().viewModifierContent(0)
            XCTAssertEqual(try content.offset(), CGSize(width: 10, height: 10))
            let object = content.content.medium.environmentObjects[0] as? Title
            XCTAssertEqual(object?.value, "Monkey Wrench")

            let text = try body.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "true")
            sut.publisher.send(false)
        }
        let exp3 = sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { body in
            let text = try body.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "false")
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp1, exp2, exp3], timeout: 0.2)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Inspection: InspectionEmissary where V: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
class Inspection<V> where V: View {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

extension InspectionForViewModifier: InspectionEmissaryForViewModifier where V: Inspectable, V.Body: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
class InspectionForViewModifier<V> where V: ViewModifier {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V.Body) -> Void]()

    func visit(_ body: V.Body, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(body)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
class Title: ObservableObject {
    @Published var value = "Monkey Wrench"
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableTestModifier: ViewModifier, Inspectable {

    typealias Body = BodyView
    
    @ObservedObject var title: Title
    @Binding var flag: Bool
    let publisher = PassthroughSubject<Bool, Never>()
    let inspection = InspectionForViewModifier<Self>()
    var didAppear: ((Self.Body) -> Void)?

    func body(content: Self.Content) -> BodyView {
        BodyView(content: content, title: title, flag: $flag,
                 publisher: publisher, inspection: inspection, didAppear: didAppear)
    }
    
    struct BodyView: View & Inspectable {
        
        let content: InspectableTestModifier.Content
        @ObservedObject var title: Title
        @Binding var flag: Bool
        let publisher: PassthroughSubject<Bool, Never>
        let inspection: InspectionForViewModifier<InspectableTestModifier>
        var didAppear: ((Self) -> Void)?
        
        var body: some View {
            HStack {
                content
                    .offset(x: 10, y: 10)
                    .environmentObject(title)
                Button(
                    action: { self.flag.toggle() },
                    label: { Text(flag ? "true" : "false").id("label") }
                )
            }
            .onReceive(publisher) { self.flag = $0 }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
            .onAppear { self.didAppear?(self) }
        }
    }
}
