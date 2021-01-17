@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct LazyGroup<T> {
    
    private let access: (Int) throws -> T
    public let count: Int
    
    init(count: Int, _ access: @escaping (Int) throws -> T) {
        self.count = count
        self.access = access
    }
    
    func element(at index: Int) throws -> T {
        guard 0 ..< count ~= index else {
            throw InspectionError.viewIndexOutOfBounds(index: index, count: count)
        }
        return try access(index)
    }
    
    static var empty: Self {
        return .init(count: 0) { _ in fatalError() }
    }
    
    static func + (lhs: LazyGroup, rhs: LazyGroup) -> LazyGroup {
        return .init(count: lhs.count + rhs.count) { index -> T in
            if index < lhs.count {
                return try lhs.element(at: index)
            }
            return try rhs.element(at: index - lhs.count)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension LazyGroup: Sequence {
    
    public struct Iterator: IteratorProtocol {
        public typealias Element = T
        internal var index = -1
        private var group: LazyGroup<Element>
        
        init(group: LazyGroup<Element>) {
            self.group = group
        }
        
        mutating public func next() -> Element? {
            index += 1
            do {
                return try group.element(at: index)
            } catch _ {
                return nil
            }
        }
    }

    public func makeIterator() -> Iterator {
        .init(group: self)
    }

    public var underestimatedCount: Int { count }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension LazyGroup: RandomAccessCollection {
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    public subscript(position: Int) -> T {
        // swiftlint:disable force_try
        return try! element(at: position)
        // swiftlint:enable force_try
    }
    
    public func index(after index: Int) -> Int { index + 1 }
}
