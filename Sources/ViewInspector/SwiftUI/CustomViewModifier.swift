import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct ViewModifier<T>: KnownViewType, CustomViewType {
        
        public static var typePrefix: String { "" }
        
        public static var namespacedPrefixes: [String] { [] }
        
        public static func inspectionCall(typeName: String) -> String {
            return "modifier(\(typeName).self\(ViewType.commaPlaceholder)\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func modifier<T>(_ type: T.Type, _ index: Int? = nil) throws -> InspectableView<ViewType.ViewModifier<T>>
    where T: ViewModifier {
        let name = Inspector.typeName(type: type)
        guard let view = content.medium.viewModifiers.reversed().compactMap({ modifier in
            try? Inspector.attribute(label: "modifier", value: modifier, type: type)
        }).dropFirst(index ?? 0).first else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: content.view),
                modifier: name, index: index ?? 0)
        }
        let medium = content.medium.resettingViewModifiers()
        let modifierContent = try Inspector.unwrap(view: view, medium: medium)
        let base = ViewType.ViewModifier<T>.inspectionCall(typeName: name)
        let call = ViewType.inspectionCall(base: base, index: index)
        return try .init(modifierContent, parent: self, call: call)
    }
}

// MARK: - Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ViewModifier: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        if content.isCustomView {
            return try content.extractCustomView()
        }
        return try content.unwrappedModifiedContent()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ViewModifier: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try content.extractCustomViewGroup()
    }
}

// MARK: - Internal

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    func unwrappedModifiedContent() throws -> Content {
        let view = try Inspector.attribute(label: "content", value: self.view)
        var medium: Content.Medium
        if let modifier = self.view as? EnvironmentModifier,
           modifier.qualifiesAsEnvironmentModifier() {
            if let value = try? modifier.value(),
               let object = try? Inspector.attribute(label: "some", value: value, type: AnyObject.self),
               object is any ObservableObject {
                medium = self.medium.appending(environmentObject: object)
            } else {
                medium = self.medium.appending(environmentModifier: modifier)
            }
        } else if let modifier = self.view as? PossiblyTransitiveModifier,
                  modifier.isTransitive() {
            medium = self.medium.appending(transitiveViewModifier: modifier)
        } else {
            medium = self.medium.appending(viewModifier: self.view)
            if let modifier = (self.view as? ModifierNameProvider)?.customModifier,
               let modifierBodyContent = try? Content(modifier, medium: self.medium).extractCustomView(),
               let modifierBodyView = try? InspectableView<ViewType.ClassifiedView>(modifierBodyContent, parent: nil),
               let viewModifierContent = try? modifierBodyView.find(ViewType.ViewModifierContent.self) {
                let overlayModifiers = Set(ViewSearch.modifierIdentities.map({ $0.name }))
                viewModifierContent.content.medium.viewModifiers
                    .filter { modifier in
                        return (modifier as? ModifierNameProvider)
                            .map { $0.modifierType(prefixOnly: true) }
                            .map { !overlayModifiers.contains($0) } ?? true
                    }
                    .forEach {
                        medium = medium.appending(viewModifier: $0)
                    }
                viewModifierContent.content.medium.transitiveViewModifiers.forEach {
                    medium = medium.appending(transitiveViewModifier: $0)
                }
                viewModifierContent.content.medium.environmentModifiers.forEach {
                    medium = medium.appending(environmentModifier: $0)
                }
                viewModifierContent.content.medium.environmentObjects.forEach {
                    medium = medium.appending(environmentObject: $0)
                }
            }
        }
        return try Inspector.unwrap(view: view, medium: medium)
    }

    func customViewModifiers() -> [Any] {
        return medium.viewModifiers.reversed()
            .compactMap { try? Inspector.attribute(label: "modifier", value: $0) }
            .filter { !Inspector.isSystemType(value: $0) }
    }
}

// MARK: - ViewModifier content

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ViewModifierContent: KnownViewType {
        public static var typePrefix: String = "_ViewModifier_Content"
        
        public static func inspectionCall(typeName: String) -> String {
            return "viewModifierContent(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func viewModifierContent() throws -> InspectableView<ViewType.ViewModifierContent> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func viewModifierContent(_ index: Int) throws -> InspectableView<ViewType.ViewModifierContent> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - ViewModifier content allocation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension _ViewModifier_Content {
    private struct Allocator { }
    init() {
        self = unsafeBitCast(Allocator(), to: Self.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewModifier {
    func body() -> Any {
        body(content: .init())
    }
}
