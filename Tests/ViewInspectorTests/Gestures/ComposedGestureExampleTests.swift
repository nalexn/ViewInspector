import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

@available(iOS 13.0, macOS 11, *)
@available(tvOS, unavailable)
final class ComposedGestureExampleTests: XCTestCase {
    
    func testComposedGestureFirst() throws {
        let sut = TestGestureView10()
        let exp1 = sut.inspection.inspect { view in
            let simultaneousGesture = try view
                .vStack()
                .image(0)
                .gesture(SimultaneousGesture<MagnificationGesture, RotationGesture>.self)
            let magnificationGesture = try simultaneousGesture
                .first(MagnificationGesture.self)
            let value = MagnificationGesture.Value(2.0)
            try magnificationGesture.gestureCallChanged(value: value)
            sut.publisher.send()
        }
        
        let exp2 = sut.inspection.inspect { view in
            XCTAssertEqual(try view.actualView().scale, 2.0)
        }

        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 0.1)
    }

    func testComposedGestureSecond() throws {
        let sut = TestGestureView10()
        let exp1 = sut.inspection.inspect { view in
            let simultaneousGesture = try view
                .vStack()
                .image(0)
                .gesture(SimultaneousGesture<MagnificationGesture, RotationGesture>.self)
            let rotationGesture = try simultaneousGesture
                .second(RotationGesture.self)
            let value = RotationGesture.Value(angle: Angle(degrees: 5))
            try rotationGesture.gestureCallChanged(value: value)
            sut.publisher.send()
        }
        
        let exp2 = sut.inspection.inspect { view in
            XCTAssertEqual(try view.actualView().angle, Angle(degrees: 5))
        }

        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func testComposedGestureAltFirst() throws {
        let sut = TestGestureView11()
        let exp1 = sut.inspection.inspect { view in
            let simultaneousGesture = try view
                .vStack()
                .image(0)
                .gesture(SimultaneousGesture<MagnificationGesture, RotationGesture>.self)
            let magnificationGesture = try simultaneousGesture
                .first(MagnificationGesture.self)
            let value = MagnificationGesture.Value(2.0)
            try magnificationGesture.gestureCallChanged(value: value)
            sut.publisher.send()
        }
        
        let exp2 = sut.inspection.inspect { view in
            XCTAssertEqual(try view.actualView().scale, 2.0)
        }

        ViewHosting.host(view: sut)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func testNotAComposedGestureError() throws {
        let sut = TestGestureView1()
        let rectangle = try sut.inspect().shape(0)
        let tapGesture = try rectangle.gesture(TapGesture.self)
        XCTAssertThrows(try tapGesture.first(MagnificationGesture.self),
            "Type mismatch: TapGesture is not ExclusiveGesture, SequenceGesture, or SimultaneousGesture")
    }
    
    func testComposedGestureComplex() throws {
        let sut = TestGestureView12()
        let exp = sut.inspection.inspect { view in
            let outerSimultaneousGesture = try view
                .vStack()
                .image(0)
                .gesture(
                    SimultaneousGesture<
                        SimultaneousGesture<MagnificationGesture, RotationGesture>,
                        DragGesture>.self
                )
            let innerSimultaneousGesture = try outerSimultaneousGesture
                .first(SimultaneousGesture<MagnificationGesture, RotationGesture>.self)
            XCTAssertNoThrow(try innerSimultaneousGesture.first(MagnificationGesture.self))
        }

        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
}

@available(iOS 13.0, macOS 11, *)
@available(tvOS, unavailable)
struct TestGestureView10: View & Inspectable {
    @State var scale: CGFloat = 1.0
    @State var angle = Angle(degrees: 0)
    
    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in self.scale = value.magnitude }
        
        let rotationGesture = RotationGesture()
            .onChanged { value in self.angle = value }
        
        let gesture = SimultaneousGesture(magnificationGesture, rotationGesture)
        
        VStack {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 200))
                .foregroundColor(Color.red)
                .gesture(gesture)
                .rotationEffect(angle)
                .scaleEffect(scale)
                .animation(.easeInOut)
       }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { }
    }
}

@available(iOS 13.0, macOS 11, *)
@available(tvOS, unavailable)
struct TestGestureView11: View & Inspectable {
    @State var scale: CGFloat = 1.0
    @State var angle = Angle(degrees: 0)
    
    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()

    var body: some View {
        let rotationGesture = RotationGesture()
            .onChanged { value in self.angle = value }
        
        let gesture = MagnificationGesture()
            .onChanged { value in self.scale = value.magnitude }
            .simultaneously(with: rotationGesture)
                
        VStack {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 200))
                .foregroundColor(Color.red)
                .gesture(gesture)
                .rotationEffect(angle)
                .scaleEffect(scale)
                .animation(.easeInOut)
       }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { }
    }
}

@available(iOS 13.0, macOS 11, *)
@available(tvOS, unavailable)
struct TestGestureView12: View & Inspectable {
    
    internal let inspection = Inspection<Self>()
    internal let publisher = PassthroughSubject<Void, Never>()
    
    var body: some View {
        let rotationGesture = RotationGesture()
        let magnificationGesture = MagnificationGesture()
        let dragGesture = DragGesture()
        
        let gesture = SimultaneousGesture(
            SimultaneousGesture(magnificationGesture, rotationGesture),
            dragGesture)
        
        VStack {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 200))
                .foregroundColor(Color.red)
                .gesture(gesture)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .onReceive(publisher) { }
    }
}
