import SwiftUI

// MARK: - Index

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewSearch {
    
    private static var index: [String: [ViewIdentity]] = {
        let identities: [ViewIdentity] = [
            .init(ViewType.ActionSheet.self),
            .init(ViewType.Alert.self), .init(ViewType.AlertButton.self),
            .init(ViewType.AngularGradient.self), .init(ViewType.AnyView.self),
            .init(ViewType.AsyncImage.self),
            .init(ViewType.Button.self), .init(ViewType.Canvas.self),
            .init(ViewType.Color.self), .init(ViewType.ColorPicker.self),
            .init(ViewType.ConfirmationDialog.self),
            .init(ViewType.ControlGroup.self, genericTypeName: nil),
            .init(ViewType.DatePicker.self), .init(ViewType.DisclosureGroup.self),
            .init(ViewType.Divider.self),
            .init(ViewType.EditButton.self), .init(ViewType.EmptyView.self),
            .init(ViewType.EllipticalGradient.self),
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
            .init(ViewType.LocationButton.self),
            .init(ViewType.Map.self),
            .init(ViewType.Menu.self), .init(ViewType.MenuButton.self),
            .init(ViewType.NavigationLink.self), .init(ViewType.NavigationView.self),
            .init(ViewType.OutlineGroup.self),
            .init(ViewType.PasteButton.self), .init(ViewType.Picker.self),
            .init(ViewType.Popover.self, genericTypeName: nil),
            .init(ViewType.ProgressView.self),
            .init(ViewType.RadialGradient.self),
            .init(ViewType.SafeAreaInset.self, genericTypeName: nil),
            .init(ViewType.ScrollView.self), .init(ViewType.ScrollViewReader.self),
            .init(ViewType.Section.self), .init(ViewType.SecureField.self),
            .init(ViewType.SignInWithAppleButton.self),
            .init(ViewType.Sheet.self, genericTypeName: "Sheet"),
            .init(ViewType.Slider.self), .init(ViewType.Spacer.self), .init(ViewType.Stepper.self),
            .init(ViewType.StyleConfiguration.Label.self), .init(ViewType.StyleConfiguration.Content.self),
            .init(ViewType.StyleConfiguration.Title.self), .init(ViewType.StyleConfiguration.Icon.self),
            .init(ViewType.StyleConfiguration.CurrentValueLabel.self),
            .init(ViewType.TabView.self), .init(ViewType.Text.self),
            .init(ViewType.TextEditor.self), .init(ViewType.TextField.self),
            .init(ViewType.TimelineView.self),
            .init(ViewType.Toggle.self), .init(ViewType.TouchBar.self),
            .init(ViewType.TupleView.self), .init(ViewType.Toolbar.self),
            .init(ViewType.Toolbar.Item.self, genericTypeName: nil),
            .init(ViewType.Toolbar.ItemGroup.self, genericTypeName: nil),
            .init(ViewType.VideoPlayer.self),
            .init(ViewType.ViewModifierContent.self),
            .init(ViewType.VSplitView.self), .init(ViewType.VStack.self),
            .init(ViewType.ZStack.self)
        ]

        var index = [String: [ViewIdentity]](minimumCapacity: 26) // alphabet
        identities.forEach { identity in
            let names = identity.viewType.namespacedPrefixes
                .compactMap { $0.components(separatedBy: ".").last }
                + [identity.viewType.typePrefix]
            let letters = Set(names).map { String($0.prefix(1)) }
            letters.forEach { letter in
                var array = index[letter] ?? []
                array.append(identity)
                index[letter] = array
            }
        }
        return index
    }()
    
    private static func identify(_ content: Content) -> ViewIdentity? {
        if let customMapping = content.view as? CustomViewIdentityMapping {
            let viewType = customMapping.viewTypeForSearch
            let letter = String(viewType.typePrefix.prefix(1))
            return index[letter]?.first(where: { $0.viewType == viewType })
        }
        if content.isShape {
            return .init(ViewType.Shape.self)
        }
        let shortName = Inspector.typeName(value: content.view, generics: .remove)
        let fullName = Inspector.typeName(value: content.view, namespaced: true, generics: .remove)
        if shortName.count > 0,
           let identity = index[String(shortName.prefix(1))]?
            .first(where: { $0.viewType.namespacedPrefixes.contains(fullName) }) {
            return identity
        }
        if (try? content.extractCustomView()) != nil,
           let inspectable = content.view as? Inspectable {
            let name = Inspector.typeName(
                value: content.view, generics: .customViewPlaceholder)
            switch inspectable.entity {
            case .view:
                return .init(ViewType.View<ViewType.Stub>.self, genericTypeName: name)
            case .viewModifier:
                return .init(ViewType.ViewModifier<ViewType.Stub>.self, genericTypeName: name)
            case .gesture:
                break
            }
            
        }
        return nil
    }
    
    static func identifyAndInstantiate(_ view: UnwrappedView, index: Int?) -> (ViewIdentity, UnwrappedView)? {
        guard let identity = ViewSearch.identify(view.content),
              let instance = { () -> UnwrappedView? in
                    if view.isUnwrappedSupplementaryChild {
                        return view
                    }
                    return try? identity.builder(view.content, view.parentView, index)
                }()
        else { return nil }
        return (identity, instance)
    }
}

// MARK: - ViewType.Stub

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct Stub: Inspectable {
        var entity: Content.InspectableEntity
        func extractContent(environmentObjects: [AnyObject]) throws -> Any { () }
    }
}

// MARK: - ViewIdentity

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol CustomViewIdentityMapping {
    var viewTypeForSearch: KnownViewType.Type { get }
}

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
                    var view = try descendants.element(at: index)
                    if Inspector.isTupleView(view.content.view) ||
                        !(view is InspectableView<ViewType.ClassifiedView>) {
                        view.isUnwrappedSupplementaryChild = true
                        return view
                    }
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
internal extension ViewType.Overlay.API {
    
    static var viewSearchModifierIdentities: [ViewSearch.ModifierIdentity] {
        let apiToSearch: [ViewType.Overlay.API] = [
            .overlayPreferenceValue, .backgroundPreferenceValue,
            .overlay, .background
        ]
        return apiToSearch
            .map { api in
                .init(name: api.modifierName, builder: { parent, index in
                    try parent.content.overlay(parent: parent, api: api, index: index)
                })
            }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewSearch {
    
    static private(set) var modifierIdentities: [ModifierIdentity] = ViewType.Overlay.API.viewSearchModifierIdentities
    + [
        .init(name: ViewType.Toolbar.typePrefix, builder: { parent, index in
            try parent.content.toolbar(parent: parent, index: index)
        }),
        .init(name: ViewType.ConfirmationDialog.typePrefix, builder: { parent, index in
            try parent.content.confirmationDialog(parent: parent, index: index)
        }),
        .init(name: ViewType.SafeAreaInset.typePrefix, builder: { parent, index in
            try parent.content.safeAreaInset(parent: parent, index: index)
        }),
        .init(name: ViewType.Popover.standardModifierName, builder: { parent, index in
            try parent.content.popover(parent: parent, index: index)
        }),
        .init(name: "_MaskEffect", builder: { parent, index in
            try parent.content.mask(parent: parent, index: index)
        }),
        .init(name: "_TraitWritingModifier<TabItemTraitKey>", builder: { parent, index in
            try parent.content.tabItem(parent: parent, index: index)
        }),
        .init(name: "PlatformItemTraitWriter<LabelPlatformItemListFlags", builder: { parent, index in
            try parent.content.tabItem(parent: parent, index: index)
        }),
        .init(name: "_TraitWritingModifier<ListRowBackgroundTraitKey>", builder: { parent, index in
            try parent.content.listRowBackground(parent: parent, index: index)
        }),
        .init(name: "_TouchBarModifier", builder: { parent, index in
            try parent.content.touchBar(parent: parent, index: index)
        }),
    ]
    
    struct ModifierIdentity {
        typealias Builder = (UnwrappedView, Int?) throws -> UnwrappedView
        let name: String
        let builder: Builder
        
        init(name: String, builder: @escaping Builder) {
            self.name = name
            self.builder = { parent, index in
                let view = try builder(parent, index)
                if view.isTransitive {
                    return try InspectableView<ViewType.ClassifiedView>(
                        view.content, parent: view, index: index)
                } else {
                    return view
                }
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func modifierDescendants(parent: UnwrappedView) -> LazyGroup<UnwrappedView> {
        let modifierNames = modifiersMatching({ _ in true })
                .map { $0.modifierType }
        let identities = ViewSearch.modifierIdentities
            .filter({ identity -> Bool in
                modifierNames.contains(where: { $0.hasPrefix(identity.name) })
            })
        let sheets = sheetModifierDescendants(parent: parent)
        let customModifiers = customViewModifiers()
        let modifiersCount = modifierNames.count
        return .init(count: identities.count * modifiersCount, { index -> UnwrappedView in
            try identities[index / modifiersCount]
                .builder(parent, (index % modifiersCount).nilIfZero)
        }) + sheets + .init(count: customModifiers.count, { index -> UnwrappedView in
            let modifier = customModifiers[index]
            let name = Inspector.typeName(value: modifier)
            let thisTypeModifiersCount = customModifiers
                .reduce(0, { $0 + (Inspector.typeName(value: $1) == name ? 1 : 0) })
            let index = thisTypeModifiersCount > 1 ? index : nil
            let medium = self.medium.resettingViewModifiers()
            let content = try Inspector.unwrap(view: modifier, medium: medium)
            
            let base = ViewType.ViewModifier<ViewType.Stub>
                .inspectionCall(typeName: name)
            let call = ViewType.inspectionCall(base: base, index: index)
            return try InspectableView<ViewType.ViewModifier<ViewType.Stub>>(
                content, parent: parent, call: call, index: index)
        })
    }
    
    private func sheetModifierDescendants(parent: UnwrappedView) -> LazyGroup<UnwrappedView> {
        let sheetModifiers = sheetsForSearch()
        let alertModifiers = alertsForSearch()
        #if os(macOS)
        let actionSheetModifiers: [ViewSearch.ModifierIdentity] = []
        #else
        let actionSheetModifiers = actionSheetsForSearch()
        #endif
        #if os(iOS) || os(macOS)
        let popoverModifiers = popoversForSearch()
        #else
        let popoverModifiers: [ViewSearch.ModifierIdentity] = []
        #endif
        return
            .init(count: sheetModifiers.count, { index -> UnwrappedView in
                try sheetModifiers[index].builder(parent, index)
            }) + .init(count: actionSheetModifiers.count, { index -> UnwrappedView in
                try actionSheetModifiers[index].builder(parent, index)
            }) + .init(count: alertModifiers.count, { index -> UnwrappedView in
                try alertModifiers[index].builder(parent, index)
            }) + .init(count: popoverModifiers.count, { index -> UnwrappedView in
                try popoverModifiers[index].builder(parent, index)
            })
    }
}

private extension Int {
    var nilIfZero: Int? {
        return self == 0 ? nil : self
    }
}
