import SwiftUI

// MARK: - ViewPositioning

public extension InspectableView {
    
    func position() throws -> CGPoint {
        return try modifierAttribute(
            modifierName: "_PositionLayout", path: "modifier|position",
            type: CGPoint.self, call: "position")
    }
    
    func offset() throws -> CGSize {
        return try modifierAttribute(
            modifierName: "_OffsetEffect", path: "modifier|offset",
            type: CGSize.self, call: "offset")
    }
    
    func edgesIgnoringSafeArea() throws -> Edge.Set {
        return try modifierAttribute(
            modifierName: "_SafeAreaIgnoringLayout", path: "modifier|edges",
            type: Edge.Set.self, call: "edgesIgnoringSafeArea")
    }
    
    func coordinateSpaceName() throws -> String {
        return try modifierAttribute(
            modifierName: "_CoordinateSpaceModifier", path: "modifier|name",
            type: String.self, call: "coordinateSpace(name:)")
    }
}
