import SwiftUI
import Combine
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol InspectionEmissary: class {
    
    associatedtype V: View & Inspectable
    typealias Inspection = (InspectableView<ViewType.View<V>>) throws -> Void
    
    var notice: PassthroughSubject<UInt, Never> { get }
    var callbacks: [UInt: (V) -> Void] { get set }
    
    @discardableResult
    func inspect(after delay: TimeInterval,
                 function: String, file: StaticString, line: UInt,
                 _ inspection: @escaping Inspection
    ) -> XCTestExpectation
    
    @discardableResult
    func inspect<P>(onReceive publisher: P,
                    function: String, file: StaticString, line: UInt,
                    _ inspection: @escaping Inspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never
}

// MARK: - Default Implementation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectionEmissary {
    
    @discardableResult
    func inspect(after delay: TimeInterval = 0,
                 function: String = #function, file: StaticString = #file, line: UInt = #line,
                 _ inspection: @escaping Inspection
    ) -> XCTestExpectation {
        let exp = XCTestExpectation(description: "Inspection at line \(line)")
        setup(inspection: inspection, expectation: exp, function: function, file: file, line: line)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak notice] in
            notice?.send(line)
        }
        return exp
    }
    
    @discardableResult
    func inspect<P>(onReceive publisher: P,
                    function: String = #function, file: StaticString = #file, line: UInt = #line,
                    _ inspection: @escaping Inspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never {
        let exp = XCTestExpectation(description: "Inspection at line \(line)")
        setup(inspection: inspection, expectation: exp, function: function, file: file, line: line)
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
                       function: String, file: StaticString, line: UInt) {
        callbacks[line] = { [weak self] view in
            do {
                try inspection(try view.inspect(function: function))
            } catch let error {
                XCTFail("\(error.localizedDescription)", file: file, line: line)
            }
            if self?.callbacks.count == 0 {
                ViewHosting.expel(function: function)
            }
            expectation.fulfill()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View where Self: Inspectable {
    @discardableResult
    mutating func on(_ keyPath: WritableKeyPath<Self, ((Self) -> Void)?>,
                     function: String = #function, file: StaticString = #file, line: UInt = #line,
                     perform: @escaping ((InspectableView<ViewType.View<Self>>) throws -> Void)
    ) -> XCTestExpectation {
        let description = Inspector.typeName(value: self) + " callback at line #\(line)"
        let expectation = XCTestExpectation(description: description)
        self[keyPath: keyPath] = { view in
            view.inspect(function: function, file: file, line: line, inspection: perform)
            ViewHosting.expel(function: function)
            expectation.fulfill()
        }
        return expectation
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier where Self: Inspectable {
    @discardableResult
    mutating func on(_ keyPath: WritableKeyPath<Self, ((Self.Body) -> Void)?>,
                     function: String = #function, file: StaticString = #file, line: UInt = #line,
                     perform: @escaping ((InspectableView<ViewType.ClassifiedView>) throws -> Void)
    ) -> XCTestExpectation {
        let description = Inspector.typeName(value: self) + " callback at line #\(line)"
        let expectation = XCTestExpectation(description: description)
        self[keyPath: keyPath] = { body in
            body.inspect(function: function, file: file, line: line, inspection: perform)
            ViewHosting.expel(function: function)
            expectation.fulfill()
        }
        return expectation
    }
}
