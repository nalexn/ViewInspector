import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Canvas: KnownViewType {
        public static var typePrefix: String = "Canvas"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func canvas() throws -> InspectableView<ViewType.Canvas> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func canvas(_ index: Int) throws -> InspectableView<ViewType.Canvas> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Canvas: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return .empty }
        return .init(count: 1) { _ in
            let view = try Inspector.attribute(label: "symbols", value: parent.content.view)
            let medium = parent.content.medium.resettingViewModifiers()
            let content = try Inspector.unwrap(content: Content(view, medium: medium))
            return try InspectableView<ViewType.ClassifiedView>(
                content, parent: parent, call: "symbolsView()")
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View == ViewType.Canvas {
    
    func symbolsView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try ViewType.Canvas.supplementaryChildren(self)
            .element(at: 0).asInspectableView()
    }
    
    func colorMode() throws -> ColorRenderingMode {
        if let value = try? Inspector.attribute(
            path: "rasterizationOptions|colorMode",
            value: content.view, type: ColorRenderingMode.self) {
            return value
        }
        return try Inspector.attribute(
            path: "rasterizationOptions|_colorMode|wrappedValue",
            value: content.view, type: ColorRenderingMode.self)
    }
    
    func opaque() throws -> Bool {
        return try optionFlags().contains(.opaque)
    }
    
    func rendersAsynchronously() throws -> Bool {
        return try optionFlags().contains(.rendersAsynchronously)
    }
    
    private func optionFlags() throws -> ViewType.Canvas.RasterizationOptions32 {
        if let flags = try? Inspector.attribute(
            path: "rasterizationOptions|flags|rawValue",
            value: content.view, type: UInt32.self) {
            return ViewType.Canvas.RasterizationOptions32(rawValue: flags)
        }
        let flags = try Inspector.attribute(
            path: "rasterizationOptions|_flags|wrappedValue|rawValue",
            value: content.view, type: UInt8.self)
        let legacyOptions = ViewType.Canvas.RasterizationOptions8(rawValue: flags)
        var options: ViewType.Canvas.RasterizationOptions32 = []
        if legacyOptions.contains(.opaque) {
            options.insert(.opaque)
        }
        if legacyOptions.contains(.rendersAsynchronously) {
            options.insert(.rendersAsynchronously)
        }
        return options
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension ViewType.Canvas {
    struct RasterizationOptions8: OptionSet {
        let rawValue: UInt8
        static let opaque = RasterizationOptions8(rawValue: 1 << 1)
        static let rendersAsynchronously = RasterizationOptions8(rawValue: 1 << 2)
    }
    struct RasterizationOptions32: OptionSet {
        let rawValue: UInt32
        static let opaque = RasterizationOptions32(rawValue: 1 << 1)
        static let rendersAsynchronously = RasterizationOptions32(rawValue: 1 << 2)
    }
}
