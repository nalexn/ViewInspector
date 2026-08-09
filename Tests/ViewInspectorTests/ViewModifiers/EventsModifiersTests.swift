import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewEventsTests

@MainActor
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
        let val = Optional(Inspector.TestValue(value: "initial"))
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().onChange(of: val) { [val] value in
            XCTAssertEqual(val, Inspector.TestValue(value: "initial"))
            XCTAssertEqual(value, Inspector.TestValue(value: "expected"))
            exp.fulfill()
        }.padding()
        try sut.inspect().emptyView()
            .callOnChange(newValue: Inspector.TestValue(value: "expected"))
        wait(for: [exp], timeout: 0.1)
    }

    func testOnChangeInitial() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let val = ""
        let sut = EmptyView().onChange(of: val, initial: true) {}
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testOnChangeInitialInspection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let val = Optional(Inspector.TestValue(value: "initial"))
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().onChange(of: val, initial: true) {
            exp.fulfill()
        }.padding()
        try sut.inspect().emptyView()
            .callOnChange(oldValue: val, newValue: Inspector.TestValue(value: "expected"))
        wait(for: [exp], timeout: 0.1)
    }

    func testOnChangeOldValueNewValue() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let val = ""
        let sut = EmptyView().onChange(of: val) { _, _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testOnChangeOldValueNewValueInspection() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let val = Optional(Inspector.TestValue(value: "inferred type"))
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().onChange(of: val) { oldValue, newValue in
            XCTAssertEqual(oldValue, Inspector.TestValue(value: "initial"))
            XCTAssertEqual(newValue, Inspector.TestValue(value: "expected"))
            exp.fulfill()
        }.padding()
        try sut.inspect().emptyView()
            .callOnChange(
                oldValue: Inspector.TestValue(value: "initial"),
                newValue: Inspector.TestValue(value: "expected")
            )
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
        let expSearch = XCFlagExpectation(description: "search")
        let expText = XCFlagExpectation(description: "text")
        let sut = EmptyView()
            .onSubmit(of: .search, {
                XCTAssertTrue(expText.isFulfilled)
                expSearch.fulfill()
            })
            .onSubmit(of: .text, {
                XCTAssertFalse(expSearch.isFulfilled)
                expText.fulfill()
            })
        try sut.inspect().callOnSubmit(of: .text)
        try sut.inspect().callOnSubmit(of: .search)
        wait(for: [expSearch, expText], timeout: 0.1)
    }

    func testRefreshable() throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else { throw XCTSkip() }
        let sut = EmptyView().refreshable { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testRefreshableInspection() async throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else { throw XCTSkip() }
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().refreshable {
            exp.fulfill()
        }.padding().onDisappear(perform: { })
        try await sut.inspect().emptyView().callRefreshable()
        await fulfillment(of: [exp], timeout: 0.1)
    }

    func testTask() throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else { throw XCTSkip() }
        let sut = EmptyView().task { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testTaskInspection() async throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else { throw XCTSkip() }
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding().task {
            exp.fulfill()
        }.padding().onDisappear(perform: { })
        try await sut.inspect().emptyView().callTask()
        await fulfillment(of: [exp], timeout: 0.1)
    }

    func testTaskIdInspection() async throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else { throw XCTSkip() }
        let exp = XCTestExpectation(description: #function)
        let sut = EmptyView().padding()
            .task(id: "id") {
                exp.fulfill()
            }
        try await sut.inspect().emptyView().callTask(id: "id")
        await fulfillment(of: [exp], timeout: 0.1)
    }

    func testTaskIdInspectionWithIndex() async throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else { throw XCTSkip() }
        let exp1 = XCTestExpectation(description: "task1")
        let exp2 = XCTestExpectation(description: "task2")
        exp1.assertForOverFulfill = true
        exp2.assertForOverFulfill = true

        let sut = EmptyView().padding()
            .task(id: "id1") {
                exp1.fulfill()
            }
            .task(id: "id2") {
                exp2.fulfill()
            }

        try await sut.inspect().emptyView().callTask(id: "id1", index: 0)
        await fulfillment(of: [exp1], timeout: 0.1)

        try await sut.inspect().emptyView().callTask(id: "id2", index: 1)
        await fulfillment(of: [exp2], timeout: 0.1)
    }

    func testTaskIdInspectionMultipleDifferentTypes() async throws {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else { throw XCTSkip() }
        struct CustomEquatableStruct: Equatable {
            let value: Int
        }
        let exp1 = XCTestExpectation(description: "task1")
        let exp2 = XCTestExpectation(description: "task2")
        let exp3 = XCTestExpectation(description: "task3")
        exp1.assertForOverFulfill = true
        exp2.assertForOverFulfill = true
        exp3.assertForOverFulfill = true

        let sut = EmptyView().padding()
            .task(id: "id") {
                exp1.fulfill()
            }
            .task(id: 2) {
                exp2.fulfill()
            }
            .task(id: CustomEquatableStruct(value: 1)) {
                exp3.fulfill()
            }

        _ = try await sut.inspect().emptyView().callTask(id: 2)
        _ = try await sut.inspect().emptyView().callTask(id: "id")
        _ = try await sut.inspect().emptyView().callTask(id: CustomEquatableStruct(value: 1))

        await fulfillment(of: [exp1, exp2, exp3], timeout: 0.1)
    }
}

// MARK: - ViewPublisherEventsTests

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewPublisherEventsTests: XCTestCase {
    
    func testOnReceive() throws {
        let publisher = Just<Void>(())
        let sut = EmptyView().onReceive(publisher) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Inspector {
    struct TestValue: Equatable {
        let value: String
    }
}

private final class XCFlagExpectation: XCTestExpectation, @unchecked Sendable {
    
    private(set) var isFulfilled: Bool = false

    override func fulfill() {
        isFulfilled = true
        super.fulfill()
    }
}
