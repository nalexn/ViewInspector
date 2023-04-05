import SwiftUI
import Combine
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol InspectionEmissary: AnyObject {
    
    associatedtype V
    var notice: PassthroughSubject<UInt, Never> { get }
    var callbacks: [UInt: (V) -> Void] { get set }
}

// MARK: - InspectionEmissary for View

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectionEmissary where V: View {
    
    typealias ViewInspection = (InspectableView<ViewType.View<V>>) throws -> Void
    
    @discardableResult
    func inspect(after delay: TimeInterval = 0,
                 function: String = #function, file: StaticString = #file, line: UInt = #line,
                 _ inspection: @escaping ViewInspection
    ) -> XCTestExpectation {
        return inspect(after: delay, function: function, file: file, line: line) { view in
            let unwrapped = try view.inspect(function: function)
                .asInspectableView(ofType: ViewType.View<V>.self)
            return try inspection(unwrapped)
        }
    }
    
    @discardableResult
    func inspect<P>(onReceive publisher: P,
                    after delay: TimeInterval = 0,
                    function: String = #function, file: StaticString = #file, line: UInt = #line,
                    _ inspection: @escaping ViewInspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never {
        return inspect(onReceive: publisher, after: delay, function: function, file: file, line: line) { view in
            let unwrapped = try view.inspect(function: function)
                .asInspectableView(ofType: ViewType.View<V>.self)
            return try inspection(unwrapped)
        }
    }
}

// MARK: - InspectionEmissary for ViewModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectionEmissary where V: ViewModifier {
    
    typealias ViewModifierInspection = (InspectableView<ViewType.ViewModifier<V>>) throws -> Void
    
    @discardableResult
    func inspect(after delay: TimeInterval = 0,
                 function: String = #function, file: StaticString = #file, line: UInt = #line,
                 _ inspection: @escaping ViewModifierInspection
    ) -> XCTestExpectation {
        return inspect(after: delay, function: function, file: file, line: line) { view in
            return try inspection(try view.inspect(function: function))
        }
    }
    
    @discardableResult
    func inspect<P>(onReceive publisher: P,
                    after delay: TimeInterval = 0,
                    function: String = #function, file: StaticString = #file, line: UInt = #line,
                    _ inspection: @escaping ViewModifierInspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never {
        return inspect(onReceive: publisher, after: delay, function: function, file: file, line: line) { view in
            return try inspection(try view.inspect(function: function))
        }
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension InspectionEmissary {
    
    typealias SubjectInspection = (_ subject: V) throws -> Void
    
    func inspect(after delay: TimeInterval,
                 function: String, file: StaticString, line: UInt,
                 inspection: @escaping SubjectInspection
    ) -> XCTestExpectation {
        let exp = XCTestExpectation(description: "Inspection at line \(line)")
        setup(inspection: inspection, expectation: exp, function: function, file: file, line: line)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak notice] in
            notice?.send(line)
        }
        return exp
    }
    
    func inspect<P>(onReceive publisher: P,
                    after delay: TimeInterval,
                    function: String, file: StaticString, line: UInt,
                    inspection: @escaping SubjectInspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never {
        let exp = XCTestExpectation(description: "Inspection at line \(line)")
        setup(inspection: inspection, expectation: exp, function: function, file: file, line: line)
        var subscription: AnyCancellable?
        _ = subscription
        subscription = publisher.sink { [weak notice] _ in
            subscription = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak notice] in
                notice?.send(line)
            }
        }
        return exp
    }
    
    func setup(inspection: @escaping SubjectInspection,
               expectation: XCTestExpectation,
               function: String, file: StaticString, line: UInt) {
        callbacks[line] = { [weak self] view in
            do {
                try inspection(view)
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

// MARK: - on keyPath inspection

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View {
    @discardableResult
    mutating func on(_ keyPath: WritableKeyPath<Self, ((Self) -> Void)?>,
                     function: String = #function, file: StaticString = #file, line: UInt = #line,
                     perform: @escaping ((InspectableView<ViewType.View<Self>>) throws -> Void)
    ) -> XCTestExpectation {
        return Inspector.injectInspectionCallback(
            value: &self, keyPath: keyPath, function: function, file: file, line: line) { body in
            body.inspect(function: function, file: file, line: line, inspection: perform)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier {
    @discardableResult
    mutating func on(_ keyPath: WritableKeyPath<Self, ((Self) -> Void)?>,
                     function: String = #function, file: StaticString = #file, line: UInt = #line,
                     perform: @escaping ((InspectableView<ViewType.ViewModifier<Self>>) throws -> Void)
    ) -> XCTestExpectation {
        return Inspector.injectInspectionCallback(
            value: &self, keyPath: keyPath, function: function, file: file, line: line) { body in
            body.inspect(function: function, file: file, line: line, inspection: perform)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Inspector {
    static func injectInspectionCallback<T>(
        value: inout T, keyPath: WritableKeyPath<T, ((T) -> Void)?>,
        function: String, file: StaticString, line: UInt,
        inspection: @escaping ((T) -> Void)
    ) -> XCTestExpectation {
        let description = Inspector.typeName(value: self) + " callback at line #\(line)"
        let expectation = XCTestExpectation(description: description)
        value[keyPath: keyPath] = { body in
            inspection(body)
            ViewHosting.expel(function: function)
            expectation.fulfill()
        }
        return expectation
    }
}
