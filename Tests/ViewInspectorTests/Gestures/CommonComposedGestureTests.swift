import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Common Composed Gesture Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class CommonComposedGestureTests<U: Gesture & Inspectable> {

    let type: U.Type

    let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
    let magnificationValue = MagnificationGesture.Value(10)

    let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
    let rotationValue = RotationGesture.Value(angle: Angle(degrees: 90))

    var state = CGSize.zero
    var transaction = Transaction()

    init(type: U.Type) {
        self.type = type
    }

    func gestureTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws {
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let composedGesture = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let firstGesture = try composedGesture.first(MagnificationGesture.self).actualGesture()
            XCTAssertEqual(firstGesture.minimumScaleDelta, 1.5, file: file, line: line)
        case .second:
            let secondGesture = try composedGesture.second(RotationGesture.self).actualGesture()
            XCTAssertEqual(secondGesture.minimumAngleDelta, Angle(degrees: 5), file: file, line: line)
        }
    }

    func gesturePathTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws {
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let composedGesture = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let path = try composedGesture.first(MagnificationGesture.self).pathToRoot
            XCTAssertEqual(path, "emptyView().gesture(\(T.self).self).first(MagnificationGesture.self)")
        case .second:
            let path = try composedGesture.second(RotationGesture.self).pathToRoot
            XCTAssertEqual(path, "emptyView().gesture(\(T.self).self).second(RotationGesture.self)")
        }
    }
    
    func gestureFailureTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws {
        guard #available(tvOS 16.0, *) else { throw XCTSkip() }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            XCTAssertThrows(
                try gesture.first(TapGesture.self),
                "Type mismatch: MagnificationGesture is not TapGesture",
                file: file, line: line)
        case .second:
            XCTAssertThrows(
                try gesture.second(TapGesture.self),
                "Type mismatch: RotationGesture is not TapGesture",
                file: file, line: line)
        }
    }
    
    #if os(macOS)
    typealias ComposedGestureModifiers<T> =
        (_ModifiersGesture<MagnificationGesture>,
         _ModifiersGesture<RotationGesture>) -> T

    func modifiersTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureModifiers<T>) throws {
        let magnificationGesture = self.magnificationGesture.modifiers(.shift)
        let rotationGesture = self.rotationGesture.modifiers(.shift)
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), .shift)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), .shift)
        }
    }

    typealias ComposedGestureModifiersNotFirst<T> =
        (_ModifiersGesture<_EndedGesture<MagnificationGesture>>,
         _ModifiersGesture<_EndedGesture<RotationGesture>>) -> T

    func modifiersNotFirstTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureModifiersNotFirst<T>) throws {
        let magnificationGesture = self.magnificationGesture
            .onEnded { value in }
            .modifiers(.shift)
        let rotationGesture = self.rotationGesture
            .onEnded { value in }
            .modifiers(.shift)
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), .shift)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), .shift)
        }
    }

    typealias ComposedGestureModifiersMultiple<T> =
        (_ModifiersGesture<_ModifiersGesture<MagnificationGesture>>,
         _ModifiersGesture<_ModifiersGesture<RotationGesture>>) -> T

    func modifiersMultipleTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureModifiersMultiple<T>) throws {
        let magnificationGesture = self.magnificationGesture
            .modifiers(.shift)
            .modifiers(.control)
        let rotationGesture = self.rotationGesture
            .modifiers(.shift)
            .modifiers(.control)
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), [.shift, .control])
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), [.shift, .control])
        }
    }

    func modifiersFailureTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws {
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), [])
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), [])
        }
    }
    #endif
}
