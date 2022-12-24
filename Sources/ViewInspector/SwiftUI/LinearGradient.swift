import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct LinearGradient: KnownViewType {
        public static var typePrefix: String = "LinearGradient"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func linearGradient() throws -> InspectableView<ViewType.LinearGradient> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func linearGradient(_ index: Int) throws -> InspectableView<ViewType.LinearGradient> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.LinearGradient {
    
    func gradient() throws -> Gradient {
        return try Inspector
            .attribute(label: "gradient", value: content.view, type: Gradient.self)
    }
    
    func startPoint() throws -> UnitPoint {
        return try Inspector
            .attribute(label: "startPoint", value: content.view, type: UnitPoint.self)
    }
    
    func endPoint() throws -> UnitPoint {
        return try Inspector
            .attribute(label: "endPoint", value: content.view, type: UnitPoint.self)
    }
}
