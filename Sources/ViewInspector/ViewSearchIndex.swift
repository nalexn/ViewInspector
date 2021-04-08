import SwiftUI

// MARK: - Index

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewSearch {
    
    private static var index: [String: [ViewIdentity]] = {
        let identities: [ViewIdentity] = [
            .init(ViewType.AngularGradient.self), .init(ViewType.AnyView.self),
            .init(ViewType.Button.self),
            .init(ViewType.Color.self), .init(ViewType.ColorPicker.self),
            .init(ViewType.DatePicker.self), .init(ViewType.DisclosureGroup.self),
            .init(ViewType.Divider.self),
            .init(ViewType.EditButton.self), .init(ViewType.EmptyView.self),
            .init(ViewType.ForEach.self), .init(ViewType.Form.self),
            .init(ViewType.GeometryReader.self),
            .init(ViewType.Group.self), .init(ViewType.GroupBox.self),
            .init(ViewType.HSplitView.self), .init(ViewType.HStack.self),
            .init(ViewType.Image.self),
            .init(ViewType.Label.self),
            .init(ViewType.LazyHGrid.self), .init(ViewType.LazyHStack.self),
            .init(ViewType.LazyVGrid.self), .init(ViewType.LazyVStack.self),
            .init(ViewType.LinearGradient.self),
            .init(ViewType.Link.self), .init(ViewType.List.self),
            .init(ViewType.Menu.self), .init(ViewType.MenuButton.self),
            .init(ViewType.NavigationLink.self), .init(ViewType.NavigationView.self),
            .init(ViewType.OutlineGroup.self),
            .init(ViewType.PasteButton.self), .init(ViewType.Picker.self),
            .init(ViewType.Popover.self), .init(ViewType.ProgressView.self),
            .init(ViewType.RadialGradient.self),
            .init(ViewType.ScrollView.self), .init(ViewType.ScrollViewReader.self),
            .init(ViewType.Section.self), .init(ViewType.SecureField.self),
            .init(ViewType.Slider.self), .init(ViewType.Spacer.self), .init(ViewType.Stepper.self),
            .init(ViewType.StyleConfiguration.Label.self), .init(ViewType.StyleConfiguration.Content.self),
            .init(ViewType.StyleConfiguration.Title.self), .init(ViewType.StyleConfiguration.Icon.self),
            .init(ViewType.StyleConfiguration.CurrentValueLabel.self),
            .init(ViewType.TabView.self), .init(ViewType.Text.self),
            .init(ViewType.TextEditor.self), .init(ViewType.TextField.self),
            .init(ViewType.Toggle.self), .init(ViewType.TouchBar.self), .init(ViewType.TupleView.self),
            .init(ViewType.ViewModifierContent.self), .init(ViewType.VSplitView.self), .init(ViewType.VStack.self),
            .init(ViewType.ZStack.self)
        ]
        var index = [String: [ViewIdentity]](minimumCapacity: 26) // alphabet
        identities.forEach { identity in
            let letter = String(identity.viewType.typePrefix.prefix(1))
            var array = index[letter] ?? []
            array.append(identity)
            index[letter] = array
        }
        return index
    }()
    
    private static func identify(_ content: Content) -> ViewIdentity? {
        let shortPrefix = Inspector.typeName(value: content.view, prefixOnly: true)
        let longPrefix = Inspector.typeName(value: content.view, namespaced: true, prefixOnly: true)
        if shortPrefix.count > 0,
           let identity = index[String(shortPrefix.prefix(1))]?
            .first(where: { $0.viewType.namespacedPrefixes.contains(longPrefix) }) {
            return identity
        }
        if (try? content.extractCustomView()) != nil {
            let name = Inspector.typeName(value: content.view, prefixOnly: true)
            return .init(ViewType.View<TraverseStubView>.self, genericTypeName: name)
        }
        return nil
    }
    
    static func identifyAndInstantiate(_ view: UnwrappedView, index: Int?) -> (ViewIdentity, UnwrappedView)? {
        guard let identity = ViewSearch.identify(view.content),
              let instance = try? identity.builder(view.content, view.parentView, index)
        else { return nil }
        return (identity, instance)
    }
}

// MARK: - TraverseStubView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct TraverseStubView: View, Inspectable {
    var body: some View { EmptyView() }
}

// MARK: - ViewIdentity

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewSearch {
    
    struct ViewIdentity {
        
        typealias ChildrenBuilder = (UnwrappedView) throws -> LazyGroup<UnwrappedView>
        typealias SupplementaryBuilder = (UnwrappedView) throws -> LazyGroup<SupplementaryView>
        
        let viewType: KnownViewType.Type
        let builder: (Content, UnwrappedView?, Int?) throws -> UnwrappedView
        let children: ChildrenBuilder
        let modifiers: ChildrenBuilder
        let supplementary: ChildrenBuilder
        
        var allDescendants: ChildrenBuilder {
            return { try self.children($0) + self.supplementary($0) + self.modifiers($0) }
        }
        
        private init<T>(_ type: T.Type,
                        genericTypeName: String?,
                        children: @escaping ChildrenBuilder = { _ in .empty },
                        supplementary: @escaping SupplementaryBuilder = { _ in .empty }
        ) where T: KnownViewType {
            viewType = type
            let callWithIndex: (Int?) -> String = { index in
                let base = type.inspectionCall(typeName: genericTypeName ?? "")
                return ViewType.inspectionCall(base: base, index: index)
            }
            builder = { content, parent, index in
                try InspectableView<T>(content, parent: parent, call: callWithIndex(index), index: index)
            }
            self.children = children
            self.supplementary = { parent in
                let descendants = try supplementary(parent)
                return .init(count: descendants.count) { index -> UnwrappedView in
                    let view = try descendants.element(at: index)
                    return try InspectableView<ViewType.ClassifiedView>(view.content, parent: view)
                }
            }
            self.modifiers = { parent in
                return parent.content.modifierDescendants(parent: parent)
            }
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType, T: SingleViewContent {
            self.init(type, genericTypeName: nil, children: { parent in
                try T.child(parent.content).descendants(parent)
            })
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType, T: SingleViewContent, T: SupplementaryChildren {
            self.init(type, genericTypeName: nil, children: { parent in
                try T.child(parent.content).descendants(parent)
            }, supplementary: { parent in
                try T.supplementaryChildren(parent)
            })
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType, T: MultipleViewContent {
            self.init(type, genericTypeName: nil, children: { parent in
                try T.children(parent.content).descendants(parent, indexed: true)
            })
        }
        
        init<T>(_ type: T.Type)
        where T: KnownViewType, T: MultipleViewContent, T: SupplementaryChildren {
            self.init(type, genericTypeName: nil, children: { parent in
                try T.children(parent.content).descendants(parent, indexed: true)
            }, supplementary: { parent in
                try T.supplementaryChildren(parent)
            })
        }
        
        init<T>(_ type: T.Type, genericTypeName: String? = nil)
        where T: KnownViewType, T: SingleViewContent, T: MultipleViewContent {
            self.init(type, genericTypeName: genericTypeName, children: { parent in
                try T.children(parent.content).descendants(parent, indexed: true)
            })
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType {
            self.init(type, genericTypeName: nil, children: { _ in .empty })
        }
        
        init<T>(_ type: T.Type) where T: KnownViewType, T: SupplementaryChildren {
            self.init(type, genericTypeName: nil, supplementary: { parent in
                try T.supplementaryChildren(parent)
            })
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension LazyGroup where T == Content {
    func descendants(_ parent: UnwrappedView, indexed: Bool) -> LazyGroup<UnwrappedView> {
        return .init(count: count, { index in
            try InspectableView<ViewType.ClassifiedView>(
                try element(at: index), parent: parent, index: indexed ? index : nil)
        })
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Content {
    func descendants(_ parent: UnwrappedView) -> LazyGroup<UnwrappedView> {
        return .init(count: 1) { _ in
            try InspectableView<ViewType.ClassifiedView>(self, parent: parent, index: nil)
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
        .init(name: "PopoverPresentationModifier", builder: { parent in
            try parent.content.popover(parent: parent)
        }),
        .init(name: "_MaskEffect", builder: { parent in
            try parent.content.mask(parent: parent)
        }),
        .init(name: "_TraitWritingModifier<TabItemTraitKey>", builder: { parent in
            try parent.content.tabItem(parent: parent)
        }),
        .init(name: "_TraitWritingModifier<ListRowBackgroundTraitKey>", builder: { parent in
            try parent.content.listRowBackground(parent: parent)
        }),
        .init(name: "_TouchBarModifier", builder: { parent in
            try parent.content.touchBar(parent: parent)
        }),
    ]
    
    struct ModifierIdentity {
        let name: String
        let builder: (UnwrappedView) throws -> UnwrappedView
        
        init(name: String, builder: @escaping (UnwrappedView) throws -> UnwrappedView) {
            self.name = name
            self.builder = { parent in
                let modifier = try builder(parent)
                guard modifier is InspectableView<ViewType.ClassifiedView>
                else { return modifier }
                return try InspectableView<ViewType.ClassifiedView>(modifier.content, parent: modifier)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func modifierDescendants(parent: UnwrappedView) -> LazyGroup<UnwrappedView> {
        let modifierNames = medium.viewModifiers
                .compactMap { $0 as? ModifierNameProvider }
                .map { $0.modifierType }
        let identities = ViewSearch.modifierIdentities.filter({ identity -> Bool in
            modifierNames.contains(where: { $0.hasPrefix(identity.name) })
        })
        let customModifiers = customViewModifiers()
        return .init(count: identities.count, { index -> UnwrappedView in
            try identities[index].builder(parent)
        }) + .init(count: customModifiers.count, { index -> UnwrappedView in
            let modifier = customModifiers[index]
            let view = try modifier.extractContent(environmentObjects: medium.environmentObjects)
            let medium = self.medium.resettingViewModifiers()
            let content = try Inspector.unwrap(view: view, medium: medium)
            let name = Inspector.typeName(value: modifier)
            let call = ViewType.ModifiedContent.inspectionCall(typeName: name)
            let modifierView = try InspectableView<ViewType.ClassifiedView>(content, parent: parent, call: call)
            return try InspectableView<ViewType.ClassifiedView>(content, parent: modifierView)
        })
    }
}
