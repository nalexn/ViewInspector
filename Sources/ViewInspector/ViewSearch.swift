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
    
    func find(text: String,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.Text> {
        return try find(textWhere: { value, _ in value == text }, locale: locale)
    }
    
    func find(textWhere condition: (String, ViewType.Text.Attributes) throws -> Bool,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.Text> {
        return try find(ViewType.Text.self, where: {
            try condition(try $0.string(locale: locale), try $0.attributes())
        })
    }
    
    func find(button title: String,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.Button> {
        return try find(ViewType.Button.self, containing: title, locale: locale)
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    func find(link url: URL) throws -> InspectableView<ViewType.Link> {
        return try find(ViewType.Link.self, where: { view in
            try view.url() == url
        })
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    func find(link label: String,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.Link> {
        return try find(ViewType.Link.self, containing: label, locale: locale)
    }
    
    func find(navigationLink string: String,
              locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.NavigationLink> {
        return try find(ViewType.NavigationLink.self, containing: string, locale: locale)
    }
    
    func find(viewWithId id: AnyHashable) throws -> InspectableView<ViewType.ClassifiedView> {
        return try find { try $0.id() == id }
    }
    
    func find(viewWithTag tag: AnyHashable) throws -> InspectableView<ViewType.ClassifiedView> {
        return try find { try $0.tag() == tag }
    }
    
    func find<V>(_ inspectable: V.Type,
                 relation: ViewSearch.Relation = .child,
                 where condition: (InspectableView<ViewType.View<V>>) throws -> Bool = { _ in true }
    ) throws -> InspectableView<ViewType.View<V>> where V: Inspectable {
        return try find(ViewType.View<V>.self, relation: relation, where: condition)
    }
    
    func find<V>(_ inspectable: V.Type,
                 containing string: String,
                 locale: Locale = .testsDefault
    ) throws -> InspectableView<ViewType.View<V>> {
        return try find(ViewType.View<V>.self, containing: string, locale: locale)
    }
    
    func find<T>(_ viewType: T.Type,
                 containing string: String,
                 locale: Locale = .testsDefault
    ) throws -> InspectableView<T> {
        return try find(ViewType.Text.self, where: { text in
            try text.string(locale: locale) == string
            && (try? text.find(T.self, relation: .parent)) != nil
        }).find(T.self, relation: .parent)
    }
    
    func find<T>(_ viewType: T.Type,
                 relation: ViewSearch.Relation = .child,
                 traversal: ViewSearch.Traversal = .breadthFirst,
                 skipFound: Int = 0,
                 where condition: (InspectableView<T>) throws -> Bool = { _ in true }
    ) throws -> InspectableView<T> where T: KnownViewType {
        let view = try find(relation: relation, traversal: traversal, skipFound: skipFound, where: { view -> Bool in
            let typedView = try view.asInspectableView(ofType: T.self)
            return try condition(typedView)
        })
        return try view.asInspectableView(ofType: T.self)
    }
    
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
    
    func findAll<V>(_ inspectable: V.Type,
                    where condition: (InspectableView<ViewType.View<V>>) throws -> Bool = { _ in true }
    ) -> [InspectableView<ViewType.View<V>>] where V: Inspectable {
        return findAll(ViewType.View<V>.self, where: condition)
    }
    
    func findAll<T>(_ viewType: T.Type,
                    where condition: (InspectableView<T>) throws -> Bool = { _ in true }
    ) -> [InspectableView<T>] where T: KnownViewType {
        return findAll(where: { view in
            guard let typedView = try? view.asInspectableView(ofType: T.self)
            else { return false }
            return try condition(typedView)
        }).compactMap({ try? $0.asInspectableView(ofType: T.self) })
    }
    
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
            let name = Inspector.typeName(value: view, prefixOnly: false)
            if name.hasPrefix("EnvironmentReaderView") {
                return "navigationBarItems"
            }
            if name.hasPrefix("PopoverPresentationModifier") {
                return "popover"
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
                guard let view = try? children.element(at: offset) else { continue }
                let index = isSingle ? nil : offset
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
    
    // swiftlint:disable function_parameter_count
    func depthFirstRecursion(shouldContinue: inout Bool,
                             isSingle: Bool, offset: Int,
                             condition: ViewSearch.Condition,
                             stopOnFoundMatch: (UnwrappedView) -> Bool,
                             identificationFailure: (Content) -> Void) {
    // swiftlint:enable function_parameter_count
        if (try? condition(try self.asInspectableView())) == true,
           stopOnFoundMatch(self) {
            shouldContinue = false
        }
        guard shouldContinue else { return }
        
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
