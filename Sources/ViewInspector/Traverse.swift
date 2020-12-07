import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Traverse: KnownViewType {
        public static var typePrefix: String = ""
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.Traverse {
    struct Params {
        let parent: UnwrappedView
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    func traverse() throws -> InspectableView<ViewType.Traverse> {
        return try .init(Content(ViewType.Traverse.Params(parent: self)), parent: nil)
    }
}

// MARK: - Double dispatch

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Traverse: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension UnwrappedView {
    
    internal func traverseIfNeeded<V>(content: Content, _ viewType: V.Type
    ) throws -> UnwrappedView? where V: KnownViewType {
        guard let traverseParams = content.view as? ViewType.Traverse.Params
        else { return nil }
        let notFound = "Could not find view with type \(Inspector.typeName(type: viewType, prefixOnly: false))."
        return try traverseParams.search(notFound: notFound) { identity, view -> Bool in
            return identity.viewType == viewType
        }
    }
}

// MARK: - Lookup

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Traverse.Params {
    func search(notFound: String, _ condition: (ViewIdentity, UnwrappedView) -> Bool) throws -> UnwrappedView {

        var unknownViews: [Any] = []
        guard let result = parent.breadthFirstSearch({ view in
            guard let identity = ViewType.Traverse.identify(view.content) else {
                unknownViews.append(view.content.view)
                return nil
            }
            return (identity, condition(identity, view))
        }) else {
            let blockers = unknownViews.count == 0 ? "" :
                " Possible blockers: \(unknownViews.map({ Inspector.typeName(value: $0, prefixOnly: false) }))"
            throw InspectionError.notSupported(notFound + blockers)
        }
        return result
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension UnwrappedView {
    
    func breadthFirstSearch(_ condition: (UnwrappedView) -> (ViewIdentity, Bool)?) -> UnwrappedView? {
        var queue: [(isSingle: Bool, children: LazyGroup<UnwrappedView>)] = []
        queue.append((true, .init(count: 1, { _ in self })))
        while !queue.isEmpty {
            let (isSingle, children) = queue.remove(at: 0)
            for pair in children.enumerated() {
                let view = pair.element
                let index = (isSingle && pair.offset == 0) ? nil : pair.offset
                guard let (identity, result) = condition(view),
                      let instance = try? identity.builder(view.content, view.parentView, index)
                else { continue }
                if result {
                    return instance
                }
                if let descendants = try? identity.descendants(instance) {
                    let isSingle = (identity.viewType is SingleViewContent.Type) && descendants.count == 1
                    queue.append((isSingle, descendants))
                }
            }
        }
        return nil
    }
}

// MARK: - Index

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Traverse {
    
    static private(set) var index: [String: [ViewIdentity]] = {
        let identities: [ViewIdentity] = [
            .init(ViewType.AnyView.self), .init(ViewType.Group.self),
            .init(ViewType.Text.self), .init(ViewType.EmptyView.self),
            .init(ViewType.HStack.self),
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
        return nil
    }
}

// MARK: - ViewIdentity

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal typealias ViewIdentity = ViewType.Traverse.ViewIdentity

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Traverse {
    
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
extension ViewType.Traverse {
    
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
        let identities = ViewType.Traverse.modifierIdentities.filter({ identity -> Bool in
            modifierNames.contains(where: { $0.hasPrefix(identity.name) })
        })
        return .init(count: identities.count) { index -> UnwrappedView in
            try identities[index].builder(parent)
        }
    }
}
