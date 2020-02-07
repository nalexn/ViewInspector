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
        guard let shape = (content.view as? InspectableShape) else {
            throw InspectionError.typeMismatch(content.view, InspectableShape.self)
        }
        return shape.path(in: rect)
    }
}

private extension InspectableView {
    func guardShapeIsInspectable(_ content: Content) throws {
        guard content.view is InspectableShape else {
            if Inspector.typeName(value: content.view) == "_Inset" {
                throw InspectionError.notSupported(
                    "Please move .inset(by:) modifier to be not the last. Alternatively, add void .offset() after it")
            }
            throw InspectionError.typeMismatch(content.view, InspectableShape.self)
        }
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
        self.shape.path(in: rect)
    }
}
