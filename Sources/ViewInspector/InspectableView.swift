import SwiftUI
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct InspectableView<View> where View: KnownViewType {
    
    internal let content: Content
    internal let parentView: UnwrappedView?
    internal let inspectionCall: String
    internal let inspectionIndex: Int?
    
    internal init(_ content: Content, parent: UnwrappedView?,
                  call: String = #function, index: Int? = nil) throws {
        let parentView: UnwrappedView? = (parent is InspectableView<ViewType.ParentView>)
            ? parent?.parentView : parent
        let inspectionCall = index
            .flatMap({ call.replacingOccurrences(of: "_:", with: "\($0)") }) ?? call
        try self.init(content: content, parent: parentView, call: inspectionCall, index: index)
    }
    
    private init(content: Content, parent: UnwrappedView?, call: String, index: Int?) throws {
        if !View.typePrefix.isEmpty,
           Inspector.isTupleView(content.view),
           View.self != ViewType.TupleView.self {
            throw InspectionError.notSupported(
                "Unable to extract \(View.typePrefix): please specify its index inside parent view")
        }
        self.content = content
        self.parentView = parent
        self.inspectionCall = call
        self.inspectionIndex = index
        do {
            try Inspector.guardType(value: content.view,
                                    namespacedPrefixes: View.namespacedPrefixes,
                                    inspectionCall: inspectionCall)
        } catch {
            if let err = error as? InspectionError, case .typeMismatch = err {
                let factual = Inspector.typeName(value: content.view, namespaced: true, prefixOnly: true)
                    .sanitizeNamespace()
                let expected = View.namespacedPrefixes
                    .map { $0.sanitizeNamespace() }
                    .joined(separator: " or ")
                throw InspectionError.inspection(path: pathToRoot, factual: factual, expected: expected)
            }
            throw error
        }
    }
}

private extension String {
    func sanitizeNamespace() -> String {
        var str = self
        if let range = str.range(of: ".(unknown context at ") {
            let end = str.index(range.upperBound, offsetBy: .init(11))
            str.replaceSubrange(range.lowerBound..<end, with: "")
        }
        return str.replacingOccurrences(of: "SwiftUI.", with: "")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol UnwrappedView {
    var content: Content { get }
    var parentView: UnwrappedView? { get }
    var inspectionCall: String { get }
    var inspectionIndex: Int? { get }
    var pathToRoot: String { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectableView: UnwrappedView { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension UnwrappedView {
    func asInspectableView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try .init(content, parent: parentView, call: inspectionCall, index: inspectionIndex)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView {
    func asInspectableView<T>(ofType type: T.Type) throws -> InspectableView<T> where T: KnownViewType {
        return try .init(content, parent: parentView, call: inspectionCall, index: inspectionIndex)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
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
    
    var pathToRoot: String {
        let prefix = parentView.flatMap { $0.pathToRoot } ?? ""
        return prefix.isEmpty ? inspectionCall : prefix + "." + inspectionCall
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

// MARK: - Inspection of a Custom View

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View {
    func inspect(function: String = #function) throws -> InspectableView<ViewType.ClassifiedView> {
        let medium = ViewHosting.medium(function: function)
        let content = try Inspector.unwrap(view: self, medium: medium)
        return try .init(content, parent: nil, call: "")
    }
    
    func inspect(function: String = #function, file: StaticString = #file, line: UInt = #line,
                 inspection: (InspectableView<ViewType.ClassifiedView>) throws -> Void) {
        do {
            try inspection(try inspect(function: function))
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View where Self: Inspectable {
    
    func inspect(function: String = #function) throws -> InspectableView<ViewType.View<Self>> {
        let call = "view(\(ViewType.View<Self>.typePrefix).self)"
        let medium = ViewHosting.medium(function: function)
        let content = Content(self, medium: medium)
        return try .init(content, parent: nil, call: call)
    }
    
    func inspect(function: String = #function, file: StaticString = #file, line: UInt = #line,
                 inspection: (InspectableView<ViewType.View<Self>>) throws -> Void) {
        do {
            try inspection(try inspect(function: function))
        } catch {
            XCTFail("\(error.localizedDescription)", file: file, line: line)
        }
    }
}

// MARK: - Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView {

    func numberModifierAttributes(modifierName: String, path: String, call: String) -> Int {
        return contentForModifierLookup.numberModifierAttributes(modifierName: modifierName, path: path, call: call)
    }

    func modifierAttribute<Type>(modifierName: String, path: String,
                                 type: Type.Type, call: String, index: Int = 0) throws -> Type {
        return try contentForModifierLookup.modifierAttribute(
            modifierName: modifierName, path: path, type: type, call: call, index: index)
    }
    
    func modifierAttribute<Type>(modifierLookup: (ModifierNameProvider) -> Bool, path: String,
                                 type: Type.Type, call: String) throws -> Type {
        return try contentForModifierLookup.modifierAttribute(
            modifierLookup: modifierLookup, path: path, type: type, call: call)
    }
    
    func modifier(_ modifierLookup: (ModifierNameProvider) -> Bool, call: String) throws -> Any {
        return try contentForModifierLookup.modifier(modifierLookup, call: call)
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

    func numberModifierAttributes(modifierName: String, path: String, call: String) -> Int {
        let modifyNameProvider: ModifierLookupClosure = { modifier -> Bool in
            guard modifier.modifierType.contains(modifierName) else {
                return false
            }
            return true
        }
        let modifiers = medium.viewModifiers.lazy
            .compactMap({ $0 as? ModifierNameProvider })
            .filter(modifyNameProvider)

        return modifiers.count
    }

    func modifierAttribute<Type>(modifierName: String, path: String,
                                 type: Type.Type, call: String, index: Int = 0) throws -> Type {
        let modifyNameProvider: ModifierLookupClosure = { modifier -> Bool in
            guard modifier.modifierType.contains(modifierName) else { return false }
            return (try? Inspector.attribute(path: path, value: modifier) as? Type) != nil
        }
        return try modifierAttribute(modifierLookup: modifyNameProvider, path: path,
                                     type: type, call: call, index: index)
    }
    
    func modifierAttribute<Type>(modifierLookup: ModifierLookupClosure, path: String,
                                 type: Type.Type, call: String, index: Int = 0) throws -> Type {
        let modifier = try self.modifier(modifierLookup, call: call, index: index)
        guard let attribute = try? Inspector.attribute(path: path, value: modifier) as? Type
        else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: self.view), modifier: call)
        }
        return attribute
    }

    func modifier(_ modifierLookup: ModifierLookupClosure, call: String, index: Int = 0) throws -> Any {
        let modifiers = medium.viewModifiers.lazy
            .compactMap({ $0 as? ModifierNameProvider })
            .filter(modifierLookup)

        if index < modifiers.count {
            return modifiers[index]
        }
        throw InspectionError.modifierNotFound(
            parent: Inspector.typeName(value: self.view), modifier: call)

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
