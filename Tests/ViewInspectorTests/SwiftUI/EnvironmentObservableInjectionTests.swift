import XCTest
import SwiftUI
#if canImport(Observation)
import Observation
#endif

@testable import ViewInspector

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class EnvironmentObservableInjectionTests: XCTestCase {

    func testEnvironmentMemoryLayout() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        typealias RealType = Environment<TestObservableObject1>
        XCTAssertEqual(MemoryLayout<RealType>.size, EnvValue.structSize)
        let sut = RealType(\.testObservableObject1)
        try withUnsafeBytes(of: sut, { bytes in
            let discriminator = try XCTUnwrap(bytes.last)
            XCTAssertEqual(discriminator, EnvValue.keyPathCase)
        })
    }

    func testEnvironmentForgery() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let obj = TestObservableObject1()
        let forgery = EnvValue.Forgery(object: obj)
        let sut = unsafeBitCast(forgery, to: Environment<TestObservableObject1>.self)
        XCTAssertIdentical(sut.wrappedValue, obj)
    }

    func testDirectEnvironmentInjection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let obj1 = TestObservableObject1()
        let obj2 = TestObservableObject2()
        var sut = ObservableInnerView()
        sut = EnvironmentInjection.inject(environmentObject: obj1, into: sut)
        sut = EnvironmentInjection.inject(environmentObject: obj2, into: sut)
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "env_true")
    }

    func testEnvironmentInjectionDuringSyncInspection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let obj1 = TestObservableObject1()
        let obj2 = TestObservableObject2()
        let sut = ObservableOuterView()
            .environment(obj1)
            .environment(obj2)
        XCTAssertNoThrow(try sut.inspect().find(text: "env_true"))
        try sut.inspect().find(button: "Flag").tap()
        XCTAssertNoThrow(try sut.inspect().find(text: "env_false"))
        XCTAssertEqual(try sut.inspect().findAll(ViewType.Text.self).first?.string(), "env_false")
    }

    func testOptionalEnvironmentInjection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let obj1 = TestObservableObject1()
        let sut = ObservableOptionalView()
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "none")
        XCTAssertEqual(try sut.environment(obj1).inspect().find(ViewType.Text.self).string(), "env")
    }

    func testInjectedObjectIsRetainedAndReleased() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        weak var weakObject: TestObservableObject1?
        try {
            let object = TestObservableObject1()
            weakObject = object
            var sut = ObservableOptionalView()
            sut = EnvironmentInjection.inject(environmentObject: object, into: sut)
            XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "env")
        }()
        XCTAssertNil(weakObject)
    }

    func testEnvironmentInjectionInActualView() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let obj1 = TestObservableObject1()
        let obj2 = TestObservableObject2()
        let sut = ObservableInnerView().environment(obj1).environment(obj2)
        let view = try sut.inspect().find(ObservableInnerView.self).actualView()
        XCTAssertIdentical(view.obj1, obj1)
        XCTAssertIdentical(view.obj2, obj2)
    }

    func testEnvironmentInjectionOnDidAppearInspection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let obj1 = TestObservableObject1()
        let obj2 = TestObservableObject2()
        var sut = ObservableOuterView()
        let exp = sut.on(\.didAppear) { view in
            XCTAssertNoThrow(try view.find(text: "env_true"))
            try view.find(button: "Flag").tap()
            XCTAssertNoThrow(try view.find(text: "env_false"))
        }
        ViewHosting.host(view: sut.environment(obj1).environment(obj2))
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: 0.5)
    }

    func testEnvironmentInjectionDuringAsyncInspection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let obj1 = TestObservableObject1()
        let obj2 = TestObservableObject2()
        let sut = ObservableOuterView()
        // Note: unlike with `@EnvironmentObject`, only one inspection of the hosted
        // view is possible: SwiftUI drops the `Observable` objects from the
        // environment once it re-renders the hierarchy.
        let exp = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: "env_true"))
            try view.find(button: "Flag").tap()
            XCTAssertNoThrow(try view.find(text: "env_false"))
        }
        ViewHosting.host(view: sut.environment(obj1).environment(obj2))
        defer { ViewHosting.expel() }
        wait(for: [exp], timeout: 0.5)
    }

    func testEnvironmentValueOfTheSameTypeIsUnaffected() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let injected = TestObservableObject1()
        injected.value1 = "injected"
        let keyed = TestObservableObject1()
        let sut = ObservableEnvironmentValueView()
            .environment(injected)
            .environment(\.testObservableObject1, keyed)
        // The keyed property is not injected, thus reading the key's default value:
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "env_injected")
        let view = try sut.inspect().find(ObservableEnvironmentValueView.self)
        XCTAssertIdentical(try view.environment(\.testObservableObject1), keyed)
    }
}

// MARK: -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
private class TestObservableObject1 {
    var value1 = "env"
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@Observable
private class TestObservableObject2 {
    var value2 = true
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private extension EnvironmentValues {
    var testObservableObject1: TestObservableObject1 {
        get { self[TestObservableObject1Key.self] }
        set { self[TestObservableObject1Key.self] = newValue }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct TestObservableObject1Key: EnvironmentKey {
    static var defaultValue: TestObservableObject1 { .init() }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct ObservableInnerView: View {

    private var iVar1: Int8 = 0
    private var iVar2: Int16 = 0
    @Environment(TestObservableObject2.self) var obj2
    private var iVar3: Int32 = 0
    @Environment(\.isEnabled) private var isEnabled
    @Environment(TestObservableObject1.self) var obj1
    @State var flag: Bool = false
    private var iVar4: Bool = false

    var body: some View {
        VStack {
            Text(obj1.value1 + "_\(obj2.value2)")
            Button("Flag", action: { self.obj2.value2.toggle() })
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct ObservableOuterView: View {

    private var iVar1: Bool = false
    @Environment(TestObservableObject1.self) var obj1
    private var iVar2: Int8 = 0
    @Environment(TestObservableObject2.self) var obj2
    var didAppear: ((Self) -> Void)?
    let inspection = Inspection<Self>()

    var body: some View {
        ObservableInnerView()
            .modifier(ObservableViewModifier())
            .onAppear { self.didAppear?(self) }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct ObservableOptionalView: View {

    @Environment(TestObservableObject1.self) private var obj1: TestObservableObject1?

    var body: some View {
        Text(obj1?.value1 ?? "none")
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct ObservableEnvironmentValueView: View {

    @Environment(\.testObservableObject1) private var keyed
    @Environment(TestObservableObject1.self) private var obj1

    var body: some View {
        Text(keyed.value1 + "_" + obj1.value1)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct ObservableViewModifier: ViewModifier {
    private var iVar1: Bool = false
    @Environment(TestObservableObject2.self) var obj2
    @Environment(TestObservableObject1.self) var obj1
    private var iVar2: Int8 = 0

    func body(content: Self.Content) -> some View {
        VStack {
            Text(obj1.value1 + "+\(obj2.value2)")
            content
        }
    }
}
