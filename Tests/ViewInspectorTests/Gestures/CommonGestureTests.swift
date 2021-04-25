import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Common Gesture Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CommonGestureTests<T: Gesture & Inspectable> {
    
    @GestureState var gestureState = CGSize.zero
    
    let testCase: XCTestCase
    let gesture: T
    let value: T.Value
    let assertValue: (T.Value, StaticString, UInt) -> Void
    
    init(testCase: XCTestCase, gesture: T, value: T.Value, assert: @escaping (T.Value, StaticString, UInt) -> Void) {
        self.testCase = testCase
        self.gesture = gesture
        self.value = value
        self.assertValue = assert
    }

    func maskTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let sut = EmptyView().gesture(gesture, including: .subviews)
        let mask = try sut.inspect().emptyView().gesture(T.self).gestureMask()
        XCTAssertEqual(mask, .subviews, file: file, line: line)
    }

    func propertiesWithUpdatingModifierTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let modifiedGesture = gesture
            .updating($gestureState) { value, state, transaction in }
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(T.self).actualGesture() as T, file: file, line: line)
    }

    func propertiesWithOnChangedModifierTest(file: StaticString = #filePath, line: UInt = #line) throws
        where T.Value: Equatable {
        let modifiedGesture = gesture
            .onChanged { value in }
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(T.self).actualGesture() as T, file: file, line: line)
    }

    func propertiesWithOnEndedModifierTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let modifiedGesture = gesture
            .onEnded { value in }
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(T.self).actualGesture() as T, file: file, line: line)
    }

    #if os(macOS)
    func propertiesWithModifiersTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let modifiedGesture = gesture
            .modifiers(.shift)
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(T.self).actualGesture() as T, file: file, line: line)
    }
    #endif

    func propertiesFailureTest(_ expectedGesture: String,
                               file: StaticString = #filePath, line: UInt = #line) throws {
        let sut = EmptyView()
        XCTAssertThrows(
            try sut.inspect().emptyView().gesture(T.self).actualGesture() as T,
            "EmptyView does not have 'gesture(\(expectedGesture).self)' modifier",
            file: file, line: line)
    }

    func callUpdatingTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let exp = XCTestExpectation(description: "updating")
        let modifiedGesture = gesture
            .updating($gestureState) { value, state, transaction in
                self.assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        var state = CGSize.zero
        var transaction = Transaction()
        try sut.inspect().emptyView().gesture(T.self)
            .gestureCallUpdating(value: value, state: &state, transaction: &transaction)
        testCase.wait(for: [exp], timeout: 0.1)
    }

    func callUpdatingNotFirstTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let exp = XCTestExpectation(description: "updating")
        let modifiedGesture = gesture
            .onEnded { value in }
            .updating($gestureState) { value, state, transaction in
                self.assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        var state = CGSize.zero
        var transaction = Transaction()
        try sut.inspect().emptyView().gesture(T.self)
            .gestureCallUpdating(value: value, state: &state, transaction: &transaction)
        testCase.wait(for: [exp], timeout: 0.1)
    }

    func callUpdatingMultipleTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let exp1 = XCTestExpectation(description: "updating1")
        let exp2 = XCTestExpectation(description: "updating2")
        let modifiedGesture = gesture
            .updating($gestureState) { value, state, transaction in
                self.assertValue(value, file, line)
                exp1.fulfill()
            }
            .updating($gestureState) { value, state, transaction in
                self.assertValue(value, file, line)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        var state = CGSize.zero
        var transaction = Transaction()
        try sut.inspect().emptyView().gesture(T.self)
            .gestureCallUpdating(value: value, state: &state, transaction: &transaction)
        testCase.wait(for: [exp1, exp2], timeout: 0.1)
    }

    func callUpdatingFailureTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let sut = EmptyView().gesture(gesture)
        var state = CGSize.zero
        var transaction = Transaction()
        XCTAssertThrows(
            try sut.inspect().gesture(T.self)
                .gestureCallUpdating(value: value, state: &state, transaction: &transaction),
            "Callback GestureStateGesture for parent AddGestureModifier<\(String(describing: T.self))> is absent",
            file: file, line: line
        )
    }

    func callOnChangedTest(file: StaticString = #filePath, line: UInt = #line) throws
        where T.Value: Equatable {
        let exp = XCTestExpectation(description: "onChanged")
        let modifiedGesture = gesture
            .onChanged { value in
                self.assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        try sut.inspect().emptyView().gesture(T.self).gestureCallChanged(value: value)
        testCase.wait(for: [exp], timeout: 0.1)
    }

    func callOnChangedNotFirstTest(file: StaticString = #filePath, line: UInt = #line) throws
        where T.Value: Equatable {
        let exp = XCTestExpectation(description: "onChanged")
        let modifiedGesture = gesture
            .onEnded { value in }
            .onChanged { value in
                self.assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        try sut.inspect().emptyView().gesture(T.self).gestureCallChanged(value: value)
        testCase.wait(for: [exp], timeout: 0.1)
    }

    func callOnChangedMultipleTest(file: StaticString = #filePath, line: UInt = #line) throws
        where T.Value: Equatable {
        let exp1 = XCTestExpectation(description: "onChanged1")
        let exp2 = XCTestExpectation(description: "onChanged2")
        let modifiedGesture = gesture
            .onChanged { value in
                self.assertValue(value, file, line)
                exp1.fulfill()
            }
            .onChanged { value in
                self.assertValue(value, file, line)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        try sut.inspect().emptyView().gesture(T.self).gestureCallChanged(value: value)
        testCase.wait(for: [exp1, exp2], timeout: 0.1)
    }

    func callOnChangedFailureTest(file: StaticString = #filePath, line: UInt = #line) throws
        where T.Value: Equatable {
        let sut = EmptyView().gesture(gesture)
        XCTAssertThrows(
            try sut.inspect().gesture(T.self).gestureCallChanged(value: value),
            "Callback _ChangedGesture for parent AddGestureModifier<\(String(describing: T.self))> is absent",
            file: file, line: line)
    }
    
    func callOnEndedTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let exp = XCTestExpectation(description: "onEnded")
        let modifiedGesture = gesture
            .onEnded { value in
                self.assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        
        try sut.inspect().emptyView().gesture(T.self).gestureCallEnded(value: value)
        testCase.wait(for: [exp], timeout: 0.1)
    }

    func callOnEndedNotFirstTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let exp = XCTestExpectation(description: "onEnded")
        let modifiedGesture = gesture
            .updating($gestureState) { value, state, transaction in }
            .onEnded { value in
                self.assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        
        try sut.inspect().emptyView().gesture(T.self).gestureCallEnded(value: value)
        testCase.wait(for: [exp], timeout: 0.1)
    }

    func callOnEndedMultipleTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let exp1 = XCTestExpectation(description: "onEnded1")
        let exp2 = XCTestExpectation(description: "onEnded2")
        let modifiedGesture = gesture
            .onEnded { value in
                self.assertValue(value, file, line)
                exp1.fulfill()
            }
            .onEnded { value in
                self.assertValue(value, file, line)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        
        try sut.inspect().emptyView().gesture(T.self).gestureCallEnded(value: value)
        testCase.wait(for: [exp1, exp2], timeout: 0.1)
    }

    func callOnEndedFailureTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let sut = EmptyView().gesture(gesture)
        XCTAssertThrows(
            try sut.inspect().gesture(T.self).gestureCallEnded(value: value),
            "Callback _EndedGesture for parent AddGestureModifier<\(String(describing: T.self))> is absent",
            file: file, line: line)
    }

    #if os(macOS)
    func modifiersTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let modifiedGesture = gesture
            .modifiers(.shift)
        let sut = EmptyView().gesture(modifiedGesture)
        let modifiers = try sut.inspect().emptyView().gesture(T.self).gestureModifiers()
        XCTAssertEqual(modifiers, .shift, file: file, line: line)
    }

    func modifiersNotFirstTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let modifiedGesture = gesture
            .onEnded { value in }
            .modifiers(.shift)
        let sut = EmptyView().gesture(modifiedGesture)
        let modifiers = try sut.inspect().emptyView().gesture(T.self).gestureModifiers()
        XCTAssertEqual(modifiers, .shift, file: file, line: line)
    }

    func modifiersMultipleTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let modifiedGesture = gesture
            .modifiers(.shift)
            .modifiers(.control)
        let sut = EmptyView().gesture(modifiedGesture)
        let modifiers = try sut.inspect().emptyView().gesture(T.self).gestureModifiers()
        XCTAssertEqual(modifiers, [.shift, .control], file: file, line: line)
    }

    func modifiersNoneTest(file: StaticString = #filePath, line: UInt = #line) throws {
        let sut = EmptyView().gesture(gesture)
        let modifiers = try sut.inspect().emptyView().gesture(T.self).gestureModifiers()
        XCTAssertEqual(modifiers, [], file: file, line: line)
    }
    #endif
}
