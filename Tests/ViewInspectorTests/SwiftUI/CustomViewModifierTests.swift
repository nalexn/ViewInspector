import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ModifiedContentTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = sampleView.modifier(TestModifier())
        let sut = try view.inspect().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testAccumulatesModifiers() throws {
        let view = Text("Test")
            .padding().modifier(TestModifier())
            .padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 5)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Text("Test").modifier(TestModifier()))
        XCTAssertEqual(try view.inspect().anyView().text().content.medium.viewModifiers.count, 2)
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
        }
        XCTAssertEqual(try view.inspect().hStack().text(0).content.medium.viewModifiers.count, 2)
        XCTAssertEqual(try view.inspect().hStack().text(1).content.medium.viewModifiers.count, 2)
    }
    
    func testNonInspectableModifier() throws {
        let sut = EmptyView().modifier(NonInspectableModifier())
        XCTAssertThrows(try sut.inspect().find(ViewType.ViewModifierContent.self),
                        "Search did not find a match")
    }
    
    func testNoModifiersError() throws {
        let sut = EmptyView().padding()
        XCTAssertThrows(try sut.inspect().emptyView().modifier(TestModifier.self),
                        "EmptyView does not have 'TestModifier' modifier")
        XCTAssertThrows(try sut.inspect().emptyView().modifier(TestModifier.self, 1),
                        "EmptyView does not have 'TestModifier' modifier at index 1")
    }
    
    func testSingleModifierInspection() throws {
        let view = EmptyView().modifier(TestModifier())
        let sut = try view.inspect().emptyView().modifier(TestModifier.self)
        let content = try sut.viewModifierContent()
        XCTAssertNoThrow(try content.callOnAppear())
        XCTAssertEqual(content.pathToRoot,
                       "emptyView().modifier(TestModifier.self).viewModifierContent()")
    }
    
    func testMultipleModifiersInspection() throws {
        let binding = Binding(wrappedValue: false)
        let view = EmptyView()
            .modifier(TestModifier(tag: 1))
            .padding()
            .modifier(TestModifier2(value: binding))
            .padding()
            .modifier(TestModifier(tag: 2))
        let sut1 = try view.inspect().emptyView().modifier(TestModifier.self)
        XCTAssertEqual(try sut1.actualView().tag, 1)
        let content1 = try sut1.viewModifierContent()
        XCTAssertEqual(content1.pathToRoot,
            "emptyView().modifier(TestModifier.self).viewModifierContent()")
        
        let sut2 = try view.inspect().emptyView().modifier(TestModifier2.self)
        let content2 = try sut2.find(ViewType.ViewModifierContent.self)
        XCTAssertEqual(content2.pathToRoot,
            "emptyView().modifier(TestModifier2.self).hStack().viewModifierContent(1)")
        
        let sut3 = try view.inspect().emptyView().modifier(TestModifier.self, 1)
        XCTAssertEqual(try sut3.actualView().tag, 2)
        let content3 = try sut3.viewModifierContent()
        XCTAssertEqual(content3.pathToRoot,
            "emptyView().modifier(TestModifier.self, 1).viewModifierContent()")
    }
    
    func testDirectAsyncInspection() throws {
        let binding = Binding(wrappedValue: false)
        var sut = TestModifier2(value: binding)
        let exp = XCTestExpectation(description: #function)
        sut.didAppear = { rawModifier in
            rawModifier.inspect { modifier in
                XCTAssertEqual(try modifier.hStack().viewModifierContent(1).padding().top, 15)
                try modifier.hStack().button(0).tap()
                XCTAssertEqual(try modifier.hStack().viewModifierContent(1).padding().top, 10)
            }
            ViewHosting.expel()
            exp.fulfill()
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnAsyncInspection() throws {
        let binding = Binding(wrappedValue: false)
        var sut = TestModifier2(value: binding)
        let exp = sut.on(\.didAppear) { modifier in
            XCTAssertEqual(try modifier.hStack().viewModifierContent(1).padding().top, 15)
            try modifier.hStack().button(0).tap()
            XCTAssertEqual(try modifier.hStack().viewModifierContent(1).padding().top, 10)
        }
        let view = EmptyView().modifier(sut)
        ViewHosting.host(view: view)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testModifierWithEnvObjects() throws {
        let sut1 = EmptyView().modifier(TestModifier3())
        XCTAssertThrows(try sut1.inspect().emptyView().modifier(TestModifier3.self, 0).text(1),
        "TestModifier3 is missing EnvironmentObjects: [\"viewModel: ExternalState\"]")
        XCTAssertThrows(try sut1.inspect().find(text: "obj1"),
        """
        Search did not find a match. Possible blockers: TestModifier3 \
        is missing EnvironmentObjects: [\"viewModel: ExternalState\"]
        """)
        
        let sut2 = EmptyView().modifier(TestModifier3()).environmentObject(ExternalState())
        let content = try sut2.inspect().emptyView().modifier(TestModifier3.self).group().viewModifierContent(0)
        XCTAssertEqual(content.pathToRoot,
            "emptyView().modifier(TestModifier3.self).group().viewModifierContent(0)")
        let text = try sut2.inspect().emptyView().modifier(TestModifier3.self).group().text(1)
        XCTAssertEqual(text.pathToRoot,
            "emptyView().modifier(TestModifier3.self).group().text(1)")
        XCTAssertEqual(try sut2.inspect().find(text: "obj1").pathToRoot,
            "emptyView().modifier(TestModifier3.self).group().text(1)")
    }
    
    func testApplyingInnerModifiersToTheContent() throws {
        let obj = ExternalState()
        let sut = TestModifier4.ViewWithEnvObject()
            .modifier(TestModifier4(injection: obj))
        let view1 = try sut.inspect().view(TestModifier4.ViewWithEnvObject.self)
        XCTAssertThrows(try view1.padding(), "ViewWithEnvObject does not have 'padding' modifier")
        XCTAssertTrue(view1.isHidden())
        XCTAssertTrue(view1.allowsTightening())
        obj.value = "other"
        let view2 = try sut.inspect().view(TestModifier4.ViewWithEnvObject.self)
        XCTAssertEqual(try view2.padding(), EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        XCTAssertThrows(try view2.offset(), "ViewWithEnvObject does not have 'offset' modifier")
        XCTAssertFalse(view2.isHidden())
        XCTAssertEqual(try view2.text().string(), "other")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct NonInspectableModifier: ViewModifier {
    func body(content: Self.Content) -> some View {
        content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestModifier: ViewModifier, Inspectable {
    var tag: Int = 0
    func body(content: Self.Content) -> some View {
        content.onAppear(perform: { })
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestModifier2: ViewModifier, Inspectable {
    
    @Binding var value: Bool
    var didAppear: ((Self) -> Void)?
    
    func body(content: Self.Content) -> some View {
        HStack {
            Button("Btn", action: { value.toggle() })
            content
                .padding(.top, value ? 10 : 15)
        }
        .onAppear { self.didAppear?(self) }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestModifier3: ViewModifier, Inspectable {
    
    @EnvironmentObject var viewModel: ExternalState
    
    func body(content: Self.Content) -> some View {
        Group {
            content
            Text(viewModel.value)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private class ExternalState: ObservableObject {
    @Published var value = "obj1"
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestModifier4: ViewModifier, Inspectable {
    
    let injection: ExternalState
    
    func body(content: Self.Content) -> some View {
        Group {
            EmptyView()
            if injection.value == "obj1" {
                AnyView(content)
                    .environment(\.allowsTightening, true)
                    .hidden()
            } else {
                HStack {
                    content
                        .padding(5)
                        .environmentObject(injection)
                }.offset()
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension TestModifier4 {
    struct ViewWithEnvObject: View, Inspectable {
        
        @EnvironmentObject var envObj: ExternalState
        
        var body: some View {
            Text(envObj.value)
        }
    }
}
