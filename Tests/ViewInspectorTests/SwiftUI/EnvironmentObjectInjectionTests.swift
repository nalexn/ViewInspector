import XCTest
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
class EnvironmentObjectInjectionTests: XCTestCase {
    
    func testEnvironmentObjectMemoryLayout() throws {
        typealias RealType = EnvironmentObject<TestEnvObject1>
        XCTAssertEqual(MemoryLayout<RealType>.size, EnvObject.structSize)
        var sut = RealType.init()
        withUnsafeMutableBytes(of: &sut, { bytes in
            let rawPointer = bytes.baseAddress! + EnvObject.seedOffset
            rawPointer.assumingMemoryBound(to: Int.self).pointee = 42
        })
        let seed2 = try Inspector.attribute(label: "_seed", value: sut, type: Int.self)
        XCTAssertEqual(seed2, 42)
    }
    
    func testEnvironmentObjectForgery() throws {
        let obj = TestEnvObject1()
        let forgery = EnvObject.Forgery(object: obj)
        let sut = unsafeBitCast(forgery, to: EnvironmentObject<TestEnvObject1>.self)
        let seed = try Inspector.attribute(label: "_seed", value: sut, type: Int.self)
        XCTAssertEqual(seed, 0)
        let store = try Inspector.attribute(label: "_store", value: sut, type: TestEnvObject1?.self)
        XCTAssertEqual(store?.value1, obj.value1)
    }
    
    func testDirectEnvironmentObjectInjection() throws {
        let obj1 = TestEnvObject1()
        let obj2 = TestEnvObject2()
        var sut = EnvironmentObjectInnerView()
        sut = EnvironmentInjection.inject(environmentObject: obj1, into: sut)
        sut = EnvironmentInjection.inject(environmentObject: obj2, into: sut)
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "env_true")
    }
    
    func testEnvironmentObjectInjectionDuringSyncInspection() throws {
        let obj1 = TestEnvObject1()
        let obj2 = TestEnvObject2()
        let sut = EnvironmentObjectOuterView()
            .environmentObject(obj1)
            .environmentObject(obj2)
        XCTAssertNoThrow(try sut.inspect().find(text: "env_true"))
        try sut.inspect().find(button: "Flag").tap()
        XCTAssertNoThrow(try sut.inspect().find(text: "env_false"))
        XCTAssertEqual(try sut.inspect().findAll(ViewType.Text.self).first?.string(), "env_false")
    }
    
    func testEnvironmentObjectInjectionOnDidAppearInspection() throws {
        let obj1 = TestEnvObject1()
        let obj2 = TestEnvObject2()
        var sut = EnvironmentObjectOuterView()
        let exp = sut.on(\.didAppear) { view in
            XCTAssertNoThrow(try view.find(text: "env_true"))
            try view.find(button: "Flag").tap()
            XCTAssertNoThrow(try view.find(text: "env_false"))
        }
        ViewHosting.host(view: sut.environmentObject(obj1).environmentObject(obj2))
        wait(for: [exp], timeout: 0.5)
    }
    
    func testEnvironmentObjectInjectionDuringAsyncInspection() throws {
        let obj1 = TestEnvObject1()
        let obj2 = TestEnvObject2()
        let sut = EnvironmentObjectOuterView()
        let exp1 = sut.inspection.inspect { view in
            XCTAssertNoThrow(try view.find(text: "env_true"))
            try view.find(button: "Flag").tap()
            XCTAssertNoThrow(try view.find(text: "env_false"))
        }
        let exp2 = sut.inspection.inspect(after: 0.1) { view in
            XCTAssertNoThrow(try view.find(text: "env_false"))
            try view.find(button: "Flag").tap()
            XCTAssertNoThrow(try view.find(text: "env_true"))
        }
        ViewHosting.host(view: sut.environmentObject(obj1).environmentObject(obj2))
        wait(for: [exp1, exp2], timeout: 0.5)
    }
    
    func testMissingEnvironmentObjectErrorForView() throws {
        var sut = EnvironmentObjectInnerView()
        XCTAssertThrows(try sut.inspect().find(ViewType.Text.self),
            """
            Search did not find a match. Possible blockers: EnvironmentObjectInnerView is \
            missing EnvironmentObjects: [\"obj2: TestEnvObject2\", \"obj1: TestEnvObject1\"]
            """)
        sut = EnvironmentInjection.inject(environmentObject: TestEnvObject1(), into: sut)
        XCTAssertThrows(try sut.inspect().find(ViewType.Text.self),
            """
            Search did not find a match. Possible blockers: EnvironmentObjectInnerView is \
            missing EnvironmentObjects: [\"obj2: TestEnvObject2\"]
            """)
    }
}

// MARK: -

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private class TestEnvObject1: ObservableObject {
    @Published var value1 = "env"
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private class TestEnvObject2: ObservableObject {
    @Published var value2 = true
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct EnvironmentObjectInnerView: View, Inspectable {
    
    private var iVar1: Int8 = 0
    private var iVar2: Int16 = 0
    @EnvironmentObject var obj2: TestEnvObject2
    private var iVar3: Int32 = 0
    @EnvironmentObject var obj1: TestEnvObject1
    @State var flag: Bool = false
    private var iVar4: Bool = false
    
    var body: some View {
        VStack {
            Text(obj1.value1 + "_\(obj2.value2)")
            Button("Flag", action: { self.obj2.value2.toggle() })
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct EnvironmentObjectOuterView: View, Inspectable {
    
    private var iVar1: Bool = false
    @EnvironmentObject var obj1: TestEnvObject1
    private var iVar2: Int8 = 0
    @EnvironmentObject var obj2: TestEnvObject2
    var didAppear: ((Self) -> Void)?
    let inspection = Inspection<Self>()
    
    var body: some View {
        EnvironmentObjectInnerView()
            .modifier(EnvironmentObjectViewModifier())
            .onAppear { self.didAppear?(self) }
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct EnvironmentObjectViewModifier: ViewModifier, Inspectable {
    private var iVar1: Bool = false
    @EnvironmentObject var obj2: TestEnvObject2
    @EnvironmentObject var obj1: TestEnvObject1
    private var iVar2: Int8 = 0
    
    func body(content: Self.Content) -> some View {
        VStack {
            Text(obj1.value1 + "+\(obj2.value2)")
            content
        }
    }
}
