import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewEventsTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewEventsTests: XCTestCase {
    
    func testOnAppear() throws {
        let sut = EmptyView().onAppear { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnAppearInspection() throws {
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().onAppear {
            exp.fulfill()
        }.padding().onDisappear(perform: { })
        try sut.inspect().emptyView().callOnAppear()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnDisappear() throws {
        let sut = EmptyView().onDisappear { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDisappearInspection() throws {
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().onAppear(perform: { }).padding()
            .onDisappear {
                exp.fulfill()
            }.padding()
        try sut.inspect().emptyView().callOnDisappear()
        wait(for: [exp], timeout: 0.1)
    }

    func testOnChange() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let val = ""
        let sut = EmptyView().onChange(of: val) { value in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testOnChangeInspection() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let val = "initial"
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().onChange(of: val) { [val] value in
            XCTAssertEqual(val, "initial")
            XCTAssertEqual(value, "expected")
            exp.fulfill()
        }.padding()
        try sut.inspect().emptyView().callOnChange(newValue: "expected")
        wait(for: [exp], timeout: 0.1)
    }

    func testMultipleOnChangeModifiersSameTypeCallFirst() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        var val = "initial"
        let other = ""
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().onChange(of: val) { [val] value in
            XCTAssertEqual(val, "initial")
            XCTAssertEqual(value, "expected")
            exp.fulfill()
        }.onChange(of: other) { value in
            XCTFail("This should never have been called")
        }.padding()
        val = "expected"
        try sut.inspect().emptyView().callOnChange(newValue: val)
        wait(for: [exp], timeout: 0.1)
    }

    func testMultipleOnChangeModifiersSameTypeCallByIndex() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        var val = "initial"
        let other = ""
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().onChange(of: other) { value in
            XCTFail("This should never have been called")
        }.onChange(of: val) { [val] value in
            XCTAssertEqual(val, "initial")
            XCTAssertEqual(value, "expected")
            exp.fulfill()
        }.padding()
        val = "expected"
        try sut.inspect().emptyView().callOnChange(newValue: val, index: 1)
        XCTAssertThrows(try sut.inspect().emptyView().callOnChange(newValue: val, index: 2),
                        "EmptyView does not have 'onChange' modifier at index 2")
        wait(for: [exp], timeout: 0.1)
    }
    
    func testMultipleOnChangeModifiersDifferentTypes() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let exp1 = XCTestExpectation(description: "onChange1")
        let exp2 = XCTestExpectation(description: "onChange2")
        [exp1, exp2].forEach {
            $0.assertForOverFulfill = true
        }
        let sut = EmptyView().padding().onChange(of: "str") { value in
            exp1.fulfill()
        }.onChange(of: 1) { value in
            exp2.fulfill()
        }.padding()
        try sut.inspect().emptyView().callOnChange(newValue: "abc")
        try sut.inspect().emptyView().callOnChange(newValue: 5)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func testOnSubmit() throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
        else { throw XCTSkip() }
        let sut = EmptyView().onSubmit { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testOnSubmitInspection() throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
        else { throw XCTSkip() }
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: "")
        let sut = TextField("Title", text: binding).onSubmit { exp.fulfill() }
        try sut.inspect().callOnSubmit()
        wait(for: [exp], timeout: 0.1)
    }
}

// MARK: - ViewPublisherEventsTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewPublisherEventsTests: XCTestCase {
    
    func testOnReceive() throws {
        let publisher = Just<Void>(())
        let sut = EmptyView().onReceive(publisher) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
