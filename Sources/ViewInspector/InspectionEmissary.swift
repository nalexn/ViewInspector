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
    
    typealias ViewInspection = @Sendable @MainActor (InspectableView<ViewType.View<V>>) async throws -> Void
    
    @discardableResult
    func inspect(after delay: TimeInterval = 0,
                 function: String = #function, file: StaticString = #file, line: UInt = #line,
                 _ inspection: @escaping ViewInspection
    ) -> XCTestExpectation {
        return inspect(after: delay, function: function, file: file, line: line) { view in
            let unwrapped = try view.inspect(function: function)
                .asInspectableView(ofType: ViewType.View<V>.self)
            return try await inspection(unwrapped)
        }
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func inspect(after delay: SuspendingClock.Duration = .seconds(0),
                 function: String = #function, file: StaticString = #file, line: UInt = #line,
                 _ inspection: @escaping ViewInspection
    ) async throws {
        return try await inspect(after: delay, function: function, file: file, line: line) { view in
            let unwrapped = try view.inspect(function: function)
                .asInspectableView(ofType: ViewType.View<V>.self)
            return try await inspection(unwrapped)
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
            return try await inspection(unwrapped)
        }
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func inspect<P>(onReceive publisher: P,
                    after delay: SuspendingClock.Duration = .seconds(0),
                    function: String = #function, file: StaticString = #file, line: UInt = #line,
                    _ inspection: @escaping ViewInspection
    ) async throws where P: Publisher {
        return try await inspect(onReceive: publisher, after: delay, function: function, file: file, line: line) { view in
            let unwrapped = try view.inspect(function: function)
                .asInspectableView(ofType: ViewType.View<V>.self)
            return try await inspection(unwrapped)
        }
    }
}

// MARK: - InspectionEmissary for ViewModifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectionEmissary where V: ViewModifier {
    
    typealias ViewModifierInspection = @Sendable @MainActor (InspectableView<ViewType.ViewModifier<V>>) async throws -> Void
    
    @discardableResult
    func inspect(after delay: TimeInterval = 0,
                 function: String = #function, file: StaticString = #file, line: UInt = #line,
                 _ inspection: @escaping ViewModifierInspection
    ) -> XCTestExpectation {
        return inspect(after: delay, function: function, file: file, line: line) { view in
            return try await inspection(try view.inspect(function: function))
        }
    }
    
    @discardableResult
    func inspect<P>(onReceive publisher: P,
                    after delay: TimeInterval = 0,
                    function: String = #function, file: StaticString = #file, line: UInt = #line,
                    _ inspection: @escaping ViewModifierInspection
    ) -> XCTestExpectation where P: Publisher, P.Failure == Never {
        return inspect(onReceive: publisher, after: delay, function: function, file: file, line: line) { view in
            return try await inspection(try view.inspect(function: function))
        }
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension InspectionEmissary {
    
    typealias SubjectInspection = @Sendable @MainActor (_ subject: V) async throws -> Void
    
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
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func inspect(after delay: SuspendingClock.Duration,
                 function: String, file: StaticString, line: UInt,
                 inspection: @escaping SubjectInspection
    ) async throws {
        async let setup: Void = try await setup(inspection: inspection, function: function, file: file, line: line)
        Task { @MainActor [weak notice] in
            let clock = SuspendingClock()
            try await clock.sleep(until: clock.now + delay)
            notice?.send(line)
        }
        try await setup
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
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func inspect<P>(onReceive publisher: P,
                    after delay: SuspendingClock.Duration,
                    function: String, file: StaticString, line: UInt,
                    inspection: @escaping SubjectInspection
    ) async throws where P: Publisher {
        async let setup: Void = try await setup(inspection: inspection, function: function, file: file, line: line)
        Task { @MainActor [weak notice] in
            _ = try await publisher.values.first { _ in true }
            let clock = SuspendingClock()
            try await clock.sleep(until: clock.now + delay)
            notice?.send(line)
        }
        try await setup
    }
    
    func setup(inspection: @escaping SubjectInspection,
               expectation: XCTestExpectation,
               function: String, file: StaticString, line: UInt) {
        callbacks[line] = { [weak self] view in
            Task { [weak self] in
                do {
                    try await inspection(view)
                } catch let error {
                    XCTFail("\(error.localizedDescription)", file: file, line: line)
                }
                if self?.callbacks.count == 0 {
                    await MainActor.run { ViewHosting.expel(function: function) }
                }
                expectation.fulfill()
            }
        }
    }
    
    @MainActor func setup(inspection: @escaping SubjectInspection,
                function: String, file: StaticString, line: UInt) async throws {
        try await withUnsafeThrowingContinuation { @MainActor continuation in
            callbacks[line] = { view in
                Task {
                    do {
                        continuation.resume(returning: try await inspection(view))
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                }
            }
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
