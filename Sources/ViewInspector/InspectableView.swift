import SwiftUI
import XCTest

public struct InspectableView<View> where View: KnownViewType {
    
    internal let content: Content
    
    internal init(_ content: Content) throws {
        try Inspector.guardType(value: content.view, prefix: View.typePrefix)
        self.content = content
    }
}

internal extension InspectableView where View: SingleViewContent {
    func child() throws -> Content {
        return try View.child(content)
    }
}

internal extension InspectableView where View: MultipleViewContent {
    
    func child(at index: Int) throws -> Content {
        let viewes = try View.children(content)
        guard index >= 0 && index < viewes.count else {
            throw InspectionError.viewIndexOutOfBounds(
                index: index, count: viewes.count) }
        return try viewes.element(at: index)
    }
}

extension InspectableView: Sequence where View: MultipleViewContent {
    
    public typealias Element = InspectableView<ViewType.ClassifiedView>
    
    public struct Iterator: IteratorProtocol {
        
        private var groupIterator: LazyGroup<Content>.Iterator
        
        init(_ group: LazyGroup<Content>) {
            groupIterator = group.makeIterator()
        }
        
        mutating public func next() -> Element? {
            guard let content = groupIterator.next()
                else { return nil }
            return try? .init(content)
        }
    }

    public func makeIterator() -> Iterator {
        let group: LazyGroup<Content> = (try? View.children(content)) ?? .empty
        return .init(group)
    }

    public var underestimatedCount: Int {
        return (try? View.children(content))?.count ?? 0
    }
}

extension InspectableView: Collection, BidirectionalCollection, RandomAccessCollection
    where View: MultipleViewContent {
    
    public typealias Index = Int
    public var startIndex: Index { 0 }
    public var endIndex: Index { count }
    public var count: Int { (try? View.children(content))?.count ?? 0 }
    
    public subscript(index: Index) -> Iterator.Element {
        do {
            let viewes = try View.children(content)
            return try .init(try viewes.element(at: index))
        } catch let error {
            fatalError("\(error)")
        }
    }

    public func index(after index: Index) -> Index {
        return index + 1
    }

    public func index(before index: Index) -> Index {
        return index - 1
    }
}

// MARK: - Inspection of a Custom View

public extension View {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        return try .init(try Inspector.unwrap(view: self, modifiers: []))
    }
}

public extension View where Self: Inspectable {
    
    func inspect() throws -> InspectableView<ViewType.View<Self>> {
        return try .init(Content(self))
    }
    
    func inspect(file: StaticString = #file, line: UInt = #line,
                 traverse: (InspectableView<ViewType.View<Self>>) throws -> Void) {
        do {
            try traverse(try inspect())
        } catch let error {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}

// MARK: - Modifiers

internal extension InspectableView {
    
    func modifierAttribute<Type>(modifierName: String, path: String,
                                 type: Type.Type, call: String) throws -> Type {
        return try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType.contains(modifierName) else { return false }
            return (try? Inspector.attribute(path: path, value: modifier) as? Type) != nil
        }, path: path, type: type, call: call)
    }
    
    func modifierAttribute<Type>(modifierLookup: (ModifierNameProvider) -> Bool, path: String,
                                 type: Type.Type, call: String) throws -> Type {
        let foundModifier = content.modifiers.lazy
            .compactMap { $0 as? ModifierNameProvider }
            .last(where: modifierLookup)
        guard let modifier = foundModifier,
            let attribute = try? Inspector.attribute(path: path, value: modifier) as? Type
        else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: content.view), modifier: call)
        }
        return attribute
    }
}

internal protocol ModifierNameProvider {
    var modifierType: String { get }
}

extension ModifiedContent: ModifierNameProvider {
    var modifierType: String {
        return Inspector.typeName(type: Modifier.self)
    }
}
