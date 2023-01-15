import SwiftUI

// MARK: - Search namespace and types

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct ViewSearch {
    public enum Relation {
        case child
        case parent
    }
    public enum Traversal {
        case depthFirst
        case breadthFirst
    }
    public typealias Condition = (InspectableView<ViewType.ClassifiedView>) throws -> Bool
}

// MARK: - Public search API

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    /**
     Searches for a `Text` view containing the specified string

      - Parameter text: The string to look up for
      - Parameter locale: The locale for the string extraction.
     Defaults to `testsDefault` (i.e. `Locale(identifier: "en")`)
      - Throws: An error if the view cannot be found
      - Returns: A found `Text` view
     */
    func find(text: String,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.Text> {
        return try find(textWhere: { value, _ in value == text }, locale: locale)
    }
    
    /**
     Searches for a `Text` view matching a given condition, based on its string and attributes

      - Parameter textWhere: The condition closure for detecting a matching `Text`.
     Thrown errors are interpreted as "this view does not match"
      - Parameter locale: The locale for the string extraction.
     Defaults to `testsDefault` (i.e. `Locale(identifier: "en")`)
      - Throws: An error if the view cannot be found
      - Returns: A found `Text` view
     */
    func find(textWhere condition: (String, ViewType.Text.Attributes) throws -> Bool,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.Text> {
        return try find(ViewType.Text.self, where: {
            try condition(try $0.string(locale: locale), try $0.attributes())
        })
    }
    
    /**
     Searches for a `Button` view with matching title

      - Parameter button: The title to look up for
      - Parameter locale: The locale for the title extraction.
     Defaults to `testsDefault` (i.e. `Locale(identifier: "en")`)
      - Throws: An error if the view cannot be found
      - Returns: A found `Button` view
     */
    func find(button title: String,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.Button> {
        return try find(ViewType.Button.self, containing: title, locale: locale)
    }
    
    /**
     Searches for a `Link` view with matching `URL` parameter

      - Parameter link: The `URL` to look up for
      - Throws: An error if the view cannot be found
      - Returns: A found `Link` view
     */
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    func find(link url: URL) throws -> InspectableView<ViewType.Link> {
        return try find(ViewType.Link.self, where: { view in
            try view.url() == url
        })
    }
    
    /**
     Searches for a `Link` view with matching label parameter

      - Parameter link: The string to look up for as Link's label
      - Parameter locale: The locale for the label extraction.
     Defaults to `testsDefault` (i.e. `Locale(identifier: "en")`)
      - Throws: An error if the view cannot be found
      - Returns: A found `Link` view
     */
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    func find(link label: String,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.Link> {
        return try find(ViewType.Link.self, containing: label, locale: locale)
    }
    
    /**
     Searches for a `NavigationLink` view with matching label parameter

      - Parameter navigationLink: The string to look up for
      - Parameter locale: The locale for the label extraction.
     Defaults to `testsDefault` (i.e. `Locale(identifier: "en")`)
      - Throws: An error if the view cannot be found
      - Returns: A found `NavigationLink` view
     */
    func find(navigationLink string: String,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.NavigationLink> {
        return try find(ViewType.NavigationLink.self, containing: string, locale: locale)
    }
    
    /**
     Searches for a view with given `id`

      - Parameter viewWithId: The `id` to look up for
      - Throws: An error if the view cannot be found
      - Returns: A found view
     */
    func find(viewWithId id: AnyHashable) throws -> InspectableView<ViewType.ClassifiedView> {
        return try find { try $0.id() == id }
    }
    
    /**
     Searches for a view with given `tag`

      - Parameter viewWithTag: The `tag` to look up for
      - Throws: An error if the view cannot be found
      - Returns: A found view
     */
    func find(viewWithTag tag: AnyHashable) throws -> InspectableView<ViewType.ClassifiedView> {
        return try find { try $0.tag() == tag }
    }
    
    /**
     Searches for a view with given `accessibilityLabel`
     
     - Parameter viewWithAccessibilityLabel: The `accessibilityLabel` to look up for
     - Throws: An error if the view cannot be found
     - Returns: A found view
     */
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    func find(
        viewWithAccessibilityLabel accessibilityLabel: String
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        return try find { try $0.accessibilityLabel().string() == accessibilityLabel }
    }
    
    /**
     Searches for a view with given `accessibilityIdentifier`
     
     - Parameter viewWithAccessibilityIdentifier: The `accessibilityIdentifier` to look up for
     - Throws: An error if the view cannot be found
     - Returns: A found view
     */
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    func find(
        viewWithAccessibilityIdentifier accessibilityIdentifier: String
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        return try find { try $0.accessibilityIdentifier() == accessibilityIdentifier }
    }
    
    /**
     Searches for a view of a specific type that matches a given condition

      - Parameter customViewType: Your custom view type. For example: `ContentView.self`
      - Parameter relation: The direction of the search. Defaults to `.child`
      - Parameter where: The condition closure for detecting a matching view.
     Thrown errors are interpreted as "this view does not match"
      - Throws: An error if the view cannot be found
      - Returns: A found view
     */
    func find<V>(_ customViewType: V.Type,
                 relation: ViewSearch.Relation = .child,
                 where condition: (InspectableView<ViewType.View<V>>) throws -> Bool = { _ in true }
    ) throws -> InspectableView<ViewType.View<V>> where V: SwiftUI.View {
        guard !Inspector.isSystemType(type: customViewType) else {
            let name = Inspector.typeName(type: customViewType)
            throw InspectionError.notSupported(
                "Please use .find(ViewType.\(name).self) instead of .find(\(name).self) inspection call.")
        }
        return try find(ViewType.View<V>.self, relation: relation, where: condition)
    }
    
    /**
     Searches for a view of a specific type, which enclosed hierarchy contains a `Text` with the provided string

      - Parameter customViewType: Your custom view type. For example: `ContentView.self`
      - Parameter containing: The string to look up for
      - Parameter locale: The locale for the text extraction.
     Defaults to `testsDefault` (i.e. `Locale(identifier: "en")`)
      - Throws: An error if the view cannot be found
      - Returns: A found view
     */
    func find<V>(_ customViewType: V.Type,
                 containing string: String,
                 locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.View<V>> where V: SwiftUI.View {
        guard !Inspector.isSystemType(type: customViewType) else {
            let name = Inspector.typeName(type: customViewType)
            throw InspectionError.notSupported(
                "Please use .find(ViewType.\(name).self) instead of .find(\(name).self) inspection call.")
        }
        return try find(ViewType.View<V>.self, containing: string, locale: locale)
    }
    
    /**
     Searches for a view of a specific type, which enclosed hierarchy contains a `Text` with the provided string

      - Parameter viewType: The type of the view. For example: `ViewType.HStack.self`
      - Parameter containing: The string to look up for
      - Parameter locale: The locale for the text extraction.
     Defaults to `testsDefault` (i.e. `Locale(identifier: "en")`)
      - Throws: An error if the view cannot be found
      - Returns: A found view
     */
    func find<T>(_ viewType: T.Type,
                 containing string: String,
                 locale: Locale = .testsDefault
    ) throws -> InspectableView<T> where T: BaseViewType {
        return try find(ViewType.Text.self, where: { text in
            try text.string(locale: locale) == string
            && (try? text.find(T.self, relation: .parent)) != nil
        }).find(T.self, relation: .parent)
    }
    
    /**
     Searches for a view of a specific type that matches a given condition

      - Parameter viewType: The type of the view. For example: `ViewType.HStack.self`
      - Parameter relation: The direction of the search. Defaults to `.child`
      - Parameter traversal: The algorithm for view hierarchy traversal. Defaults to `.breadthFirst`
      - Parameter skipFound: How many matching views to skip. Defaults to `0`
      - Parameter where: The condition closure for detecting a matching view.
     Thrown errors are interpreted as "this view does not match"
      - Throws: An error if the view cannot be found
      - Returns: A found view of the given type.
     */
    func find<T>(_ viewType: T.Type,
                 relation: ViewSearch.Relation = .child,
                 traversal: ViewSearch.Traversal = .breadthFirst,
                 skipFound: Int = 0,
                 where condition: (InspectableView<T>) throws -> Bool = { _ in true }
    ) throws -> InspectableView<T> where T: BaseViewType {
        let view = try find(relation: relation, traversal: traversal, skipFound: skipFound, where: { view -> Bool in
            let typedView = try view.asInspectableView(ofType: T.self)
            return try condition(typedView)
        })
        return try view.asInspectableView(ofType: T.self)
    }
    
    /**
     Searches for a view that matches a given condition

      - Parameter relation: The direction of the search. Defaults to `.child`
      - Parameter traversal: The algorithm for view hierarchy traversal. Defaults to `.breadthFirst`
      - Parameter skipFound: How many matching views to skip. Defaults to `0`
      - Parameter where: The condition closure for detecting a matching view.
     Thrown errors are interpreted as "this view does not match"
      - Throws: An error if the view cannot be found
      - Returns: A found view of the given type.
     */
    func find(relation: ViewSearch.Relation = .child,
              traversal: ViewSearch.Traversal = .breadthFirst,
              skipFound: Int = 0,
              where condition: ViewSearch.Condition
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        precondition(skipFound >= 0)
        switch relation {
        case .child:
            return try findChild(condition: condition, traversal: traversal, skipFound: skipFound)
        case .parent:
            return try findParent(condition: condition, skipFound: skipFound)
        }
    }
    
    /**
     Searches for all the views of a specific type that match a given condition.
     The hierarchy is traversed in depth-first order, meaning that you'll get views
     ordered top-to-bottom as they appear in the code, regardless of their nesting depth.

      - Parameter customViewType: Your custom view type. For example: `ContentView.self`
      - Parameter where: The condition closure for detecting a matching view.
     Thrown errors are interpreted as "this view does not match"
      - Returns: An array of all matching views or an empty array if none are found.
     */
    func findAll<V>(_ customViewType: V.Type,
                    where condition: (InspectableView<ViewType.View<V>>) throws -> Bool = { _ in true }
    ) -> [InspectableView<ViewType.View<V>>] where V: SwiftUI.View {
        return findAll(ViewType.View<V>.self, where: condition)
    }
    
    /**
     Searches for all the views of a specific type that match a given condition.
     The hierarchy is traversed in depth-first order, meaning that you'll get views
     ordered top-to-bottom as they appear in the code, regardless of their nesting depth.

      - Parameter viewType: The type of the view. For example: `ViewType.HStack.self`
      - Parameter where: The condition closure for detecting a matching view.
     Thrown errors are interpreted as "this view does not match"
      - Returns: An array of all matching views or an empty array if none are found.
     */
    func findAll<T>(_ viewType: T.Type,
                    where condition: (InspectableView<T>) throws -> Bool = { _ in true }
    ) -> [InspectableView<T>] where T: BaseViewType {
        return findAll(where: { view in
            guard let typedView = try? view.asInspectableView(ofType: T.self)
            else { return false }
            return try condition(typedView)
        }).compactMap({ try? $0.asInspectableView(ofType: T.self) })
    }
    
    /**
     Searches for all the views that match a given condition.
     The hierarchy is traversed in depth-first order, meaning that you'll get views
     ordered top-to-bottom as they appear in the code, regardless of their nesting depth.

      - Parameter where: The condition closure for detecting a matching view.
     Thrown errors are interpreted as "this view does not match"
      - Returns: An array of all matching views or an empty array if none are found.
     */
    func findAll(where condition: ViewSearch.Condition) -> [InspectableView<ViewType.ClassifiedView>] {
        var results: [InspectableView<ViewType.ClassifiedView>] = []
        depthFirstTraversal(condition, stopOnFoundMatch: { view in
            if let view = try? view.asInspectableView() {
                results.append(view)
            }
            return false
        }, identificationFailure: { _ in })
        return results
    }
}

// MARK: - Search

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension UnwrappedView {
    
    func findParent(condition: ViewSearch.Condition, skipFound: Int
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        var current = parentView
        var counter = skipFound + 1
        while let parent = try? current?.asInspectableView() {
            if (try? condition(parent)) == true {
                counter -= 1
            }
            if counter == 0 {
                return parent
            }
            current = parent.parentView
        }
        throw InspectionError.searchFailure(skipped: skipFound + 1 - counter, blockers: [])
    }
    
    func findChild(condition: ViewSearch.Condition,
                   traversal: ViewSearch.Traversal,
                   skipFound: Int
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        var unknownViews: [Any] = []
        var result: UnwrappedView?
        var counter = skipFound + 1
        traversal.search(in: self, condition: condition, stopOnFoundMatch: { view -> Bool in
            counter -= 1
            if counter == 0 {
                result = view
                return true
            }
            return false
        }, identificationFailure: { content in
            unknownViews.append(content.view)
        })
        if let result = result {
            return try result.asInspectableView()
        }
        let blockers = blockersDescription(unknownViews)
        throw InspectionError.searchFailure(skipped: skipFound + 1 - counter, blockers: blockers)
    }
    
    func blockersDescription(_ views: [Any]) -> [String] {
        return views.map { view -> String in
            let name = Inspector.typeName(value: view)
            if name.hasPrefix("EnvironmentReaderView") {
                return "navigationBarItems"
            }
            if name.hasPrefix(ViewType.Popover.standardModifierName) {
                return "popover"
            }
            if !Inspector.isSystemType(value: view) {
                let missingObjects = EnvironmentInjection.missingEnvironmentObjects(for: view)
                if missingObjects.count > 0 {
                    return InspectionError
                        .missingEnvironmentObjects(view: name, objects: missingObjects)
                        .localizedDescription
                }
            }
            return name
        }
    }
    
    func breadthFirstTraversal(_ condition: ViewSearch.Condition,
                               stopOnFoundMatch: (UnwrappedView) -> Bool,
                               identificationFailure: (Content) -> Void) {
        var queue: [(isSingle: Bool, children: LazyGroup<UnwrappedView>)] = []
        queue.append((true, .init(count: 1, { _ in self })))
        while !queue.isEmpty {
            let (isSingle, children) = queue.remove(at: 0)
            for offset in 0..<children.count {
                guard let view = try? children.element(at: offset),
                      view.recursionAbsenceCheck()
                else { continue }
                let viewIndex = view.inspectionIndex ?? 0
                let index = isSingle && viewIndex == 0 ? nil : viewIndex
                guard let (identity, instance) = ViewSearch
                        .identifyAndInstantiate(view, index: index)
                else {
                    if (try? condition(try view.asInspectableView())) == true,
                       stopOnFoundMatch(view) {
                        return
                    }
                    identificationFailure(view.content)
                    continue
                }
                if (try? condition(try instance.asInspectableView())) == true,
                   stopOnFoundMatch(instance) {
                    return
                }
                if let descendants = try? identity.children(instance),
                   descendants.count > 0 {
                    let isSingle = (identity.viewType is SingleViewContent.Type) && descendants.count == 1
                    queue.append((isSingle, descendants))
                }
                if let descendants = try? identity.modifiers(instance),
                   descendants.count > 0 {
                    queue.append((true, descendants))
                }
                if let descendants = try? identity.supplementary(instance),
                   descendants.count > 0 {
                    queue.append((true, descendants))
                }
            }
        }
    }
    
    func depthFirstTraversal(_ condition: ViewSearch.Condition,
                             stopOnFoundMatch: (UnwrappedView) -> Bool,
                             identificationFailure: (Content) -> Void) {
        var shouldContinue: Bool = true
        depthFirstRecursion(shouldContinue: &shouldContinue, isSingle: true, offset: 0,
                            condition: condition, stopOnFoundMatch: stopOnFoundMatch,
                            identificationFailure: identificationFailure)
    }
    
    func depthFirstRecursion(shouldContinue: inout Bool,
                             isSingle: Bool, offset: Int,
                             condition: ViewSearch.Condition,
                             stopOnFoundMatch: (UnwrappedView) -> Bool,
                             identificationFailure: (Content) -> Void) {
        if (try? condition(try self.asInspectableView())) == true,
           stopOnFoundMatch(self) {
            shouldContinue = false
        }
        guard shouldContinue, recursionAbsenceCheck() else { return }
        
        let index = isSingle ? nil : offset
        
        guard let (identity, instance) = ViewSearch
                .identifyAndInstantiate(self, index: index) else {
            identificationFailure(self.content)
            return
        }
        guard let descendants = try? identity.allDescendants(instance)
        else { return }
        
        let isSingle = (identity.viewType is SingleViewContent.Type)
            && descendants.count == 1
        
        for offset in 0..<descendants.count {
            guard let descendant = try? descendants.element(at: offset) else { continue }
            descendant.depthFirstRecursion(
                shouldContinue: &shouldContinue, isSingle: isSingle, offset: offset,
                condition: condition, stopOnFoundMatch: stopOnFoundMatch,
                identificationFailure: identificationFailure)
            guard shouldContinue else { return }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension UnwrappedView {
    func recursionAbsenceCheck() -> Bool {
        guard content.isCustomView else { return true }
        let typeRef = type(of: content.view)
        var isDirectParent = true
        return (try? findParent(condition: { parent in
            defer { isDirectParent = false }
            return typeRef == type(of: parent.content.view) && !isDirectParent
        }, skipFound: 0)) == nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension ViewSearch.Traversal {
    func search(in view: UnwrappedView,
                condition: ViewSearch.Condition,
                stopOnFoundMatch: (UnwrappedView) -> Bool,
                identificationFailure: (Content) -> Void) {
        switch self {
        case .breadthFirst:
            view.breadthFirstTraversal(condition, stopOnFoundMatch: stopOnFoundMatch,
                                       identificationFailure: identificationFailure)
        case .depthFirst:
            view.depthFirstTraversal(condition, stopOnFoundMatch: stopOnFoundMatch,
                                     identificationFailure: identificationFailure)
        }
    }
}
