import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class GestureExampleTests: XCTestCase {

    func testGestureModifier() throws {
        guard #available(iOS 14.0, tvOS 16.0, *) else { throw XCTSkip() }
        let sut = TestGestureView1()
        let rectangle = try sut.inspect().shape(0)
        XCTAssertNoThrow(try rectangle.gesture(TapGesture.self))
    }

    func testHighPriorityGestureModifier() throws {
        guard #available(iOS 14.0, tvOS 16.0, *) else { throw XCTSkip() }
        let sut = TestGestureView2()
        let rectangle = try sut.inspect().shape(0)
        XCTAssertNoThrow(try rectangle.highPriorityGesture(TapGesture.self))
    }

    func testSimultaneousGestureModifier() throws {
        guard #available(iOS 14.0, tvOS 16.0, *) else { throw XCTSkip() }
        let sut = TestGestureView3()
        let rectangle = try sut.inspect().shape(0)
        XCTAssertNoThrow(try rectangle.simultaneousGesture(TapGesture.self))
    }

    func testGestureMask() throws {
        guard #available(iOS 14.0, tvOS 16.0, *) else { throw XCTSkip() }
        let sut = TestGestureView9()
        let gesture = try sut.inspect().shape(0).gesture(TapGesture.self)
        XCTAssertEqual(try gesture.gestureMask(), .gesture)
    }

    func testGestureProperties() throws {
        guard #available(iOS 14.0, *) else { throw XCTSkip() }
        let sut = TestGestureView4()
        let rectangle = try sut.inspect().shape(0)
        let gesture = try rectangle.gesture(DragGesture.self).actualGesture()
        XCTAssertEqual(gesture.minimumDistance, 20)
        XCTAssertEqual(gesture.coordinateSpace, .global)
    }
    
    func testTestGestureUpdating() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = TestGestureView5()
        let exp1 = sut.inspection.inspect { view in
            XCTAssertEqual(try view.actualView().isDetectingLongPress, false)
            XCTAssertEqual(try view.shape(0).fillShapeStyle(Color.self), Color.green)
            let gesture = try view.shape(0).gesture(LongPressGesture.self)
            let value = LongPressGesture.Value(finished: true)
            var state: Bool = false
            var transaction = Transaction()
            try gesture.callUpdating(value: value, state: &state, transaction: &transaction)
            sut.publisher.send()
        }

        let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
            XCTAssertEqual(try view.shape(0).fillShapeStyle(Color.self), Color.green)
        }

        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 0.1)
    }

    func testTestGestureChanged() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = TestGestureView6()
        let exp1 = sut.inspection.inspect { view in
            XCTAssertEqual(try view.actualView().totalNumberOfTaps, 0)
            XCTAssertEqual(try view.vStack().text(0).string(), "0")
            let gesture = try view.vStack().shape(1).gesture(LongPressGesture.self)
            let value = LongPressGesture.Value(finished: true)
            try gesture.callOnChanged(value: value)
            sut.publisher.send()
        }

        let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
            XCTAssertEqual(try view.actualView().totalNumberOfTaps, 1)
            XCTAssertEqual(try view.vStack().text(0).string(), "1")
        }

        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func testTestGestureEnded() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = TestGestureView7()
        let exp1 = sut.inspection.inspect { view in
            XCTAssertEqual(try view.actualView().doneCounting, false)
            let circle = try view.vStack().shape(1)
            XCTAssertEqual(try circle.fillShapeStyle(Color.self), Color.green)
            let gesture = try circle.gesture(LongPressGesture.self)
            let value = LongPressGesture.Value(finished: true)
            try gesture.callOnEnded(value: value)
            sut.publisher.send()
        }

        let exp2 = sut.inspection.inspect(onReceive: sut.publisher) { view in
            XCTAssertEqual(try view.actualView().doneCounting, true)
            XCTAssertEqual(try view.vStack().shape(1).fillShapeStyle(Color.self), Color.red)
        }

        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    #if os(macOS)
    func testGestureModifiers() throws {
        let sut = TestGestureView8()
        let gesture = try sut.inspect().shape(0).gesture(TapGesture.self)
        XCTAssertEqual(try gesture.gestureModifiers(), [.shift, .control])
    }
    #endif
}

@available(iOS 13.0, macOS 10.15, tvOS 16.0, *)
struct TestGestureView1: View & InspectableProtocol {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .gesture(gesture)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 16.0, *)
struct TestGestureView2: View & InspectableProtocol {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .highPriorityGesture(gesture)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 16.0, *)
struct TestGestureView3: View & InspectableProtocol {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .simultaneousGesture(gesture)
    }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
struct TestGestureView4: View & InspectableProtocol {
    @State var isDragging = false
    
    var body: some View {
        let drag = DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onChanged { _ in self.isDragging = true }
            .onEnded { _ in self.isDragging = false }
                    
        return Rectangle()
            .fill(self.isDragging ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .gesture(drag)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 14.0, *)
struct TestGestureView5: View & InspectableProtocol {
    @GestureState var isDetectingLongPress = false

    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }

        return Circle()
            .fill(isDetectingLongPress ? Color.yellow : Color.green)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(press)
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
            .onReceive(publisher) { }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 14.0, *)
struct TestGestureView6: View & InspectableProtocol {
    @GestureState var isDetectingLongPress = false
    @State var totalNumberOfTaps = 0

    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var press: some Gesture {
        LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }
            .onChanged { _ in
                totalNumberOfTaps += 1
            }

    }

    var body: some View {
        VStack {
            Text("\(totalNumberOfTaps)")
                .font(.largeTitle)

            Circle()
                .fill(isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                .gesture(press)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 14.0, *)
struct TestGestureView7: View & InspectableProtocol {
    @GestureState var isDetectingLongPress = false
    @State var totalNumberOfTaps = 0
    @State var doneCounting = false
    
    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }.onChanged { _ in
                self.totalNumberOfTaps += 1
            }
            .onEnded { _ in
                self.doneCounting = true
            }
        
        return VStack {
            Text("\(totalNumberOfTaps)")
                .font(.largeTitle)
            
            Circle()
                .fill(doneCounting ? Color.red : isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                .gesture(doneCounting ? nil : press)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { }
    }
}

#if os(macOS)
@available(macOS 10.15, *)
struct TestGestureView8: View & InspectableProtocol {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
            .modifiers(.shift)
            .modifiers(.control)
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .gesture(gesture)
    }
}
#endif

@available(iOS 14.0, macOS 10.15, tvOS 16.0, *)
struct TestGestureView9: View & InspectableProtocol {
    @State var tapped = false
        
    var body: some View {
        let gesture = TapGesture()
            .onEnded { _ in self.tapped.toggle() }
        
        return Rectangle()
            .fill(self.tapped ? Color.blue : Color.red)
            .frame(width: 10, height: 10)
            .gesture(gesture, including: .gesture)
    }
}
