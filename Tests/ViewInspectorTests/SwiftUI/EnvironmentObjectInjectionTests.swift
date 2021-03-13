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
        sut.inject(environmentObject: obj1)
        sut.inject(environmentObject: obj2)
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "env_true")
    }
    
    func testEnvironmentObjectInjectionDuringInspection() throws {
        let obj1 = TestEnvObject1()
        let obj2 = TestEnvObject2()
        let sut = EnvironmentObjectOuterView()
            .environmentObject(obj1)
            .environmentObject(obj2)
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "env_true")
        try sut.inspect().find(button: "Flag").tap()
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "env_false")
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
    
    var body: some View {
        EnvironmentObjectInnerView()
    }
}
