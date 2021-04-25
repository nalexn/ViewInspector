import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Common Composed Gesture Changed Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class CommonComposedGestureChangedTests<U: Gesture & Inspectable> {

    let testCase: XCTestCase
    let type: U.Type

    let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
    let magnificationValue = MagnificationGesture.Value(10)

    let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
    let rotationValue = RotationGesture.Value(angle: Angle(degrees: 90))

    var state = CGSize.zero
    var transaction = Transaction()

    init(testCase: XCTestCase, type: U.Type) {
        self.testCase = testCase
        self.type = type
    }

    typealias ComposedGestureChanged<T> =
        (_ChangedGesture<MagnificationGesture>,
         _ChangedGesture<RotationGesture>) -> T

    func callChangedTest<T>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureChanged<T>) throws {
        let exp = XCTestExpectation(description: "changed")
        let magnificationGesture = self.magnificationGesture
            .onChanged { value in
                XCTAssertEqual(value, self.magnificationValue)
                exp.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .onChanged { value in
                XCTAssertEqual(value, self.rotationValue)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallChanged(value: magnificationValue)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallChanged(value: rotationValue)
        }
        testCase.wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureChangedNotFirst<T> =
        (_ChangedGesture<_EndedGesture<MagnificationGesture>>,
         _ChangedGesture<_EndedGesture<RotationGesture>>) -> T

    func callChangedNotFirstTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureChangedNotFirst<T>) throws {
        let exp = XCTestExpectation(description: "changed")
        let magnificationGesture = self.magnificationGesture
            .onEnded { value in }
            .onChanged { value in
                XCTAssertEqual(value, self.magnificationValue)
                exp.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .onEnded { value in }
            .onChanged { value in
                XCTAssertEqual(value, self.rotationValue)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallChanged(value: magnificationValue)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallChanged(value: rotationValue)
        }
        testCase.wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureChangedMultiple<T> =
        (_ChangedGesture<_ChangedGesture<MagnificationGesture>>,
         _ChangedGesture<_ChangedGesture<RotationGesture>>) -> T

    func callChangedMultipleTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureChangedMultiple<T>) throws {
        let exp1 = XCTestExpectation(description: "changed1")
        let exp2 = XCTestExpectation(description: "changed2")
        let magnificationGesture = self.magnificationGesture
            .onChanged { value in
                XCTAssertEqual(value, self.magnificationValue)
                exp1.fulfill()
            }
            .onChanged { value in
                XCTAssertEqual(value, self.magnificationValue)
                exp2.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .onChanged { value in
                XCTAssertEqual(value, self.rotationValue)
                exp1.fulfill()
            }
            .onChanged { value in
                XCTAssertEqual(value, self.rotationValue)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallChanged(value: magnificationValue)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallChanged(value: rotationValue)
        }
        testCase.wait(for: [exp1, exp2], timeout: 0.1)
    }

    func callChangedFailureTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws {
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertThrows(
                try gesture2.gestureCallChanged(value: magnificationValue),
                "MagnificationGesture does not have 'onChanged' callback",
                file: file, line: line)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertThrows(
                try gesture2.gestureCallChanged(value: rotationValue),
                "RotationGesture does not have 'onChanged' callback",
                file: file, line: line)
        }
    }
}
