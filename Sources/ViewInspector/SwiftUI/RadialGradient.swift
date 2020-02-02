import SwiftUI

public extension ViewType {
    
    struct RadialGradient: KnownViewType {
        public static var typePrefix: String = "RadialGradient"
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func radialGradient() throws -> InspectableView<ViewType.RadialGradient> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func radialGradient(_ index: Int) throws -> InspectableView<ViewType.RadialGradient> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.RadialGradient {
    
    func gradient() throws -> Gradient {
        return try Inspector
            .attribute(label: "gradient", value: content.view, type: Gradient.self)
    }
    
    func center() throws -> UnitPoint {
        return try Inspector
            .attribute(label: "center", value: content.view, type: UnitPoint.self)
    }
    
    func startRadius() throws -> CGFloat {
        return try Inspector
            .attribute(label: "startRadius", value: content.view, type: CGFloat.self)
    }
    
    func endRadius() throws -> CGFloat {
        return try Inspector
            .attribute(label: "endRadius", value: content.view, type: CGFloat.self)
    }
}
