import SwiftUI

public extension ViewType {
    
    struct Shape: KnownViewType {
        public static var typePrefix: String = ""
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func shape() throws -> InspectableView<ViewType.Shape> {
        let content = try child()
        try guardShapeIsInspectable(content.view)
        return try .init(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func shape(_ index: Int) throws -> InspectableView<ViewType.Shape> {
        let content = try child(at: index)
        try guardShapeIsInspectable(content.view)
        return try .init(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Shape {
    
    func actualShape<S>(_ shapeType: S.Type) throws -> S where S: Shape {
        let name = Inspector.typeName(type: S.self)
        let shape = try lookupShape(content.view, typeName: name, lookupMode: .shape)
        guard let typedShape = shape as? S else {
            throw InspectionError.typeMismatch(shape, S.self)
        }
        return typedShape
    }
    
    func path(in rect: CGRect) throws -> Path {
        guard let shape = content.view as? InspectableShape else {
            throw InspectionError.notSupported(
                "Please put a void '.offset()' modifier before or after '.inset(by:)'")
        }
        return shape.path(in: rect)
    }
    
    func inset() throws -> CGFloat {
        return try shapeAttribute(content.view, "_Inset", "amount", CGFloat.self)
    }
    
    func offset() throws -> CGSize {
        return try shapeAttribute(content.view, "OffsetShape", "offset", CGSize.self)
    }
    
    func scale() throws -> (x: CGFloat, y: CGFloat, anchor: UnitPoint) {
        let size = try shapeAttribute(content.view, "ScaledShape", "scale", CGSize.self)
        let anchor = try shapeAttribute(content.view, "ScaledShape", "anchor", UnitPoint.self)
        return (size.width, size.height, anchor)
    }
    
    func rotation() throws -> (angle: Angle, anchor: UnitPoint) {
        let angle = try shapeAttribute(content.view, "RotatedShape", "angle", Angle.self)
        let anchor = try shapeAttribute(content.view, "RotatedShape", "anchor", UnitPoint.self)
        return (angle, anchor)
    }
    
    func transform() throws -> CGAffineTransform {
        return try shapeAttribute(content.view, "TransformedShape", "transform", CGAffineTransform.self)
    }
    
    func size() throws -> CGSize {
        return try shapeAttribute(content.view, "_SizedShape", "size", CGSize.self)
    }
    
    func strokeStyle() throws -> StrokeStyle {
        return try shapeAttribute(content.view, "_StrokedShape", "style", StrokeStyle.self)
    }
    
    func trim() throws -> (from: CGFloat, to: CGFloat) {
        let from = try shapeAttribute(content.view, "_TrimmedShape", "startFraction", CGFloat.self)
        let to = try shapeAttribute(content.view, "_TrimmedShape", "endFraction", CGFloat.self)
        return (from, to)
    }
    
    func fillShapeStyle<S>(_ style: S.Type) throws -> S where S: ShapeStyle {
        return try shapeAttribute(content.view, "_ShapeView", "style", S.self)
    }
    
    func fillStyle() throws -> FillStyle {
        return try shapeAttribute(content.view, "_ShapeView", "fillStyle", FillStyle.self)
    }
}

// MARK: - Private

private extension InspectableView {
    
    func guardShapeIsInspectable(_ view: Any) throws {
        guard view is InspectableShape || Inspector.typeName(value: view) == "_Inset" else {
            throw InspectionError.typeMismatch(view, InspectableShape.self)
        }
    }
    
    func shapeAttribute<T>(_ view: Any, _ shapeType: String, _ label: String, _ attributeType: T.Type
    ) throws -> T {
        let shape = try lookupShape(view, typeName: shapeType, lookupMode: .attribute(label: label))
        return try Inspector.attribute(label: label, value: shape, type: attributeType)
    }
    
    enum ShapeLookupMode {
        case attribute(label: String)
        case shape
    }
    
    func lookupShape(_ view: Any, typeName: String, lookupMode: ShapeLookupMode) throws -> Any {
        let name = Inspector.typeName(value: view, prefixOnly: true)
        if name.hasPrefix(typeName) {
            return view
        }
        guard let containedShape = try? Inspector.attribute(label: "shape", value: view) else {
            switch lookupMode {
            case let .attribute(label):
                let originalType = Inspector.typeName(value: content.view)
                throw InspectionError.attributeNotFound(label: label, type: originalType)
            case .shape:
                let factualName = Inspector.typeName(value: view)
                if factualName == "_Inset" {
                    throw InspectionError.notSupported(
                        "Modifier '.inset(by:)' is blocking Shape inspection")
                } else {
                    throw InspectionError.typeMismatch(factual: factualName, expected: typeName)
                }
            }
        }
        return try lookupShape(containedShape, typeName: typeName, lookupMode: lookupMode)
    }
}

// MARK: - InspectableShape

public protocol InspectableShape {
    func path(in rect: CGRect) -> Path
}

extension Rectangle: InspectableShape { }
extension Circle: InspectableShape { }
extension Ellipse: InspectableShape { }
extension Capsule: InspectableShape { }
extension Path: InspectableShape { }
extension RoundedRectangle: InspectableShape { }
extension TransformedShape: InspectableShape { }
extension OffsetShape: InspectableShape { }
extension RotatedShape: InspectableShape { }
extension ScaledShape: InspectableShape { }
extension _SizedShape: InspectableShape { }
extension _StrokedShape: InspectableShape { }
extension _TrimmedShape: InspectableShape { }
extension _ShapeView: InspectableShape {
    public func path(in rect: CGRect) -> Path {
        return shape.path(in: rect)
    }
}
