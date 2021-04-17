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
        let exp = XCTestExpectation(description: "onAppear")
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
        let exp = XCTestExpectation(description: "onDisappear")
        let sut = EmptyView().onAppear(perform: { }).padding()
            .onDisappear {
                exp.fulfill()
            }.padding()
        try sut.inspect().emptyView().callOnDisappear()
        wait(for: [exp], timeout: 0.1)
    }

    @available(iOS 14.0, *)
    func testOnChange() throws {
        let val = ""
        let sut = EmptyView().onChange(of: val) { value in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    @available(iOS 14.0, *)
    func testOnChangeInspection() throws {
        let val = "initial"
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().padding().onChange(of: val) { [val] value in
            exp.fulfill()
            XCTAssertEqual(val, "initial")
            XCTAssertEqual(value, "expected")
        }.padding()
        try sut.inspect().emptyView().callOnChange(newValue: "expected")
        wait(for: [exp], timeout: 0.1)
    }

    @available(iOS 14.0, *)
    func testOnChangeInspectionWithMultipleOnChangeModifiersOfTheSameType() throws {
        var val = "initial"
        let other = ""
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().padding().onChange(of: val) { [val] value in
            exp.fulfill()
            XCTAssertEqual(val, "initial")
            XCTAssertEqual(value, "expected")
        }.onChange(of: other) { value in
            XCTFail("This should never have been called")
        }.padding()
        val = "expected"
        try sut.inspect().emptyView().callOnChange(newValue: val)
        wait(for: [exp], timeout: 0.1)
    }

    @available(iOS 14.0, *)
    func testOnChangeInspectionWithMultipleOnChangeModifiersOfTheSameType_CanCallOnChangeByIndex() throws {
        var val = "initial"
        let other = ""
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().padding().onChange(of: other) { value in
            XCTFail("This should never have been called")
        }.onChange(of: val) { [val] value in
            exp.fulfill()
            XCTAssertEqual(val, "initial")
            XCTAssertEqual(value, "expected")
        }.padding()
        val = "expected"
        try sut.inspect().emptyView().callOnChange(newValue: val, index: 1)
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
