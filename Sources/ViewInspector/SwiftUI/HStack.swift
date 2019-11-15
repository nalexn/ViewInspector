import SwiftUI

public extension ViewType {
    struct HStack: ViewTypeGuard, MultipleViewContent {
        public static let typePrefix: String? = "HStack"
    }
}

public extension ViewType.HStack {
    static func content(view: Any) throws -> [Any] {
        let content = try Inspector.attribute(path: "_tree|content", value: view)
        if Inspector.isToupleView(content) {
            let toupleViews = try Inspector.attribute(label: "value", value: content)
            let childrenCount = Mirror(reflecting: toupleViews).children.count
            return try stride(from: 0, to: childrenCount, by: 1).map { index in
                return try Inspector.attribute(label: ".\(index)", value: toupleViews)
            }
        } else {
            return [content]
        }
    }
}

public extension HStack {
    func inspect() throws -> InspectableView<ViewType.HStack> {
        return try InspectableView<ViewType.HStack>(self)
    }
}
