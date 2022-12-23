import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView: Sequence where View: MultipleViewContent {
    
    public typealias Element = InspectableView<ViewType.ClassifiedView>
    
    public struct Iterator: IteratorProtocol {
        
        private var index: Int = -1
        private let group: LazyGroup<Content>
        private let view: UnwrappedView
        
        init(_ group: LazyGroup<Content>, view: UnwrappedView) {
            self.group = group
            self.view = view
        }
        
        mutating public func next() -> Element? {
            index += 1
            guard index < group.count else { return nil }
            let content = (try? group.element(at: index)) ?? .absentView
            return try? .init(content, parent: view)
        }
    }

    public func makeIterator() -> Iterator {
        // swiftlint:disable force_try
        return .init(try! View.children(content), view: self)
        // swiftlint:enable force_try
    }

    public var underestimatedCount: Int {
        // swiftlint:disable force_try
        return try! View.children(content).count
        // swiftlint:enable force_try
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView: Collection, BidirectionalCollection, RandomAccessCollection
    where View: MultipleViewContent {
    
    public typealias Index = Int
    public var startIndex: Index { 0 }
    public var endIndex: Index { count }
    public var count: Int { underestimatedCount }
    
    public subscript(index: Index) -> Iterator.Element {
        do {
            do {
                return try .init(try child(at: index), parent: self, call: "[\(index)]")
            } catch InspectionError.viewNotFound {
                return try Element(.absentView, parent: self, index: index)
            } catch { throw error }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    public func index(after index: Index) -> Index { index + 1 }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Content {
    
    static var absentView: Content {
        return Content(AbsentView())
    }
    
    var isAbsent: Bool { view is AbsentView }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct AbsentView: View {
    var body: Never { fatalError() }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView {
    public var isAbsent: Bool {
        return content.isAbsent
    }
}
