import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView: Sequence where View: MultipleViewContent {
    
    public typealias Element = InspectableView<ViewType.ClassifiedView>
    
    public struct Iterator: IteratorProtocol {
        
        private var groupIterator: LazyGroup<Content>.Iterator
        private let view: UnwrappedView
        
        init(_ group: LazyGroup<Content>, view: UnwrappedView) {
            groupIterator = group.makeIterator()
            self.view = view
        }
        
        mutating public func next() -> Element? {
            guard let content = groupIterator.next()
                else { return nil }
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
        // swiftlint:disable force_try
        let viewes = try! View.children(content)
        return try! .init(try! viewes.element(at: index), parent: self, call: "[\(index)]")
        // swiftlint:enable force_try
    }

    public func index(after index: Index) -> Index { index + 1 }
}
