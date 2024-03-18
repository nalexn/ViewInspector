import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class InspectionEmissaryTests: XCTestCase {
    
    func testViewOnFunction() throws {
        var sut = TestView(flag: false)
        let exp = sut.on(\.didAppear) { view in
            XCTAssertFalse(try view.actualView().flag)
            try view.button().tap()
            XCTAssertTrue(try view.actualView().flag)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testViewModifierOnFunction() throws {
        let binding = Binding(wrappedValue: false)
        var sut = TestViewModifier(flag: binding)
        let exp = sut.on(\.didAppear) { view in
            XCTAssertFalse(try view.actualView().flag)
            try view.hStack().button(1).tap()
            XCTAssertTrue(try view.actualView().flag)
        }
        let view = EmptyView()
            .modifier(sut)
            .environmentObject(ExternalState())
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testViewInspectAfter() throws {
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
    
    func testViewModifierInspectAfter() throws {
        let binding = Binding(wrappedValue: false)
        let sut = TestViewModifier(flag: binding)
        let exp1 = sut.inspection.inspect { view in
            let text = try view.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(after: 0.1) { view in
            let texts = view.findAll(ViewType.Text.self)
            XCTAssertEqual(texts.count, 2)
            let text = try view.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "true")
        }
        let view = EmptyView()
            .modifier(sut)
            .environmentObject(ExternalState())
        ViewHosting.host(view: view)
        wait(for: [exp1, exp2], timeout: 0.2)
    }
    
    func testViewInspectOnReceive() throws {
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
    
    func testViewInspectOnReceiveAfter() throws {
        let sut = TestView(flag: false)
        let exp1 = sut.inspection.inspect { view in
            let text = try view.button().labelView().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(onReceive: sut.publisher, after: 0.1) { view in
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
    
    func testViewModifierInspectOnReceive() throws {
        let binding = Binding(wrappedValue: false)
        let sut = TestViewModifier(flag: binding)
        let exp1 = sut.inspection.inspect { view in
            let text = try view.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
            let text = try view.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "true")
            sut.publisher.send(false)
        }
        let exp3 = sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { view in
            let text = try view.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "false")
        }
        let view = EmptyView()
            .modifier(sut)
            .environmentObject(ExternalState())
        ViewHosting.host(view: view)
        wait(for: [exp1, exp2, exp3], timeout: 0.2)
    }
    
    func testViewModifierInspectOnReceiveAfter() throws {
        let binding = Binding(wrappedValue: false)
        let sut = TestViewModifier(flag: binding)
        let exp1 = sut.inspection.inspect { view in
            let text = try view.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "false")
            sut.publisher.send(true)
        }
        let exp2 = sut.inspection.inspect(onReceive: sut.publisher, after: 0.1) { view in
            let text = try view.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "true")
            sut.publisher.send(false)
        }
        let exp3 = sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { view in
            let text = try view.hStack().button(1).labelView().text().string()
            XCTAssertEqual(text, "false")
        }
        let view = EmptyView()
            .modifier(sut)
            .environmentObject(ExternalState())
        ViewHosting.host(view: view)
        wait(for: [exp1, exp2, exp3], timeout: 0.2)
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func testAsyncViewInspectAfter() async throws {
        let sut = TestView(flag: false)
        try await ViewHosting.host(sut) {
            try await $0.inspection.inspect { view in
                let text = try view.button().labelView().text().string()
                XCTAssertEqual(text, "false")
                sut.publisher.send(true)
            }
            try await $0.inspection.inspect(after: .seconds(0.1)) { view in
                let text = try view.button().labelView().text().string()
                XCTAssertEqual(text, "true")
            }
        }
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func testAsyncViewModifierInspectAfter() async throws {
        let binding = Binding(wrappedValue: false)
        let sut = TestViewModifier(flag: binding)
        let view = EmptyView()
            .modifier(sut)
            .environmentObject(ExternalState())
        try await ViewHosting.host(view) { _ in
            try await sut.inspection.inspect { view in
                let text = try view.hStack().button(1).labelView().text().string()
                XCTAssertEqual(text, "false")
                sut.publisher.send(true)
            }
            try await sut.inspection.inspect(after: .seconds(0.1)) { view in
                let texts = view.findAll(ViewType.Text.self)
                XCTAssertEqual(texts.count, 2)
                let text = try view.hStack().button(1).labelView().text().string()
                XCTAssertEqual(text, "true")
            }
        }
    }
    
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    func testAsyncViewInspectOnReceive() async throws {
        let sut = TestView(flag: false)
        try await ViewHosting.host(sut) { sut in
            try await withThrowingDiscardingTaskGroup { group in
                group.addTask {
                    try await sut.inspection.inspect { view in
                        let text = try view.button().labelView().text().string()
                        XCTAssertEqual(text, "false")
                        sut.publisher.send(true)
                    }
                }
                
                group.addTask {
                    try await sut.inspection.inspect(onReceive: sut.publisher) { view in
                        let text = try view.button().labelView().text().string()
                        XCTAssertEqual(text, "true")
                        sut.publisher.send(false)
                    }
                }
                
                group.addTask {
                    try await sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { view in
                        let text = try view.button().labelView().text().string()
                        XCTAssertEqual(text, "false")
                    }
                }
            }
        }
    }
    
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    func testAsyncViewInspectOnReceiveAfter() async throws {
        let sut = TestView(flag: false)
        try await ViewHosting.host(sut) { sut in
            try await withThrowingDiscardingTaskGroup { group in
                group.addTask {
                    try await sut.inspection.inspect { view in
                        let text = try view.button().labelView().text().string()
                        XCTAssertEqual(text, "false")
                        sut.publisher.send(true)
                    }
                }
                
                group.addTask {
                    try await sut.inspection.inspect(onReceive: sut.publisher, after: .seconds(0.1)) { view in
                        let text = try view.button().labelView().text().string()
                        XCTAssertEqual(text, "true")
                        sut.publisher.send(false)
                    }
                }
                
                group.addTask {
                    try await sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { view in
                        let text = try view.button().labelView().text().string()
                        XCTAssertEqual(text, "false")
                    }
                }
            }
        }
    }
    
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    func testAsyncViewModifierInspectOnReceive() async throws {
        let binding = Binding(wrappedValue: false)
        let sut = TestViewModifier(flag: binding)
        let view = EmptyView()
            .modifier(sut)
            .environmentObject(ExternalState())
        try await ViewHosting.host(view) { _ in
            try await withThrowingDiscardingTaskGroup { group in
                group.addTask {
                    try await sut.inspection.inspect { view in
                        let text = try view.hStack().button(1).labelView().text().string()
                        XCTAssertEqual(text, "false")
                        sut.publisher.send(true)
                    }
                }
                
                group.addTask {
                    try await sut.inspection.inspect(onReceive: sut.publisher) { view in
                        let text = try view.hStack().button(1).labelView().text().string()
                        XCTAssertEqual(text, "true")
                        sut.publisher.send(false)
                    }
                }
                
                group.addTask {
                    try await sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { view in
                        let text = try view.hStack().button(1).labelView().text().string()
                        XCTAssertEqual(text, "false")
                    }
                }
            }
        }
    }
    
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    func testAsyncViewModifierInspectOnReceiveAfter() async throws {
        let binding = Binding(wrappedValue: false)
        let sut = TestViewModifier(flag: binding)
        let view = EmptyView()
            .modifier(sut)
            .environmentObject(ExternalState())
        try await ViewHosting.host(view) { _ in
            try await withThrowingDiscardingTaskGroup { group in
                group.addTask {
                    try await sut.inspection.inspect { view in
                        let text = try view.hStack().button(1).labelView().text().string()
                        XCTAssertEqual(text, "false")
                        sut.publisher.send(true)
                    }
                }
                
                group.addTask {
                    try await sut.inspection.inspect(onReceive: sut.publisher, after: .seconds(0.1)) { view in
                        let text = try view.hStack().button(1).labelView().text().string()
                        XCTAssertEqual(text, "true")
                        sut.publisher.send(false)
                    }
                }
                
                group.addTask {
                    try await sut.inspection.inspect(onReceive: sut.publisher.dropFirst()) { view in
                        let text = try view.hStack().button(1).labelView().text().string()
                        XCTAssertEqual(text, "false")
                    }
                }
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class Inspection<V>: InspectionEmissary {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()
    
    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestView: View {
    
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
private class ExternalState: ObservableObject {
    @Published var value = "env_value"
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestViewModifier: ViewModifier {
    
    @Binding var flag: Bool
    @EnvironmentObject var envState: ExternalState
    let publisher = PassthroughSubject<Bool, Never>()
    let inspection = Inspection<Self>()
    var didAppear: ((Self) -> Void)?
    
    func body(content: Self.Content) -> some View {
        HStack {
            content
            Button(action: {
                self.flag.toggle()
            }, label: { Text(flag ? "true" : "false") })
            Text(envState.value)
        }
        .onReceive(publisher) { self.flag = $0 }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onAppear { self.didAppear?(self) }
    }
}
