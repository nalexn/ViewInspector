import SwiftUI

public extension ViewType {
    
    struct LinearGradient: KnownViewType {
        public static var typePrefix: String = "LinearGradient"
    }
}

public extension LinearGradient {
    
    func inspect() throws -> InspectableView<ViewType.LinearGradient> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func linearGradient() throws -> InspectableView<ViewType.LinearGradient> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func linearGradient(_ index: Int) throws -> InspectableView<ViewType.LinearGradient> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

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
