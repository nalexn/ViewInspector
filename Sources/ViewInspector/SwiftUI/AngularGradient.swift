import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct AngularGradient: KnownViewType {
        public static var typePrefix: String = "AngularGradient"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func angularGradient() throws -> InspectableView<ViewType.AngularGradient> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func angularGradient(_ index: Int) throws -> InspectableView<ViewType.AngularGradient> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.AngularGradient {
    
    func gradient() throws -> Gradient {
        return try Inspector
            .attribute(label: "gradient", value: content.view, type: Gradient.self)
    }
    
    func center() throws -> UnitPoint {
        return try Inspector
            .attribute(label: "center", value: content.view, type: UnitPoint.self)
    }
    
    func startAngle() throws -> Angle {
        return try Inspector
            .attribute(label: "startAngle", value: content.view, type: Angle.self)
    }
    
    func endAngle() throws -> Angle {
        return try Inspector
            .attribute(label: "endAngle", value: content.view, type: Angle.self)
    }
}
