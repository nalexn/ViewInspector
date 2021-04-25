import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Common Composed Gesture Updating Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CommonComposedGestureUpdatingTests<U: Gesture & Inspectable> {

    @GestureState var gestureState = CGSize.zero
    
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

    typealias ComposedGestureUpdating<T> =
        (GestureStateGesture<MagnificationGesture, CGSize>,
         GestureStateGesture<RotationGesture, CGSize>) -> T

    func callUpdatingTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureUpdating<T>) throws {
        let exp = XCTestExpectation(description: "updating")
        let magnificationGesture = self.magnificationGesture
            .updating($gestureState) { value, state, transaction in
                XCTAssertEqual(value, self.magnificationValue)
                exp.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .updating($gestureState) { value, state, transaction in
                XCTAssertEqual(value, self.rotationValue)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallUpdating(value: magnificationValue, state: &state, transaction: &transaction)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallUpdating(value: rotationValue, state: &state, transaction: &transaction)
        }
        testCase.wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureUpdatingNotFirst<T> =
        (GestureStateGesture<_EndedGesture<MagnificationGesture>, CGSize>,
         GestureStateGesture<_EndedGesture<RotationGesture>, CGSize>) -> T

    func callUpdatingNotFirstTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureUpdatingNotFirst<T>) throws {
        let exp = XCTestExpectation(description: "updating")
        let magnificationGesture = self.magnificationGesture
            .onEnded { value in }
            .updating($gestureState) { value, state, transaction in
                XCTAssertEqual(value, self.magnificationValue)
                exp.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .onEnded { value in }
            .updating($gestureState) { value, state, transaction in
                XCTAssertEqual(value, self.rotationValue)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallUpdating(value: magnificationValue, state: &state, transaction: &transaction)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallUpdating(value: rotationValue, state: &state, transaction: &transaction)
        }
        testCase.wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureUpdatingMultiple<T> =
        (GestureStateGesture<GestureStateGesture<MagnificationGesture, CGSize>, CGSize>,
         GestureStateGesture<GestureStateGesture<RotationGesture, CGSize>, CGSize>) -> T

    func callUpdatingMultipleTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureUpdatingMultiple<T>) throws {
        let exp1 = XCTestExpectation(description: "updating1")
        let exp2 = XCTestExpectation(description: "updating2")
        let magnificationGesture = self.magnificationGesture
            .updating($gestureState) { value, state, transaction in
                XCTAssertEqual(value, self.magnificationValue)
                exp1.fulfill()
            }
            .updating($gestureState) { value, state, transaction in
                XCTAssertEqual(value, self.magnificationValue)
                exp2.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .updating($gestureState) { value, state, transaction in
                XCTAssertEqual(value, self.rotationValue)
                exp1.fulfill()
            }
            .updating($gestureState) { value, state, transaction in
                XCTAssertEqual(value, self.rotationValue)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallUpdating(value: magnificationValue, state: &state, transaction: &transaction)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallUpdating(value: rotationValue, state: &state, transaction: &transaction)
        }
        testCase.wait(for: [exp1, exp2], timeout: 0.1)
    }

    func callUpdatingFailureTest<T: Gesture & Inspectable>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws {
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertThrows(
                try gesture2.gestureCallUpdating(value: magnificationValue, state: &state, transaction: &transaction),
                "Callback GestureStateGesture for parent MagnificationGesture is absent",
                file: file, line: line
            )
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertThrows(
                try gesture2.gestureCallUpdating(value: rotationValue, state: &state, transaction: &transaction),
                "Callback GestureStateGesture for parent RotationGesture is absent",
                file: file, line: line)
        }
    }
}
