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
        try guardShapeIsInspectable(content)
        return try .init(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func shape(_ index: Int) throws -> InspectableView<ViewType.Shape> {
        let content = try child(at: index)
        try guardShapeIsInspectable(content)
        return try .init(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Shape {
    
    func path(in rect: CGRect) throws -> Path {
        let shape = try guardShapeIsInspectable(content)
        return shape.path(in: rect)
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
    @discardableResult
    func guardShapeIsInspectable(_ content: Content) throws -> InspectableShape {
        guard let shape = content.view as? InspectableShape else {
            if Inspector.typeName(value: content.view) == "_Inset" {
                throw InspectionError.notSupported(
                    "Please move .inset(by:) modifier to be not the last. Alternatively, add void .offset() after it")
            }
            throw InspectionError.typeMismatch(content.view, InspectableShape.self)
        }
        return shape
    }
    
    func shapeAttribute<T>(_ view: Any, _ shapeType: String, _ label: String, _ attributeType: T.Type
    ) throws -> T {
        let name = Inspector.typeName(value: view, prefixOnly: true)
        if name.hasPrefix(shapeType) {
            return try Inspector.attribute(label: label, value: view, type: attributeType)
        }
        guard let containedShape = try? Inspector.attribute(label: "shape", value: view) else {
            let originalType = Inspector.typeName(value: content.view)
            throw InspectionError.attributeNotFound(label: label, type: originalType)
        }
        return try shapeAttribute(containedShape, shapeType, label, attributeType)
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
