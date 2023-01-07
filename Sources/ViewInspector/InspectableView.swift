import SwiftUI
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct InspectableView<View> where View: BaseViewType {
    
    internal let content: Content
    internal let parentView: UnwrappedView?
    internal let inspectionCall: String
    internal let inspectionIndex: Int?
    internal var isUnwrappedSupplementaryChild: Bool = false
    
    internal init(_ content: Content, parent: UnwrappedView?,
                  call: String = #function, index: Int? = nil) throws {
        let parentView: UnwrappedView? = (parent is InspectableView<ViewType.ParentView>)
            ? parent?.parentView : parent
        let inspectionCall = index
            .flatMap({ call.replacingOccurrences(of: "_:", with: "\($0)") }) ?? call
        self = try Self.build(content: content, parent: parentView, call: inspectionCall, index: index)
    }
    
    private static func build(content: Content, parent: UnwrappedView?, call: String, index: Int?) throws -> Self {
        if !View.typePrefix.isEmpty,
           Inspector.isTupleView(content.view),
           View.self != ViewType.TupleView.self {
            throw InspectionError.notSupported(
                "Unable to extract \(View.typePrefix): please specify its index inside parent view")
        }
        do {
            try Inspector.guardType(value: content.view,
                                    namespacedPrefixes: View.namespacedPrefixes,
                                    inspectionCall: call)
        } catch {
            if let err = error as? InspectionError, case .typeMismatch = err {
                if let child = try? implicitCustomViewChild(
                    parent: parent, call: call, index: index) {
                    return child
                }
                let factual = Inspector.typeName(value: content.view, namespaced: true)
                    .removingSwiftUINamespace()
                let expected = View.namespacedPrefixes
                    .map { $0.removingSwiftUINamespace() }
                    .joined(separator: " or ")
                let pathToRoot = Self.init(content: content, parent: parent, call: call, index: index)
                    .pathToRoot
                throw InspectionError.inspection(path: pathToRoot, factual: factual, expected: expected)
            }
            throw error
        }
        return Self.init(content: content, parent: parent, call: call, index: index)
    }
    
    private init(content: Content, parent: UnwrappedView?, call: String, index: Int?) {
        self.content = content
        self.parentView = parent
        self.inspectionCall = call
        self.inspectionIndex = index
    }
    
    private static func implicitCustomViewChild(parent: UnwrappedView?, call: String, index: Int?) throws -> Self? {
        guard let (content, parent) = try parent?.implicitCustomViewChild(index: index ?? 0, call: call)
        else { return nil }
        return try build(content: content, parent: parent, call: call, index: index)
    }
    
    fileprivate func withCustomViewInspectionCall() -> Self {
        let customViewType = Inspector.typeName(value: content.view, namespaced: false)
        let call = "view(\(customViewType).self)"
        return .init(content: content, parent: parentView, call: call, index: inspectionIndex)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension UnwrappedView {
    func implicitCustomViewChild(index: Int, call: String) throws
    -> (content: Content, parent: InspectableView<ViewType.View<ViewType.Stub>>)? {
        guard let parent = self as? InspectableView<ViewType.ClassifiedView>,
              !Inspector.isSystemType(value: parent.content.view),
              !(parent.content.view is AbsentView),
              let customViewParent = try? parent
                .asInspectableView(ofType: ViewType.View<ViewType.Stub>.self)
        else { return nil }
        let child = try customViewParent.child(at: index)
        let updatedParent = customViewParent.withCustomViewInspectionCall()
        return (child, updatedParent)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol UnwrappedView {
    var content: Content { get }
    var parentView: UnwrappedView? { get }
    var inspectionCall: String { get }
    var inspectionIndex: Int? { get }
    var pathToRoot: String { get }
    var isTransitive: Bool { get }
    var isUnwrappedSupplementaryChild: Bool { get set }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView: UnwrappedView {
    var isTransitive: Bool { View.isTransitive }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension UnwrappedView {
    func asInspectableView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try .init(content, parent: parentView, call: inspectionCall, index: inspectionIndex)
    }
    
    func asInspectableView<T>(ofType type: T.Type) throws -> InspectableView<T> where T: BaseViewType {
        return try .init(content, parent: parentView, call: inspectionCall, index: inspectionIndex)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView {
    func asInspectableView<T>(ofType type: T.Type) throws -> InspectableView<T> where T: BaseViewType {
        return try .init(content, parent: parentView, call: inspectionCall, index: inspectionIndex)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    /**
      A function for accessing the parent view for introspection
      - Returns: immediate predecessor of the current view in the hierarchy
      - Throws: if the current view is the root
     */
    func parent() throws -> InspectableView<ViewType.ParentView> {
        guard let parent = self.parentView else {
            throw InspectionError.parentViewNotFound(view: Inspector.typeName(value: content.view))
        }
        if parent.parentView == nil,
           parent is InspectableView<ViewType.ClassifiedView>,
           Inspector.typeName(value: parent.content.view, namespaced: true)
            == Inspector.typeName(value: content.view, namespaced: true) {
            throw InspectionError.parentViewNotFound(view: Inspector.typeName(value: content.view))
        }
        return try .init(parent.content, parent: parent.parentView, call: parent.inspectionCall)
    }
    
    /**
      A property for obtaining the inspection call's chain from the root view to the current view
      - Returns: A `String` representation of the inspection calls' chain
     */
    var pathToRoot: String {
        let prefix = parentView.flatMap { $0.pathToRoot } ?? ""
        return prefix.isEmpty ? inspectionCall : prefix + "." + inspectionCall
    }
    
    /**
      A function for erasing the type of the current view
      - Returns: The current view represented as a `ClassifiedView`
     */
    func classified() throws -> InspectableView<ViewType.ClassifiedView> {
        return try asInspectableView()
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
            if let unwrapped = try Self.implicitCustomViewChild(
                parent: self, call: inspectionCall, index: index) {
                return unwrapped.content
            }
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

// MARK: - Inspection of a Custom View

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View {
    
    func inspect(function: String = #function) throws -> InspectableView<ViewType.ClassifiedView> {
        let medium = ViewHosting.medium(function: function)
        let content = try Inspector.unwrap(view: self, medium: medium)
        return try .init(content, parent: nil, call: "")
    }
    
    func inspect(function: String = #function, file: StaticString = #file, line: UInt = #line,
                 inspection: (InspectableView<ViewType.View<Self>>) throws -> Void) {
        do {
            let view = try inspect(function: function)
                .asInspectableView(ofType: ViewType.View<Self>.self)
            try inspection(view)
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}

// MARK: - Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier {
    
    func inspect(function: String = #function) throws -> InspectableView<ViewType.ViewModifier<Self>> {
        let medium = ViewHosting.medium(function: function)
        let content = try Inspector.unwrap(view: self, medium: medium)
        return try .init(content, parent: nil, call: "")
    }
    
    func inspect(function: String = #function, file: StaticString = #file, line: UInt = #line,
                 inspection: (InspectableView<ViewType.ViewModifier<Self>>) throws -> Void) {
        do {
            try inspection(try inspect(function: function))
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView {

    func modifierAttribute<Type>(
        modifierName: String, transitive: Bool = false,
        path: String, type: Type.Type, call: String, index: Int = 0
    ) throws -> Type {
        return try contentForModifierLookup.modifierAttribute(
            modifierName: modifierName, transitive: transitive,
            path: path, type: type, call: call, index: index)
    }
    
    func modifierAttribute<Type>(
        modifierLookup: (ModifierNameProvider) -> Bool, transitive: Bool = false,
        path: String, type: Type.Type, call: String
    ) throws -> Type {
        return try contentForModifierLookup.modifierAttribute(
            modifierLookup: modifierLookup, transitive: transitive, path: path, type: type, call: call)
    }
    
    func modifier(
        _ modifierLookup: (ModifierNameProvider) -> Bool,
        transitive: Bool = false, call: String
    ) throws -> Any {
        return try contentForModifierLookup.modifier(
            modifierLookup, transitive: transitive, call: call)
    }
    
    func modifiersMatching(_ modifierLookup: (ModifierNameProvider) -> Bool,
                           transitive: Bool = false
    ) -> [ModifierNameProvider] {
        return contentForModifierLookup
            .modifiersMatching(modifierLookup, transitive: transitive)
    }
    
    var contentForModifierLookup: Content {
        if self is InspectableView<ViewType.ParentView>, let parent = parentView {
            return parent.content
        }
        return content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    typealias ModifierLookupClosure = (ModifierNameProvider) -> Bool

    func modifierAttribute<Type>(
        modifierName: String, transitive: Bool = false,
        path: String, type: Type.Type, call: String, index: Int = 0
    ) throws -> Type {
        let modifyNameProvider: ModifierLookupClosure = { modifier -> Bool in
            guard modifier.modifierType.contains(modifierName) else { return false }
            return (try? Inspector.attribute(path: path, value: modifier) as? Type) != nil
        }
        return try modifierAttribute(
            modifierLookup: modifyNameProvider, transitive: transitive,
            path: path, type: type, call: call, index: index)
    }
    
    func modifierAttribute<Type>(
        modifierLookup: ModifierLookupClosure, transitive: Bool = false,
        path: String, type: Type.Type, call: String, index: Int = 0
    ) throws -> Type {
        let modifier = try self.modifier(modifierLookup, transitive: transitive, call: call, index: index)
        guard let attribute = try? Inspector.attribute(path: path, value: modifier) as? Type
        else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: self.view), modifier: call, index: index)
        }
        return attribute
    }

    func modifier(_ modifierLookup: ModifierLookupClosure, transitive: Bool = false,
                  call: String, index: Int = 0) throws -> Any {
        let modifiers = modifiersMatching(modifierLookup, transitive: transitive)
        if index < modifiers.count {
            return modifiers[index]
        }
        throw InspectionError.modifierNotFound(
            parent: Inspector.typeName(value: self.view), modifier: call, index: index)
    }
    
    func modifiersMatching(_ modifierLookup: ModifierLookupClosure,
                           transitive: Bool = false) -> [ModifierNameProvider] {
        let modifiers = transitive ? medium.transitiveViewModifiers
            : medium.viewModifiers.reversed()
        return modifiers.lazy
            .compactMap { $0 as? ModifierNameProvider }
            .filter(modifierLookup)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol ModifierNameProvider {
    var modifierType: String { get }
    func modifierType(prefixOnly: Bool) -> String
    var customModifier: Any? { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ModifierNameProvider {
    var modifierType: String { modifierType(prefixOnly: false) }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ModifiedContent: ModifierNameProvider {
    
    func modifierType(prefixOnly: Bool) -> String {
        return Inspector.typeName(type: Modifier.self, generics: prefixOnly ? .remove : .keep)
    }
    
    var customModifier: Any? {
        guard let modifier = try? Inspector.attribute(label: "modifier", value: self),
              !Inspector.isSystemType(value: modifier)
        else { return nil }
        return modifier
    }
}

// MARK: - isResponsive check for controls

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    /**
     A function to check if the view is responsive to the user's touch input.
     Returns `false` if the view or any of its parent views are `disabled`,
     `hidden`, or if `allowsHitTesting` is set to `false`.

      - Returns: `true` if the view is responsive to the user's interaction
     */
    func isResponsive() -> Bool {
        do {
            try guardIsResponsive()
            return true
        } catch {
            return false
        }
    }
    
    internal func guardIsResponsive() throws {
        let name = Inspector.typeName(value: content.view, generics: .remove)
        if isDisabled() {
            let blocker = farthestParent(where: { $0.isDisabled() }) ?? self
            throw InspectionError.unresponsiveControl(
                name: name, reason: blocker.pathToRoot.ifEmpty(use: "it") + " is disabled")
        }
        if isHidden() {
            let blocker = farthestParent(where: { $0.isHidden() }) ?? self
            throw InspectionError.unresponsiveControl(
                name: name, reason: blocker.pathToRoot.ifEmpty(use: "it") + " is hidden")
        }
        if !allowsHitTesting() {
            let blocker = farthestParent(where: { !$0.allowsHitTesting() }) ?? self
            throw InspectionError.unresponsiveControl(
                name: name, reason: blocker.pathToRoot.ifEmpty(use: "it") + " has allowsHitTesting set to false")
        }
        if isAbsent {
            throw InspectionError.unresponsiveControl(name: name, reason: "the conditional view has been hidden")
        }
    }
    
    private func farthestParent(where condition: (InspectableView<ViewType.ClassifiedView>) -> Bool) -> UnwrappedView? {
        if let parent = try? self.parentView?.asInspectableView(),
           condition(parent) {
            return parent.farthestParent(where: condition) ?? parent
        }
        return nil
    }
}

private extension String {
    func ifEmpty(use replacement: String) -> String {
        return isEmpty ? replacement : self
    }
}
