import SwiftUI

internal extension ViewType {
    struct EnvironmentReaderView { }
}

// MARK: - Content Extraction

extension ViewType.EnvironmentReaderView: SingleViewContent {
    
    static func content(view: Any, envObject: Any) throws -> Any {
        /* Need to find a way to get through EnvironmentReaderView */
        throw InspectionError.notSupported("""
            One of the enclosed views is using
            Environment injection, which blocks inspection.
            We're seeking for a workaround.
        """)
    }
}
