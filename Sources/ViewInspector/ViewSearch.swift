import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol SearchBranchViewContent {
    static func nonStandardChildren(_ content: Content) throws -> LazyGroup<Content>
}

// MARK: - Public search API

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func find(text: String) throws -> InspectableView<ViewType.Text> {
        return try find(textWhere: { value, _ in value == text })
    }
    
    func find(textWhere condition: (String, ViewType.Text.Attributes) throws -> Bool
    ) throws -> InspectableView<ViewType.Text> {
        return try find(ViewType.Text.self, where: {
            try condition(try $0.string(), try $0.attributes())
        })
    }
    
    func find(viewWithId id: AnyHashable) throws -> InspectableView<ViewType.ClassifiedView> {
        return try find { try $0.id() == id }
    }
    
    func find(viewWithTag tag: AnyHashable) throws -> InspectableView<ViewType.ClassifiedView> {
        return try find { try $0.tag() == tag }
    }
    
    func find<T>(_ viewType: T.Type,
                 relation: ViewSearch.Relation = .child,
                 where condition: (InspectableView<T>) throws -> Bool = { _ in true }
    ) throws -> InspectableView<T> where T: KnownViewType {
        let view = try find(relation: relation, where: { view -> Bool in
            guard let typedView = try? view.asInspectableView(ofType: T.self)
            else { return false }
            return (try? condition(typedView)) == true
        })
        return try view.asInspectableView(ofType: T.self)
    }
    
    func findAll<T>(_ viewType: T.Type,
                    where condition: (InspectableView<T>) throws -> Bool = { _ in true }
    ) -> [InspectableView<T>] where T: KnownViewType {
        return findAll(where: { view in
            guard let typedView = try? view.asInspectableView(ofType: T.self)
            else { return false }
            return (try? condition(typedView)) == true
        }).compactMap({ try? $0.asInspectableView(ofType: T.self) })
    }
    
    func find(relation: ViewSearch.Relation = .child,
              where condition: ViewSearch.Condition
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        switch relation {
        case .child:
            return try findChild(condition: condition)
        case .parent:
            return try findParent(condition: condition)
        }
    }
    
    func findAll(where condition: ViewSearch.Condition) -> [InspectableView<ViewType.ClassifiedView>] {
        return depthFirstFullTraversal(condition)
            .compactMap { try? $0.asInspectableView() }
    }
}

// MARK: - Search

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension UnwrappedView {
    
    func findParent(condition: ViewSearch.Condition) throws -> InspectableView<ViewType.ClassifiedView> {
        var current = parentView
        while let parent = try? current?.asInspectableView() {
            if (try? condition(parent)) == true {
                return parent
            }
            current = parent.parentView
        }
        throw InspectionError.notSupported("Search did not find a match")
    }
    
    func findChild(condition: ViewSearch.Condition) throws -> InspectableView<ViewType.ClassifiedView> {
        var unknownViews: [Any] = []
        guard let result = breadthFirstSearch(condition, identificationFailure: { content in
            unknownViews.append(content.view)
        }) else {
            let blockers = unknownViews.count == 0 ? "" :
                ". Possible blockers: \(unknownViews.map({ Inspector.typeName(value: $0, prefixOnly: false) }))"
            throw InspectionError.notSupported("Search did not find a match" + blockers)
        }
        return try result.asInspectableView()
    }
    
    func breadthFirstSearch(_ condition: ViewSearch.Condition,
                            identificationFailure: (Content) -> Void) -> UnwrappedView? {
        var queue: [(isSingle: Bool, children: LazyGroup<UnwrappedView>)] = []
        queue.append((true, .init(count: 1, { _ in self })))
        while !queue.isEmpty {
            let (isSingle, children) = queue.remove(at: 0)
            for (offset, view) in children.enumerated() {
                if (try? condition(try view.asInspectableView())) == true {
                    return view
                }
                let index = (isSingle && offset == 0) ? nil : offset
                guard let identity = ViewSearch.identify(view.content),
                      let instance = try? identity.builder(view.content, view.parentView, index)
                else {
                    identificationFailure(view.content)
                    continue
                }
                if let descendants = try? identity.descendants(instance) {
                    let isSingle = (identity.viewType is SingleViewContent.Type) && descendants.count == 1
                    queue.append((isSingle, descendants))
                }
            }
        }
        return nil
    }
    
    func depthFirstFullTraversal(isSingle: Bool = true, offset: Int = 0, _ condition: ViewSearch.Condition) -> [UnwrappedView] {
        
        var current: [UnwrappedView] = []
        if (try? condition(try self.asInspectableView())) == true {
            current.append(self)
        }
        
        let index = (isSingle && offset == 0) ? nil : offset
        guard let identity = ViewSearch.identify(self.content),
              let instance = try? identity.builder(self.content, self.parentView, index),
              let descendants = try? identity.descendants(instance)
        else { return current }
        
        let isSingle = (identity.viewType is SingleViewContent.Type) && descendants.count == 1
        
        let joined = [current] + descendants.enumerated().map({ offset, child in
            child.depthFirstFullTraversal(isSingle: isSingle, offset: offset, condition)
        })
        return joined.flatMap { $0 }
    }
}

// MARK: - Search namespace and types

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct ViewSearch {
    public enum Relation {
        case child
        case parent
    }
    public typealias Condition = (InspectableView<ViewType.ClassifiedView>) throws -> Bool
}

// MARK: - Index

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewSearch {
    
    static private(set) var index: [String: [ViewIdentity]] = {
        let identities: [ViewIdentity] = [
            .init(ViewType.AnyView.self), .init(ViewType.Group.self),
            .init(ViewType.Text.self), .init(ViewType.EmptyView.self),
            .init(ViewType.HStack.self), .init(ViewType.Button.self)
        ]
        var index = [String: [ViewIdentity]](minimumCapacity: 27) // alphabet + empty string
        identities.forEach { identity in
            let letter = String(identity.viewType.typePrefix.prefix(1))
            var array = index[letter] ?? []
            array.append(identity)
            index[letter] = array
        }
        return index
    }()
    
    static func identify(_ content: Content) -> ViewIdentity? {
        let typePrefix = Inspector.typeName(value: content.view, prefixOnly: true)
        if let identity = index[String(typePrefix.prefix(1))]?
            .first(where: { $0.viewType.typePrefix == typePrefix }) {
            return identity
        }
        if (try? content.extractCustomView()) != nil {
            return .init(ViewType.View<TraverseStubView>.self)
        }
        return nil
    }
}

// MARK: - ViewIdentity

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewSearch {
    
    struct ViewIdentity {
        let viewType: KnownViewType.Type
        let builder: (Content, UnwrappedView?, Int?) throws -> UnwrappedView
        let descendants: (UnwrappedView) throws -> LazyGroup<UnwrappedView>
        
        private init<T>(_ type: T.Type,
                        call: String?,
                        descendants: @escaping (UnwrappedView) throws -> LazyGroup<UnwrappedView>
        ) where T: KnownViewType {
            viewType = type
            let callWithIndex: (Int?) -> String = { index in
                let base = call ?? (type.typePrefix.prefix(1).lowercased() + type.typePrefix.dropFirst())
                return base + (index.flatMap({ "(\($0))" }) ?? "()")
            }
            builder = { content, parent, index in
                try InspectableView<T>.init(content, parent: parent, call: callWithIndex(index), index: index)
            }
            self.descendants = { parent in
                let children = try descendants(parent)
                let modifiers = parent.content.modifierDescendants(parent: parent)
                return children + modifiers
            }
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: SingleViewContent {
            self.init(type, call: call, descendants: { parent in
                let view = try T.child(parent.content)
                return .init(count: 1) { _ in
                    try InspectableView<ViewType.ClassifiedView>(
                        view, parent: parent, index: nil)
                }
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: MultipleViewContent {
            self.init(type, call: call, descendants: { parent in
                let viewes = try T.children(parent.content)
                return .init(count: viewes.count) { index in
                    try InspectableView<ViewType.ClassifiedView>(
                        try viewes.element(at: index), parent: parent, index: index)
                }
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: SingleViewContent, T: MultipleViewContent {
            self.init(type, call: call, descendants: { parent in
                let viewes = try T.children(parent.content)
                return .init(count: viewes.count) { index in
                    try InspectableView<ViewType.ClassifiedView>(
                        try viewes.element(at: index), parent: parent, index: index)
                }
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil) where T: KnownViewType {
            self.init(type, call: call, descendants: { _ in .empty })
        }
    }
}

// MARK: - ModifierIdentity

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewSearch {
    
    static private(set) var modifierIdentities: [ModifierIdentity] = [
        .init(name: "_OverlayModifier", builder: { parent in
            try parent.content.overlay(parent: parent)
        }),
        .init(name: "_BackgroundModifier", builder: { parent in
            try parent.content.background(parent: parent)
        }),
        .init(name: "_MaskEffect", builder: { parent in
            try parent.content.mask(parent: parent)
        })
    ]
    
    struct ModifierIdentity {
        let name: String
        let builder: (UnwrappedView) throws -> UnwrappedView
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func modifierDescendants(parent: UnwrappedView) -> LazyGroup<UnwrappedView> {
        let modifierNames = self.modifiers
                .compactMap { $0 as? ModifierNameProvider }
                .map { $0.modifierType }
        let identities = ViewSearch.modifierIdentities.filter({ identity -> Bool in
            modifierNames.contains(where: { $0.hasPrefix(identity.name) })
        })
        return .init(count: identities.count) { index -> UnwrappedView in
            try identities[index].builder(parent)
        }
    }
}

// MARK: - TraverseStubView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct TraverseStubView: View, Inspectable {
    var body: some View { EmptyView() }
}
