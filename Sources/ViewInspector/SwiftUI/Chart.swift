import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    /// `Chart` is an opaque view: its `body` is built from `GeometryReader` and other
    /// internals that require a real layout context, so ViewInspector does not descend
    /// into it. The chart's content is `ChartContent`, not `View`, and is not inspectable.
    struct Chart: KnownViewType {
        public static let typePrefix: String = "Chart"
        public static var namespacedPrefixes: [String] {
            return ["Charts." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "chart(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: SingleViewContent {

    func chart() throws -> InspectableView<ViewType.Chart> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: MultipleViewContent {

    func chart(_ index: Int) throws -> InspectableView<ViewType.Chart> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}
