import SwiftUI

public extension ViewType {
    
    struct StyleConfigurationLabel: KnownViewType {
        public static var typePrefix: String = "Label"
    }
    
    struct StyleConfigurationContent: KnownViewType {
        public static var typePrefix: String = "Content"
    }
    
    struct StyleConfigurationTitle: KnownViewType {
        public static var typePrefix: String = "Title"
    }
    
    struct StyleConfigurationIcon: KnownViewType {
        public static var typePrefix: String = "Icon"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func styleConfigurationLabel() throws -> InspectableView<ViewType.StyleConfigurationLabel> {
        return try .init(try child())
    }
    
    func styleConfigurationContent() throws -> InspectableView<ViewType.StyleConfigurationContent> {
        return try .init(try child())
    }
    
    func styleConfigurationTitle() throws -> InspectableView<ViewType.StyleConfigurationTitle> {
        return try .init(try child())
    }
    
    func styleConfigurationIcon() throws -> InspectableView<ViewType.StyleConfigurationIcon> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func styleConfigurationLabel(_ index: Int) throws -> InspectableView<ViewType.StyleConfigurationLabel> {
        return try .init(try child(at: index))
    }
    
    func styleConfigurationContent(_ index: Int) throws -> InspectableView<ViewType.StyleConfigurationContent> {
        return try .init(try child(at: index))
    }
    
    func styleConfigurationTitle(_ index: Int) throws -> InspectableView<ViewType.StyleConfigurationTitle> {
        return try .init(try child(at: index))
    }
    
    func styleConfigurationIcon(_ index: Int) throws -> InspectableView<ViewType.StyleConfigurationIcon> {
        return try .init(try child(at: index))
    }
}
