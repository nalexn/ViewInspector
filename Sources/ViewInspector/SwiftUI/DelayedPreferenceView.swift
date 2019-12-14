import SwiftUI

internal extension ViewType {
    struct DelayedPreferenceView { }
}

// MARK: - Content Extraction

extension ViewType.DelayedPreferenceView: SingleViewContent {
    
    static func child(_ content: Content, envObject: Any) throws -> Content {
        /* Need to find a way to get through DelayedPreferenceView */
        throw InspectionError.notSupported("""
            "PreferenceValue" modifiers are currently not supported.
            Consider extracting the enclosed view for direct inspection.
        """)
    }
}
