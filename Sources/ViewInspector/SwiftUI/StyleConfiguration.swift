import SwiftUI

public extension ViewType {
    struct StyleConfiguration { }
}

public extension ViewType.StyleConfiguration {
    struct Label: KnownViewType {
        public static var typePrefix: String = "Label"
    }
    
    struct Content: KnownViewType {
        public static var typePrefix: String = "Content"
    }
    
    struct Title: KnownViewType {
        public static var typePrefix: String = "Title"
    }
    
    struct Icon: KnownViewType {
        public static var typePrefix: String = "Icon"
    }
    
    struct CurrentValueLabel: KnownViewType {
        public static var typePrefix: String = "CurrentValueLabel"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func styleConfigurationLabel() throws -> InspectableView<ViewType.StyleConfiguration.Label> {
        return try .init(try child())
    }
    
    func styleConfigurationContent() throws -> InspectableView<ViewType.StyleConfiguration.Content> {
        return try .init(try child())
    }
    
    func styleConfigurationTitle() throws -> InspectableView<ViewType.StyleConfiguration.Title> {
        return try .init(try child())
    }
    
    func styleConfigurationIcon() throws -> InspectableView<ViewType.StyleConfiguration.Icon> {
        return try .init(try child())
    }
    
    func styleConfigurationCurrentValueLabel() throws ->
    InspectableView<ViewType.StyleConfiguration.CurrentValueLabel> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func styleConfigurationLabel(_ index: Int) throws -> InspectableView<ViewType.StyleConfiguration.Label> {
        return try .init(try child(at: index))
    }
    
    func styleConfigurationContent(_ index: Int) throws -> InspectableView<ViewType.StyleConfiguration.Content> {
        return try .init(try child(at: index))
    }
    
    func styleConfigurationTitle(_ index: Int) throws -> InspectableView<ViewType.StyleConfiguration.Title> {
        return try .init(try child(at: index))
    }
    
    func styleConfigurationIcon(_ index: Int) throws -> InspectableView<ViewType.StyleConfiguration.Icon> {
        return try .init(try child(at: index))
    }
    
    func styleConfigurationCurrentValueLabel(_ index: Int) throws ->
    InspectableView<ViewType.StyleConfiguration.CurrentValueLabel> {
        return try .init(try child(at: index))
    }
}
