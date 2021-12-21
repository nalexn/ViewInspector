import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    struct StyleConfiguration { }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType.StyleConfiguration {
    struct Label: KnownViewType {
        public static var typePrefix: String = "Label"
        
        public static var namespacedPrefixes: [String] {
            var types: [Any.Type] = [
                PrimitiveButtonStyleConfiguration.Label.self,
                ButtonStyleConfiguration.Label.self,
                ToggleStyleConfiguration.Label.self
            ]
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                types.append(ProgressViewStyleConfiguration.Label.self)
                #if os(iOS) || os(macOS)
                types.append(GroupBoxStyleConfiguration.Label.self)
                types.append(MenuStyleConfiguration.Label.self)
                #endif
            }
            return types
                .map { Inspector.typeName(type: $0, namespaced: true, generics: .remove) }
        }
        
        public static func inspectionCall(typeName: String) -> String {
            return "styleConfigurationLabel(\(ViewType.indexPlaceholder))"
        }
    }
    
    struct Content: KnownViewType {
        public static var typePrefix: String = "Content"
        
        public static var namespacedPrefixes: [String] {
            var types: [Any.Type] = []
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, *) {
                #if os(iOS) || os(macOS)
                types.append(GroupBoxStyleConfiguration.Content.self)
                types.append(MenuStyleConfiguration.Content.self)
                #endif
            }
            return types
                .map { Inspector.typeName(type: $0, namespaced: true, generics: .remove) }
        }
        
        public static func inspectionCall(typeName: String) -> String {
            return "styleConfigurationContent(\(ViewType.indexPlaceholder))"
        }
    }
    
    struct Title: KnownViewType {
        public static var typePrefix: String = "Title"
        
        public static var namespacedPrefixes: [String] {
            var types: [Any.Type] = []
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                types.append(LabelStyleConfiguration.Title.self)
            }
            return types
                .map { Inspector.typeName(type: $0, namespaced: true, generics: .remove) }
        }
        
        public static func inspectionCall(typeName: String) -> String {
            return "styleConfigurationTitle(\(ViewType.indexPlaceholder))"
        }
    }
    
    struct Icon: KnownViewType {
        public static var typePrefix: String = "Icon"
        
        public static var namespacedPrefixes: [String] {
            var types: [Any.Type] = []
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                types.append(LabelStyleConfiguration.Icon.self)
            }
            return types
                .map { Inspector.typeName(type: $0, namespaced: true, generics: .remove) }
        }
        
        public static func inspectionCall(typeName: String) -> String {
            return "styleConfigurationIcon(\(ViewType.indexPlaceholder))"
        }
    }
    
    struct CurrentValueLabel: KnownViewType {
        public static var typePrefix: String = "CurrentValueLabel"
        
        public static var namespacedPrefixes: [String] {
            var types: [Any.Type] = []
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                types.append(ProgressViewStyleConfiguration.CurrentValueLabel.self)
            }
            return types
                .map { Inspector.typeName(type: $0, namespaced: true, generics: .remove) }
        }
        
        public static func inspectionCall(typeName: String) -> String {
            return "styleConfigurationCurrentValueLabel(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func styleConfigurationLabel() throws -> InspectableView<ViewType.StyleConfiguration.Label> {
        return try .init(try child(), parent: self)
    }
    
    func styleConfigurationContent() throws -> InspectableView<ViewType.StyleConfiguration.Content> {
        return try .init(try child(), parent: self)
    }
    
    func styleConfigurationTitle() throws -> InspectableView<ViewType.StyleConfiguration.Title> {
        return try .init(try child(), parent: self)
    }
    
    func styleConfigurationIcon() throws -> InspectableView<ViewType.StyleConfiguration.Icon> {
        return try .init(try child(), parent: self)
    }
    
    func styleConfigurationCurrentValueLabel() throws ->
    InspectableView<ViewType.StyleConfiguration.CurrentValueLabel> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func styleConfigurationLabel(_ index: Int) throws -> InspectableView<ViewType.StyleConfiguration.Label> {
        return try .init(try child(at: index), parent: self, index: index)
    }
    
    func styleConfigurationContent(_ index: Int) throws -> InspectableView<ViewType.StyleConfiguration.Content> {
        return try .init(try child(at: index), parent: self, index: index)
    }
    
    func styleConfigurationTitle(_ index: Int) throws -> InspectableView<ViewType.StyleConfiguration.Title> {
        return try .init(try child(at: index), parent: self, index: index)
    }
    
    func styleConfigurationIcon(_ index: Int) throws -> InspectableView<ViewType.StyleConfiguration.Icon> {
        return try .init(try child(at: index), parent: self, index: index)
    }
    
    func styleConfigurationCurrentValueLabel(_ index: Int) throws ->
    InspectableView<ViewType.StyleConfiguration.CurrentValueLabel> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}
