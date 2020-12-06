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
    
    internal func traverseIfNeeded<V>(content: Content, _ viewType: V.Type) throws -> Content {
        guard let traverseParams = content.view as? ViewType.Traverse.Params
        else { return content }
        return try traverseParams.search(for: viewType)
    }
}

// MARK: - Lookup

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Traverse.Params {
    func search<V>(for viewType: V.Type) throws -> Content {

        var unknownViews: [Any] = []
        guard let result = parent.breadthFirstSearch({ view in
            guard let identity = ViewType.Traverse.identify(view.content.view) else {
                unknownViews.append(view.content.view)
                return nil
            }
            return (identity, identity.viewType == viewType)
        }) else {
            let blockers = unknownViews.count == 0 ? "" :
                " Possible blockers: \(unknownViews.map({ Inspector.typeName(value: $0, prefixOnly: false) }))"
            throw InspectionError.notSupported(
                "Could not find view with type \(Inspector.typeName(type: viewType, prefixOnly: false))." + blockers)
        }
        return result.content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension UnwrappedView {
    func breadthFirstSearch(_ condition: (UnwrappedView) -> (ViewType.Traverse.ViewIdentity, Bool)?
    ) -> UnwrappedView? {
        var queue: [LazyGroup<UnwrappedView>] = []
        queue.append(.init(count: 1, { _ in self }))
        while !queue.isEmpty {
            let group = queue.remove(at: 0)
            for pair in group.enumerated() {
                let view = pair.element
                guard let (identity, result) = condition(view),
                      let instance = try? identity.builder(view.content, view.parentView, pair.offset)
                else { continue }
                if result {
                    return instance
                }
                if let descendants = try? identity.descendants(view) {
                    queue.append(descendants)
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
            .init(ViewType.Text.self), .init(ViewType.EmptyView.self)
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
    
    static func identify(_ view: Any) -> ViewIdentity? {
        let typePrefix = Inspector.typeName(value: view, prefixOnly: true)
        return index[String(typePrefix.prefix(1))]?
            .first(where: { $0.viewType.typePrefix == typePrefix })
    }
}

// MARK: - ViewIdentity

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Traverse {
    
    struct ViewIdentity {
        let viewType: KnownViewType.Type
        let builder: (Content, UnwrappedView?, Int?) throws -> UnwrappedView
        let descendants: (UnwrappedView) throws -> LazyGroup<UnwrappedView>
        
        private init<T>(_ type: T.Type,
                        descendants: @escaping (UnwrappedView) throws -> LazyGroup<UnwrappedView>
        ) where T: KnownViewType {
            viewType = type
            builder = { content, parent, index in
                try InspectableView<T>.init(content, parent: parent, index: index)
            }
            self.descendants = descendants
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType, T: SingleViewContent {
            self.init(type, descendants: { parent in
                let view = try T.child(parent.content)
                return .init(count: 1) { _ in
                    try InspectableView<ViewType.ClassifiedView>(
                        view, parent: parent, index: nil)
                }
            })
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType, T: MultipleViewContent {
            self.init(type, descendants: { parent in
                let viewes = try T.children(parent.content)
                return .init(count: viewes.count) { index in
                    try InspectableView<ViewType.ClassifiedView>(
                        try viewes.element(at: index), parent: parent, index: index)
                }
            })
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType, T: SingleViewContent, T: MultipleViewContent {
            self.init(type, descendants: { parent in
                let viewes = try T.children(parent.content)
                return .init(count: viewes.count) { index in
                    try InspectableView<ViewType.ClassifiedView>(
                        try viewes.element(at: index), parent: parent, index: index)
                }
            })
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType {
            self.init(type, descendants: { _ in .empty })
        }
    }
}
