import SwiftUI

internal extension ViewType {
    struct SubscriptionView {}
}

extension ViewType.SubscriptionView: SingleViewContent {

    static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "content", value: view)
        return try Inspector.unwrap(view: view)
    }
}
