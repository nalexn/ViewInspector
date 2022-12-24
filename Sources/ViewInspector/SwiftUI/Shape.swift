import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Shape: KnownViewType {
        public static var typePrefix: String = ""
        public static func inspectionCall(typeName: String) -> String {
            return "shape(\(ViewType.indexPlaceholder))"
        }
        
        fileprivate static func inspectionCall(index: Int) -> String {
            return ViewType.inspectionCall(base: inspectionCall(typeName: ""), index: index)
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func shape() throws -> InspectableView<ViewType.Shape> {
        let content = try child()
        let call = ViewType.Shape.inspectionCall(index: 0)
        if !content.isShape,
           let child = try? implicitCustomViewChild(index: 0, call: call)?.content,
           child.isShape {
            return try .init(child, parent: self)
        }
        try content.throwIfNotShape()
        return try .init(content, parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func shape(_ index: Int) throws -> InspectableView<ViewType.Shape> {
        let content = try child(at: index)
        let call = ViewType.Shape.inspectionCall(index: index)
        if !content.isShape,
           let child = try? implicitCustomViewChild(index: index, call: call)?.content,
           child.isShape {
            return try .init(child, parent: self)
        }
        try content.throwIfNotShape()
        return try .init(content, parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Shape {
    
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension InspectableView {
    
    func shapeAttribute<T>(_ view: Any, _ shapeType: String, _ label: String, _ attributeType: T.Type
    ) throws -> T {
        let shape = try lookupShape(view, typeName: shapeType, label: label)
        return try Inspector.attribute(label: label, value: shape, type: attributeType)
    }
    
    func lookupShape(_ view: Any, typeName: String, label: String) throws -> Any {
        let name = Inspector.typeName(value: view, generics: .remove)
        if name.hasPrefix(typeName) {
            return view
        }
        guard let containedShape = try? Inspector.attribute(label: "shape", value: view) else {
            let typeName = Inspector.typeName(value: view)
            throw InspectionError.attributeNotFound(label: label, type: typeName)
        }
        return try lookupShape(containedShape, typeName: typeName, label: label)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    var isShape: Bool {
        do {
            try throwIfNotShape()
            return true
        } catch {
            return false
        }
    }
    
    fileprivate func throwIfNotShape() throws {
        guard view is InspectableShape || Inspector.typeName(value: view) == "_Inset" else {
            throw InspectionError.typeMismatch(view, InspectableShape.self)
        }
    }
}

// MARK: - InspectableShape

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol InspectableShape {
    func path(in rect: CGRect) -> Path
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Rectangle: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Circle: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Ellipse: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Capsule: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Path: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension RoundedRectangle: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension TransformedShape: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension OffsetShape: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension RotatedShape: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ScaledShape: InspectableShape { }

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ContainerRelativeShape: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension _SizedShape: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension _StrokedShape: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension _TrimmedShape: InspectableShape { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension _ShapeView: InspectableShape {
    public func path(in rect: CGRect) -> Path {
        return shape.path(in: rect)
    }
}
