import SwiftUI
import Combine
import XCTest

public protocol InspectionEmissary: class {
    
    associatedtype V: View, Inspectable
    typealias Inspection = (InspectableView<ViewType.View<V>>) throws -> Void
    
    var notice: PassthroughSubject<UInt, Never> { get }
    var callbacks: [UInt: (V) -> Void] { get set }
    
    func inspect(after delay: TimeInterval,
                 file: StaticString, line: UInt, function: String,
                 _ inspection: @escaping Inspection
    ) -> XCTestExpectation
    
    func inspect<P>(onReceive publisher: P,
                    file: StaticString, line: UInt, function: String,
                    _ inspection: @escaping Inspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never
}

// MARK: - Default Implementation

public extension InspectionEmissary {
    
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
