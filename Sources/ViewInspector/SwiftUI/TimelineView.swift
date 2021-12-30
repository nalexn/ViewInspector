import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct TimelineView: KnownViewType {
        public static var typePrefix: String = "TimelineView"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func timelineView() throws -> InspectableView<ViewType.TimelineView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func timelineView(_ index: Int) throws -> InspectableView<ViewType.TimelineView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TimelineView: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return .empty }
        return .init(count: 1) { _ in
            return try view(for: .init(), parent: parent)
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    fileprivate static func view(for context: ViewType.TimelineView.Context, parent: UnwrappedView
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        let provider = try Inspector.cast(value: parent.content.view, type: ElementViewProvider.self)
        let view = try provider.view(context)
        let medium = parent.content.medium.resettingViewModifiers()
        let content = try Inspector.unwrap(content: Content(view, medium: medium))
        return try InspectableView<ViewType.ClassifiedView>(
            content, parent: parent, call: "contentView()")
    }
}

// MARK: - Custom Attributes

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View == ViewType.TimelineView {
    
    func contentView(_ context: ViewType.TimelineView.Context = .init()
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        return try ViewType.TimelineView.view(for: context, parent: self)
    }
}

// MARK: -

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension ViewType.TimelineView {
    struct Context {
        public enum Cadence {
            case live, seconds, minutes
        }
        let date: Date
        let cadence: Cadence
        public init(date: Date = Date(), cadence: Cadence = .live) {
            self.date = date
            self.cadence = cadence
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension TimelineView: ElementViewProvider {
    func view(_ element: Any) throws -> Any {
        typealias Builder = (Context) -> Content
        let builder = try Inspector.attribute(
            label: "content", value: self, type: Builder.self)
        let param = try Inspector.cast(
            value: element, type: ViewType.TimelineView.Context.self)
        let context = withUnsafeBytes(of: param) { bytes in
            return bytes.baseAddress!
                .assumingMemoryBound(to: Context.self).pointee
        }
        return builder(context)
    }
}
