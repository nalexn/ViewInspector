import SwiftUI

// MARK: - ViewPositioning

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView {

    func ignoresSafeArea() throws -> (regions: SafeAreaRegions, edges: Edge.Set) {
        let regions = try modifierAttribute(
            modifierName: "_SafeAreaRegionsIgnoringLayout", path: "modifier|regions",
            type: SafeAreaRegions.self, call: "ignoresSafeArea(_:edges:)")
        let edges = try modifierAttribute(
            modifierName: "_SafeAreaRegionsIgnoringLayout", path: "modifier|edges",
            type: Edge.Set.self, call: "ignoresSafeArea(_:edges:)")
        return (regions, edges)
    }
}

// MARK: - ViewLayering

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func zIndex() throws -> Double {
        return try modifierAttribute(
            modifierName: "ZIndexTraitKey", path: "modifier|value",
            type: Double.self, call: "zIndex")
    }
}
