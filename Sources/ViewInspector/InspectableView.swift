import SwiftUI
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct InspectableView<View> where View: KnownViewType {
    
    internal let content: Content
    internal let parentView: UnwrappedView?
    internal let indexInParent: Int?
    
    internal init(_ content: Content, parent: UnwrappedView?, index: Int?) throws {
        if !View.typePrefix.isEmpty,
           Inspector.isTupleView(content.view),
           View.self != ViewType.TupleView.self {
            throw InspectionError.notSupported(
                "Unable to extract \(View.typePrefix): please specify its index inside parent view")
        }
        self.content = content
        self.indexInParent = index
        if View.self == ViewType.ClassifiedView.self {
            self.parentView = parent?.parentView
        } else {
            self.parentView = parent
        }
        do {
            try Inspector.guardType(value: content.view, prefix: View.typePrefix)
        } catch {
            if let err = error as? InspectionError, case .typeMismatch = err {
                throw InspectionError.inspection(
                    path: pathToRoot, factual: Inspector.typeName(value: content.view),
                    expected: View.typePrefix)
            }
            throw error
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol UnwrappedView {
    var content: Content { get }
    var parentView: UnwrappedView? { get }
    var indexInParent: Int? { get }
    var pathToRoot: String { get }
    func inspectionCall(index: Int?) -> String
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView: UnwrappedView {
    func inspectionCall(index: Int?) -> String {
        View.inspectionCall(index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    func parent() throws -> InspectableView<ViewType.ClassifiedView> {
        guard let parent = self.parentView else {
            throw InspectionError.parentViewNotFound(view: Inspector.typeName(value: content.view))
        }
        return try .init(parent.content, parent: parent.parentView, index: parent.parentView?.indexInParent)
    }
    
    var pathToRoot: String {
        return (parentView?.pathToRoot ?? "inspect()") + inspectionCall(index: indexInParent)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView where View: SingleViewContent {
    func child() throws -> Content {
        return try View.child(content)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView where View: MultipleViewContent {
    
    func child(at index: Int, isTupleExtraction: Bool = false) throws -> Content {
        let viewes = try View.children(content)
        guard index >= 0 && index < viewes.count else {
            throw InspectionError.viewIndexOutOfBounds(index: index, count: viewes.count)
        }
        let child = try viewes.element(at: index)
        if !isTupleExtraction && Inspector.isTupleView(child.view) {
            // swiftlint:disable line_length
            throw InspectionError.notSupported(
                "Please insert .tupleView(\(index)) after \(Inspector.typeName(type: View.self)) for inspecting its children at index \(index)")
            // swiftlint:enable line_length
        }
        return child
    }
}

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
            return try? .init(content, parent: view, index: groupIterator.index)
        }
    }

    public func makeIterator() -> Iterator {
        return .init(View._children(content), view: self)
    }

    public var underestimatedCount: Int {
        return View._children(content).count
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView: Collection, BidirectionalCollection, RandomAccessCollection
    where View: MultipleViewContent {
    
    public typealias Index = Int
    public var startIndex: Index { 0 }
    public var endIndex: Index { count }
    public var count: Int { View._children(content).count }
    
    public subscript(index: Index) -> Iterator.Element {
        do {
            let viewes = try View.children(content)
            return try .init(try viewes.element(at: index), parent: self, index: index)
        } catch {
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        return try .init(try Inspector.unwrap(view: self, modifiers: []), parent: nil, index: nil)
    }
    
    func inspect(file: StaticString = #file, line: UInt = #line,
                 traverse: (InspectableView<ViewType.ClassifiedView>) throws -> Void) {
        do {
            try traverse(try inspect())
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View where Self: Inspectable {
    
    func inspect() throws -> InspectableView<ViewType.View<Self>> {
        return try .init(Content(self), parent: nil, index: nil)
    }
    
    func inspect(file: StaticString = #file, line: UInt = #line,
                 traverse: (InspectableView<ViewType.View<Self>>) throws -> Void) {
        do {
            try traverse(try inspect())
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}

// MARK: - Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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
        let modifier = try self.modifier(modifierLookup, call: call)
        guard let attribute = try? Inspector.attribute(path: path, value: modifier) as? Type
        else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: content.view), modifier: call)
        }
        return attribute
    }
    
    func modifier(_ modifierLookup: (ModifierNameProvider) -> Bool, call: String) throws -> Any {
        guard let modifier = content.modifiers.lazy
                .compactMap({ $0 as? ModifierNameProvider })
                .last(where: modifierLookup)
        else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: content.view), modifier: call)
        }
        return modifier
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol ModifierNameProvider {
    var modifierType: String { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ModifiedContent: ModifierNameProvider {
    var modifierType: String {
        return Inspector.typeName(type: Modifier.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension MultipleViewContent {
    static func _children(_ content: Content) -> LazyGroup<Content> {
        return (try? children(content)) ?? .empty
    }
}
