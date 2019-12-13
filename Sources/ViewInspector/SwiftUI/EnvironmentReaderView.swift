import SwiftUI

internal extension ViewType {
    struct EnvironmentReaderView { }
}

// MARK: - Content Extraction

extension ViewType.EnvironmentReaderView: SingleViewContent {
    
    static func content(view: Any, envObject: Any) throws -> Any {
        /* Need to find a way to get through EnvironmentReaderView */
        throw InspectionError.notSupported("""
            "navigationBarItems" modifier is currently not supported.
            Consider moving the modifier for direct inspection of the base view.
        """)
    }
}
