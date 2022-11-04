import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - ViewWithBodyFromClosure

public protocol ViewWithBodyFromClosure {
    associatedtype Content
    var body: Content { get }
}

// MARK: - WithViewStore + ViewWithBodyFromClosure

extension WithViewStore: ViewWithBodyFromClosure { }

extension ViewType {
    public struct WithViewStore: KnownViewType {
        public static var typePrefix = "WithViewStore"
        public static var namespacedPrefixes: [String] {
            ["ComposableArchitecture"]
        }
    }
}

// MARK: - ViewType.WithViewStore + SingleViewContent

extension ViewType.WithViewStore: SingleViewContent {
    public static func child(_ content: Content) throws -> Content {
        print("=== WithViewStore.\(#function) ===")
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - ViewType.WithViewStore + MultipleViewContent

extension ViewType.WithViewStore: MultipleViewContent {
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        print("=== WithViewStore.\(#function) ===")
        return try Inspector.viewsInContainer(view: content.view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

extension InspectableView where View: SingleViewContent {
    public func withViewStore() throws -> InspectableView<ViewType.WithViewStore> {
        print("=== WithViewStore.\(#function) ===")
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

extension InspectableView where View: MultipleViewContent {
    public func withViewStore(
        _ index: Int) throws -> InspectableView<ViewType.WithViewStore>
    {
        print("=== WithViewStore.\(#function) - index: \(index) ===")

        let childWrapper = try child(at: index)
//        print("--- WithViewStore.\(#function) - index: \(index), childWrapper: \(childWrapper)")

//        print("--- WithViewStore.\(#function) - index: \(index), childWrapper.view: \(childWrapper.view)")

        guard let viewWithBodyFromClosure = childWrapper.view as? (any ViewWithBodyFromClosure)
        else { throw InspectionError.viewNotFound(parent: "WithViewStore") }

//        print(">-- --- --- --- -->")
//        print("--- WithViewStore.\(#function) - viewWithBodyFromClosure: \(viewWithBodyFromClosure)")
//        print(">-- --- --- --- -->")

        let content = Content(viewWithBodyFromClosure.body)
        return try .init(content, parent: self, index: index, usesContentFromClosure: true)
    }
}
