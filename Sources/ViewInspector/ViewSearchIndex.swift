import SwiftUI

// MARK: - Index

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewSearch {
    
    private static var index: [String: [ViewIdentity]] = {
        let knownViewTypes: [KnownViewType.Type] = [
            ViewType.ActionSheet.self,
            ViewType.ActionSheet.self,
            ViewType.Alert.self,
            ViewType.AlertButton.self,
            ViewType.AngularGradient.self,
            ViewType.AnyView.self,
            ViewType.AsyncImage.self,
            ViewType.Button.self,
            ViewType.Canvas.self,
            ViewType.Color.self,
            ViewType.ColorPicker.self,
            ViewType.ConfirmationDialog.self,
            ViewType.ControlGroup.self,
            ViewType.DatePicker.self,
            ViewType.DisclosureGroup.self,
            ViewType.Divider.self,
            ViewType.EditButton.self,
            ViewType.EmptyView.self,
            ViewType.EllipticalGradient.self,
            ViewType.ForEach.self,
            ViewType.Form.self,
            ViewType.GeometryReader.self,
            ViewType.Grid.self,
            ViewType.GridRow.self,
            ViewType.Group.self,
            ViewType.GroupBox.self,
            ViewType.HSplitView.self,
            ViewType.HStack.self,
            ViewType.Image.self,
            ViewType.Label.self,
            ViewType.LabeledContent.self,
            ViewType.LazyHGrid.self,
            ViewType.LazyHStack.self,
            ViewType.LazyVGrid.self,
            ViewType.LazyVStack.self,
            ViewType.LinearGradient.self,
            ViewType.Link.self,
            ViewType.List.self,
            ViewType.LocationButton.self,
            ViewType.Map.self,
            ViewType.Menu.self,
            ViewType.MenuButton.self,
            ViewType.MultiDatePicker.self,
            ViewType.NavigationDestination.self,
            ViewType.NavigationLink.self,
            ViewType.NavigationView.self,
            ViewType.NavigationSplitView.self,
            ViewType.NavigationStack.self,
            ViewType.OutlineGroup.self,
            ViewType.PasteButton.self,
            ViewType.Picker.self,
            ViewType.Popover.self,
            ViewType.ProgressView.self,
            ViewType.RadialGradient.self,
            ViewType.SafeAreaInset.self,
            ViewType.ScrollView.self,
            ViewType.ScrollViewReader.self,
            ViewType.Section.self,
            ViewType.SecureField.self,
            ViewType.SignInWithAppleButton.self,
            ViewType.ShareLink.self,
            ViewType.Sheet.self,
            ViewType.Slider.self,
            ViewType.Spacer.self,
            ViewType.Stepper.self,
            ViewType.StyleConfiguration.Label.self,
            ViewType.StyleConfiguration.Content.self,
            ViewType.StyleConfiguration.Title.self,
            ViewType.StyleConfiguration.Icon.self,
            ViewType.StyleConfiguration.CurrentValueLabel.self,
            ViewType.TabView.self,
            ViewType.Text.self,
            ViewType.TextEditor.self,
            ViewType.TextField.self,
            ViewType.TimelineView.self,
            ViewType.Toggle.self,
            ViewType.TouchBar.self,
            ViewType.TupleView.self,
            ViewType.Toolbar.self,
            ViewType.Toolbar.Item.self,
            ViewType.Toolbar.ItemGroup.self,
            ViewType.VideoPlayer.self,
            ViewType.ViewModifierContent.self,
            ViewType.ViewThatFits.self,
            ViewType.VSplitView.self,
            ViewType.VStack.self,
            ViewType.ZStack.self,
        ]
        let identities = knownViewTypes.map { $0.viewSearchIdentity() }
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
            return ViewType.Shape.viewSearchIdentity()
        }
        let shortName = Inspector.typeName(value: content.view, generics: .remove)
        let fullName = Inspector.typeName(value: content.view, namespaced: true, generics: .remove)
        if shortName.count > 0,
           let identity = index[String(shortName.prefix(1))]?
            .first(where: {
                $0.viewType.namespacedPrefixes.containsPrefixRegex(matching: fullName)
            }) {
            return identity
        }
        if (try? content.extractCustomView()) != nil {
            let name = Inspector.typeName(
                value: content.view, generics: .customViewPlaceholder)
            switch content.view {
            case _ as any View:
                return ViewType.View<ViewType.Stub>
                    .viewSearchIdentity(genericTypeName: name)
            case _ as any ViewModifier:
                return ViewType.ViewModifier<ViewType.Stub>
                    .viewSearchIdentity(genericTypeName: name)
            case _ as any Gesture:
                break
            default:
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
    struct Stub { }
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
        
        fileprivate init<T>(type: T.Type, genericTypeName: String?,
                            children: @escaping ChildrenBuilder,
                            supplementary: @escaping SupplementaryBuilder
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
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension KnownViewType {
    static func viewSearchIdentity(genericTypeName: String? = nil) -> ViewSearch.ViewIdentity {
        return ViewSearch.ViewIdentity(
            type: self,
            genericTypeName: genericTypeName ?? genericViewTypeForViewSearch,
            children: childViewsBuilder(),
            supplementary: supplementaryViewsBuilder())
    }
}

// MARK: - KnownViewType and extensions

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol KnownViewType: BaseViewType {
    static func childViewsBuilder() -> ViewSearch.ViewIdentity.ChildrenBuilder
    static func supplementaryViewsBuilder() -> ViewSearch.ViewIdentity.SupplementaryBuilder
    static var genericViewTypeForViewSearch: String? { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension KnownViewType {
    static func childViewsBuilder() -> ViewSearch.ViewIdentity.ChildrenBuilder {
        return { _ in .empty }
    }
    static func supplementaryViewsBuilder() -> ViewSearch.ViewIdentity.SupplementaryBuilder {
        return { _ in .empty }
    }
    static var genericViewTypeForViewSearch: String? { nil }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension KnownViewType where Self: SingleViewContent {
    static func childViewsBuilder() -> ViewSearch.ViewIdentity.ChildrenBuilder {
        return { parent in
            try child(parent.content).descendants(parent)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension KnownViewType where Self: MultipleViewContent {
    static func childViewsBuilder() -> ViewSearch.ViewIdentity.ChildrenBuilder {
        return { parent in
            try children(parent.content).descendants(parent, indexed: true)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension KnownViewType where Self: SingleViewContent & MultipleViewContent {
    static func childViewsBuilder() -> ViewSearch.ViewIdentity.ChildrenBuilder {
        return { parent in
            try children(parent.content).descendants(parent, indexed: true)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension KnownViewType where Self: SupplementaryChildren {
    static func supplementaryViewsBuilder() -> ViewSearch.ViewIdentity.SupplementaryBuilder {
        return { parent in
            try supplementaryChildren(parent)
        }
    }
}

// MARK: - Descendants

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
            .overlay, .overlayStyle, .background, .backgroundStyle
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
        .init(name: ViewType.NavigationDestination.typePrefix, builder: { parent, index in
            try parent.content.navigationDestination(parent: parent, index: index)
        }),
        .init(name: ViewType.SafeAreaInset.typePrefix, builder: { parent, index in
            try parent.content.safeAreaInset(parent: parent, index: index)
        }),
        .init(name: ViewType.Popover.standardModifierName, builder: { parent, index in
            try parent.content.popover(parent: parent, index: index)
        }),
        .init(name: ViewType.HelpView.Container.name, builder: { parent, index in
            try parent.content.help(parent: parent, index: index)
        }),
        .init(name: "_TooltipModifier", builder: { parent, index in
            try parent.content.help(parent: parent, index: index)
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
        .init(name: "PlatformItemTraitWriter<LabelPlatformItemsStrategy", builder: { parent, index in
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
