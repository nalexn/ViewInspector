import SwiftUI
import Combine
import XCTest

public protocol InspectionEmissary: class {
    
    associatedtype V: View & Inspectable
    typealias Inspection = (InspectableView<ViewType.View<V>>) throws -> Void
    
    var notice: PassthroughSubject<UInt, Never> { get }
    var callbacks: [UInt: (V) -> Void] { get set }
    
    @discardableResult
    func inspect(after delay: TimeInterval,
                 file: StaticString, line: UInt, function: String,
                 _ inspection: @escaping Inspection
    ) -> XCTestExpectation
    
    @discardableResult
    func inspect<P>(onReceive publisher: P,
                    file: StaticString, line: UInt, function: String,
                    _ inspection: @escaping Inspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never
}

// MARK: - Default Implementation

public extension InspectionEmissary {
    
    @discardableResult
    func inspect(after delay: TimeInterval = 0,
                 file: StaticString = #file, line: UInt = #line, function: String = #function,
                 _ inspection: @escaping Inspection
    ) -> XCTestExpectation {
        let exp = XCTestExpectation(description: "Inspection at line \(line)")
        setup(inspection: inspection, expectation: exp, file: file, line: line, function: function)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak notice] in
            notice?.send(line)
        }
        return exp
    }
    
    @discardableResult
    func inspect<P>(onReceive publisher: P,
                    file: StaticString = #file, line: UInt = #line, function: String = #function,
                    _ inspection: @escaping Inspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never {
        let exp = XCTestExpectation(description: "Inspection at line \(line)")
        setup(inspection: inspection, expectation: exp, file: file, line: line, function: function)
        var subscription: AnyCancellable?
        _ = subscription
        subscription = publisher.sink { [weak notice] _ in
            subscription = nil
            DispatchQueue.main.async {
                notice?.send(line)
            }
        }
        return exp
    }
    
    private func setup(inspection: @escaping Inspection,
                       expectation: XCTestExpectation,
                       file: StaticString, line: UInt, function: String) {
        callbacks[line] = { [weak self] view in
            do {
                try inspection(try view.inspect())
            } catch let error {
                XCTFail("\(error.localizedDescription)", file: file, line: line)
            }
            if self?.callbacks.count == 0 {
                ViewHosting.expel(viewId: function)
            }
            expectation.fulfill()
        }
    }
}

public extension View {
    mutating func on(_ keyPath: WritableKeyPath<Self, ((Self) -> Void)?>,
                     file: StaticString = #file, line: UInt = #line,
                     viewId: String = #function,
                     perform: @escaping ((Self) throws -> Void)) -> XCTestExpectation {
        let description = Inspector.typeName(value: self) + " callback at line #\(line)"
        let expectation = XCTestExpectation(description: description)
        self[keyPath: keyPath] = { view in
            do {
                try perform(view)
                ViewHosting.expel(viewId: viewId)
                expectation.fulfill()
            } catch let error {
                XCTFail("\(error.localizedDescription)", file: file, line: line)
            }
        }
        return expectation
    }
}
