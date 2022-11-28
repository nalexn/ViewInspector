import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Common Composed Gesture Ended Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class CommonComposedGestureEndedTests<U: Gesture & InspectableProtocol> {

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

    typealias ComposedGestureEnded<T> =
        (_EndedGesture<MagnificationGesture>,
         _EndedGesture<RotationGesture>) -> T

    func callEndedTest<T: Gesture & InspectableProtocol>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureEnded<T>) throws {
        let exp = XCTestExpectation(description: "ended")
        let magnificationGesture = self.magnificationGesture
            .onEnded { value in
                XCTAssertEqual(value, self.magnificationValue)
                exp.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .onEnded { value in
                XCTAssertEqual(value, self.rotationValue)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.callOnEnded(value: magnificationValue)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.callOnEnded(value: rotationValue)
        }
        testCase.wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureEndedNotFirst<T> =
        (_EndedGesture<_ChangedGesture<MagnificationGesture>>,
         _EndedGesture<_ChangedGesture<RotationGesture>>) -> T

    func callEndedNotFirstTest<T: Gesture & InspectableProtocol>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureEndedNotFirst<T>) throws {
        let exp = XCTestExpectation(description: "ended")
        let magnificationGesture = self.magnificationGesture
            .onChanged { value in }
            .onEnded { value in
                XCTAssertEqual(value, self.magnificationValue)
                exp.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .onChanged { value in }
            .onEnded { value in
                XCTAssertEqual(value, self.rotationValue)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.callOnEnded(value: magnificationValue)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.callOnEnded(value: rotationValue)
        }
        testCase.wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureEndedMultiple<T> =
        (_EndedGesture<_EndedGesture<MagnificationGesture>>,
         _EndedGesture<_EndedGesture<RotationGesture>>) -> T

    func callEndedMultipleTest<T: Gesture & InspectableProtocol>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: ComposedGestureEndedMultiple<T>) throws {
        let exp1 = XCTestExpectation(description: "ended1")
        let exp2 = XCTestExpectation(description: "ended2")
        let magnificationGesture = self.magnificationGesture
            .onEnded { value in
                XCTAssertEqual(value, self.magnificationValue)
                exp1.fulfill()
            }
            .onEnded { value in
                XCTAssertEqual(value, self.magnificationValue)
                exp2.fulfill()
            }
        let rotationGesture = self.rotationGesture
            .onEnded { value in
                XCTAssertEqual(value, self.rotationValue)
                exp1.fulfill()
            }
            .onEnded { value in
                XCTAssertEqual(value, self.rotationValue)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.callOnEnded(value: magnificationValue)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.callOnEnded(value: rotationValue)
        }
        testCase.wait(for: [exp1, exp2], timeout: 0.1)
    }

    func callEndedFailureTest<T: Gesture & InspectableProtocol>(
        _ order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath, line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws {
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect().emptyView().gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertThrows(
                try gesture2.callOnEnded(value: magnificationValue),
                "MagnificationGesture does not have 'onEnded' callback",
                file: file, line: line)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertThrows(
                try gesture2.callOnEnded(value: rotationValue),
                "RotationGesture does not have 'onEnded' callback",
                file: file, line: line)
        }
    }
}
