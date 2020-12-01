import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct DelayedPreferenceView { }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.DelayedPreferenceView: SingleViewContent {
    
    static func child(_ content: Content) throws -> Content {
        /* Need to find a way to get through DelayedPreferenceView */
        // swiftlint:disable line_length
        throw InspectionError.notSupported(
            "'PreferenceValue' modifiers are currently not supported. Consider extracting the enclosed view for direct inspection.")
        // swiftlint:enable line_length
    }
}
