import SwiftUI

#if !os(watchOS)

public extension ViewType {
    
    struct ModifiedContent: KnownViewType {
        public static var typePrefix: String = "ModifiedContent"
    }
}

public extension ModifiedContent {
    
    func inspect() throws -> InspectableView<ViewType.ModifiedContent> {
        return try InspectableView<ViewType.ModifiedContent>(self)
    }
}

// MARK: - SingleViewContent

extension ViewType.ModifiedContent: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(path: "content", value: view)
        return try Inspector.unwrap(view: view)
    }
}

#endif
