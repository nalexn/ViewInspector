import SwiftUI
#if canImport(AVKit)
import AVKit
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct VideoPlayer: KnownViewType {
        public static let typePrefix: String = "VideoPlayer"
        public static var namespacedPrefixes: [String] {
            return ["_AVKit_SwiftUI." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "videoPlayer(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func videoPlayer() throws -> InspectableView<ViewType.VideoPlayer> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func videoPlayer(_ index: Int) throws -> InspectableView<ViewType.VideoPlayer> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.VideoPlayer: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { return .empty }
        return .init(count: 1) { _ in
            return try videoOverlay(parent: parent)
        }
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    fileprivate static func videoOverlay(parent: UnwrappedView
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        let provider = try Inspector.cast(value: parent.content.view, type: SingleViewProvider.self)
        let view = try provider.view()
        let medium = parent.content.medium.resettingViewModifiers()
        let content = try Inspector.unwrap(content: Content(view, medium: medium))
        return try InspectableView<ViewType.ClassifiedView>(
            content, parent: parent, call: "videoOverlay()")
    }
}

// MARK: - Custom Attributes

#if canImport(AVKit) && !os(watchOS)

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.VideoPlayer {
    
    func player() throws -> AVPlayer? {
        return try Inspector.attribute(
            path: "configuration|avPlayer", value: content.view, type: AVPlayer?.self)
    }
    
    func videoOverlay() throws -> InspectableView<ViewType.ClassifiedView> {
        return try ViewType.VideoPlayer.videoOverlay(parent: self)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension VideoPlayer: SingleViewProvider {
    func view() throws -> Any {
        return try Inspector.attribute(
            path: "configuration|videoOverlay", value: self)
    }
}

#endif
