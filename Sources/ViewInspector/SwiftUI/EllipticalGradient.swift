import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct EllipticalGradient: KnownViewType {
        public static var typePrefix: String = "EllipticalGradient"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func ellipticalGradient() throws -> InspectableView<ViewType.EllipticalGradient> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func ellipticalGradient(_ index: Int) throws -> InspectableView<ViewType.EllipticalGradient> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
public extension InspectableView where View == ViewType.EllipticalGradient {
    
    func gradient() throws -> Gradient {
        return try Inspector
            .attribute(label: "gradient", value: content.view, type: Gradient.self)
    }
    
    func center() throws -> UnitPoint {
        return try Inspector
            .attribute(label: "center", value: content.view, type: UnitPoint.self)
    }
    
    func startRadiusFraction() throws -> CGFloat {
        return try Inspector
            .attribute(label: "startRadiusFraction", value: content.view, type: CGFloat.self)
    }
    
    func endRadiusFraction() throws -> CGFloat {
        return try Inspector
            .attribute(label: "endRadiusFraction", value: content.view, type: CGFloat.self)
    }
}
