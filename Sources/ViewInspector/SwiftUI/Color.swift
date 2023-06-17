import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Color: KnownViewType {
        public static var typePrefix: String = "Color"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func color() throws -> InspectableView<ViewType.Color> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func color(_ index: Int) throws -> InspectableView<ViewType.Color> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Color {
    
    func value() throws -> Color {
        return try Inspector.cast(value: content.view, type: Color.self)
    }
    
    func rgba() throws -> (red: Float, green: Float, blue: Float, alpha: Float) {
        var colorProvider = try Inspector.attribute(path: "provider|base", value: content.view)
        var providerName = Inspector.typeName(value: colorProvider)
        if providerName == "ResolvedColorProvider" {
            colorProvider = try Inspector.attribute(label: "color", value: colorProvider)
            providerName = Inspector.typeName(value: colorProvider)
        }
        if ["_Resolved", "Resolved"].contains(providerName) {
            let red = try Inspector.attribute(label: "linearRed", value: colorProvider, type: Float.self)
            let green = try Inspector.attribute(label: "linearGreen", value: colorProvider, type: Float.self)
            let blue = try Inspector.attribute(label: "linearBlue", value: colorProvider, type: Float.self)
            let alpha = try Inspector.attribute(label: "opacity", value: colorProvider, type: Float.self)
            return (red, green, blue, alpha)
        }
        if providerName == "DisplayP3" {
            let red = try Inspector.attribute(label: "red", value: colorProvider, type: CGFloat.self)
            let green = try Inspector.attribute(label: "green", value: colorProvider, type: CGFloat.self)
            let blue = try Inspector.attribute(label: "blue", value: colorProvider, type: CGFloat.self)
            let alpha = try Inspector.attribute(label: "opacity", value: colorProvider, type: Float.self)
            return (Float(red), Float(green), Float(blue), alpha)
        }
        throw InspectionError.notSupported("RGBA values are not available")
    }
    
    func name() throws -> String {
        let colorProvider = try Inspector.attribute(path: "provider|base", value: content.view)
        let providerName = Inspector.typeName(value: colorProvider)
        if providerName == "NamedColor" {
            return try Inspector.attribute(label: "name", value: colorProvider, type: String.self)
        }
        throw InspectionError.notSupported("Color name is not available")
    }
}
