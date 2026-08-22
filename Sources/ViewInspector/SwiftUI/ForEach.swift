import SwiftUI
import UniformTypeIdentifiers.UTType

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ForEach: KnownViewType {
        public static let typePrefix: String = "ForEach"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ForEach: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let provider = try Inspector.cast(value: content.view, type: MultipleViewProvider.self)
        let children = try provider.views()
        return LazyGroup(count: children.count) { index in
            try Inspector.unwrap(view: try children.element(at: index),
                                 medium: content.medium.resettingViewModifiers())
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func forEach() throws -> InspectableView<ViewType.ForEach> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func forEach(_ index: Int) throws -> InspectableView<ViewType.ForEach> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - DynamicViewContent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.ForEach {
    
    func callOnDelete(_ indexSet: IndexSet) throws {
        typealias Closure = (IndexSet) -> Void
        let closure = try modifierAttribute(
            modifierName: "_TraitWritingModifier<OnDeleteTraitKey>",
            path: "modifier|value|some", type: Closure.self, call: "onDelete(perform:)")
        closure(indexSet)
    }
    
    func callOnMove(_ indexSet: IndexSet, _ index: Int) throws {
        typealias Closure = (IndexSet, Int) -> Void
        let closure = try modifierAttribute(
            modifierName: "_TraitWritingModifier<OnMoveTraitKey>",
            path: "modifier|value|some", type: Closure.self, call: "onMove(perform:)")
        closure(indexSet, index)
    }
    
    #if os(macOS)
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    func callOnInsert(of types: [UTType], _ index: Int, _ providers: [NSItemProvider]) throws {
        typealias Closure = (Int, [NSItemProvider]) -> Void
        let closure = try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType == "_TraitWritingModifier<OnInsertTraitKey>",
                  let typesValue = try? Inspector.attribute(
                    path: "modifier|value|some|supportedContentTypes", value: modifier, type: [UTType].self)
            else { return false }
            return typesValue == types
        }, path: "modifier|value|some|action", type: Closure.self,
        call: "onInsert(of: \(types.map({ $0.identifier })), perform:)")
        closure(index, providers)
    }
    #endif
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ForEach: MultipleViewProvider {
    
    func views() throws -> LazyGroup<Any> {
        
        typealias Builder = (Data.Element) -> Content
        let data = try Inspector
            .attribute(label: "data", value: self, type: Data.self)

        // `ForEach(subviews:)` and `ForEach(sections:)` store a collection that only the
        // SwiftUI rendering engine can enumerate - touching it here would crash. Both keep
        // a substitute view, `Group(subviews:)` or `Group(sections:)`, that is inspected instead.
        switch Inspector.typeName(value: data, generics: .remove) {
        case "ForEachSubviewCollection", "ForEachSectionCollection":
            // The substitute view is boxed in an `AnyView` that no one wrote in the
            // view hierarchy, so it is skipped to keep the inspection paths clean.
            let substituteView = try {
                if let unboxed = try? Inspector.attribute(
                    path: "substituteView|storage|view", value: data) {
                    return unboxed
                }
                return try Inspector.attribute(label: "substituteView", value: data)
            }()
            return LazyGroup(count: 1) { _ in substituteView }
        default:
            break
        }

        let builder = try Inspector
            .attribute(label: "content", value: self, type: Builder.self)
        
        return LazyGroup(count: data.count) { int in
            let index = data.index(data.startIndex, offsetBy: int)
            return builder(data[index])
        }
    }
}
