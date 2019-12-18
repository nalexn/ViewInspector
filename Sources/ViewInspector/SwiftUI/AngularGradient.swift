import SwiftUI

public extension ViewType {
    
    struct AngularGradient: KnownViewType {
        public static var typePrefix: String = "AngularGradient"
    }
}

public extension AngularGradient {
    
    func inspect() throws -> InspectableView<ViewType.AngularGradient> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func angularGradient() throws -> InspectableView<ViewType.AngularGradient> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func angularGradient(_ index: Int) throws -> InspectableView<ViewType.AngularGradient> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.AngularGradient {
    
    func gradient() throws -> Gradient {
        let gradient = try Inspector.attribute(label: "gradient", value: content.view)
        guard let casted = gradient as? Gradient else {
            throw InspectionError.typeMismatch(gradient, Gradient.self)
        }
        return casted
    }
    
    func center() throws -> UnitPoint {
        let center = try Inspector.attribute(label: "center", value: content.view)
        guard let casted = center as? UnitPoint else {
            throw InspectionError.typeMismatch(center, UnitPoint.self)
        }
        return casted
    }
    
    func startAngle() throws -> Angle {
        let angle = try Inspector.attribute(label: "startAngle", value: content.view)
        guard let casted = angle as? Angle else {
            throw InspectionError.typeMismatch(angle, Angle.self)
        }
        return casted
    }
    
    func endAngle() throws -> Angle {
        let angle = try Inspector.attribute(label: "endAngle", value: content.view)
        guard let casted = angle as? Angle else {
            throw InspectionError.typeMismatch(angle, Angle.self)
        }
        return casted
    }
}
