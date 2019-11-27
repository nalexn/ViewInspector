import SwiftUI

public extension ViewType {
    struct OptionalContent {}
}

extension ViewType.OptionalContent: SingleViewContent {

    public static func content(view: Any, envObject: Any) throws -> Any {
        let wrapped = try Inspector.attribute(label: "some", value: view)
        return try Inspector.unwrap(view: wrapped)
    }

}
