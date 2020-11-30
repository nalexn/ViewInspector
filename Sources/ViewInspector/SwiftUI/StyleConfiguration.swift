import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    struct StyleConfiguration { }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType.StyleConfiguration {
    struct Label: KnownViewType {
        public static var typePrefix: String = "Label"
        public static func inspectionCall(index: Int?) -> String { ".styleConfigurationLabel()" }
    }
    
    struct Content: KnownViewType {
        public static var typePrefix: String = "Content"
        public static func inspectionCall(index: Int?) -> String { ".styleConfigurationContent()" }
    }
    
    struct Title: KnownViewType {
        public static var typePrefix: String = "Title"
        public static func inspectionCall(index: Int?) -> String { ".styleConfigurationTitle()" }
    }
    
    struct Icon: KnownViewType {
        public static var typePrefix: String = "Icon"
        public static func inspectionCall(index: Int?) -> String { ".styleConfigurationIcon()" }
    }
    
    struct CurrentValueLabel: KnownViewType {
        public static var typePrefix: String = "CurrentValueLabel"
        public static func inspectionCall(index: Int?) -> String { ".styleConfigurationCurrentValueLabel()" }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func styleConfigurationLabel() throws -> InspectableView<ViewType.StyleConfiguration.Label> {
        return try .init(try child(), parent: self, index: nil)
    }
    
    func styleConfigurationContent() throws -> InspectableView<ViewType.StyleConfiguration.Content> {
        return try .init(try child(), parent: self, index: nil)
    }
    
    func styleConfigurationTitle() throws -> InspectableView<ViewType.StyleConfiguration.Title> {
        return try .init(try child(), parent: self, index: nil)
    }
    
    func styleConfigurationIcon() throws -> InspectableView<ViewType.StyleConfiguration.Icon> {
        return try .init(try child(), parent: self, index: nil)
    }
    
    func styleConfigurationCurrentValueLabel() throws ->
    InspectableView<ViewType.StyleConfiguration.CurrentValueLabel> {
        return try .init(try child(), parent: self, index: nil)
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
