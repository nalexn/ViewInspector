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
            .init(ViewType.Toggle.self), .init(ViewType.TouchBar.self),
            .init(ViewType.VSplitView.self), .init(ViewType.VStack.self),
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
    
    static func identify(_ content: Content) -> ViewIdentity? {
        let typePrefix = Inspector.typeName(value: content.view, prefixOnly: true)
        if let identity = index[String(typePrefix.prefix(1))]?
            .first(where: { $0.viewType.typePrefix == typePrefix }) {
            return identity
        }
        if (try? content.extractCustomView()) != nil {
            return .init(ViewType.View<TraverseStubView>.self)
        }
        return nil
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
        let viewType: KnownViewType.Type
        let builder: (Content, UnwrappedView?, Int?) throws -> UnwrappedView
        let descendants: (UnwrappedView) throws -> LazyGroup<UnwrappedView>
        
        private init<T>(_ type: T.Type,
                        call: String?,
                        descendants: @escaping (UnwrappedView) throws -> LazyGroup<UnwrappedView>
        ) where T: KnownViewType {
            viewType = type
            let callWithIndex: (Int?) -> String = { index in
                let base = call ?? (type.typePrefix.prefix(1).lowercased() + type.typePrefix.dropFirst())
                return base + (index.flatMap({ "(\($0))" }) ?? "()")
            }
            builder = { content, parent, index in
                try InspectableView<T>.init(content, parent: parent, call: callWithIndex(index), index: index)
            }
            self.descendants = { parent in
                let children = try descendants(parent)
                let modifiers = parent.content.modifierDescendants(parent: parent)
                return children + modifiers
            }
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: SingleViewContent {
            self.init(type, call: call, descendants: { parent in
                try T.child(parent.content).descendants(parent)
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: SingleViewContent, T: SupplementaryChildren {
            self.init(type, call: call, descendants: { parent in
                try T.child(parent.content).descendants(parent)
                    + T.supplementaryChildren(parent.content).descendants(parent, indexed: false)
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: MultipleViewContent {
            self.init(type, call: call, descendants: { parent in
                try T.children(parent.content).descendants(parent, indexed: true)
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: MultipleViewContent, T: SupplementaryChildren {
            self.init(type, call: call, descendants: { parent in
                try T.children(parent.content).descendants(parent, indexed: true)
                    + T.supplementaryChildren(parent.content).descendants(parent, indexed: false)
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: SingleViewContent, T: MultipleViewContent {
            self.init(type, call: call, descendants: { parent in
                try T.children(parent.content).descendants(parent, indexed: true)
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil
        ) where T: KnownViewType, T: SingleViewContent, T: MultipleViewContent, T: SupplementaryChildren {
            self.init(type, call: call, descendants: { parent in
                try T.children(parent.content).descendants(parent, indexed: true)
                    + T.supplementaryChildren(parent.content).descendants(parent, indexed: false)
            })
        }
        
        init<T>(_ type: T.Type, call: String? = nil) where T: KnownViewType {
            self.init(type, call: call, descendants: { _ in .empty })
        }
        
        init<T>(_ type: T.Type, call: String? = nil) where T: KnownViewType, T: SupplementaryChildren {
            self.init(type, call: call, descendants: { parent in
                try T.supplementaryChildren(parent.content).descendants(parent, indexed: false)
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
        .init(name: "_MaskEffect", builder: { parent in
            try parent.content.mask(parent: parent)
        })
    ]
    
    struct ModifierIdentity {
        let name: String
        let builder: (UnwrappedView) throws -> UnwrappedView
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func modifierDescendants(parent: UnwrappedView) -> LazyGroup<UnwrappedView> {
        let modifierNames = self.modifiers
                .compactMap { $0 as? ModifierNameProvider }
                .map { $0.modifierType }
        let identities = ViewSearch.modifierIdentities.filter({ identity -> Bool in
            modifierNames.contains(where: { $0.hasPrefix(identity.name) })
        })
        return .init(count: identities.count) { index -> UnwrappedView in
            try identities[index].builder(parent)
        }
    }
}
