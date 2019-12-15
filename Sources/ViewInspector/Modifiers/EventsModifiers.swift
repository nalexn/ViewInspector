// MARK: - ViewEvents

public extension InspectableView {
    
    func callOnAppear() throws {
        let callback = try modifierAttribute(
            modifierName: "_AppearanceActionModifier", path: "modifier|appear",
            type: (() -> Void).self, call: "onAppear")
        callback()
    }
    
    func callOnDisappear() throws {
        let callback = try modifierAttribute(
            modifierName: "_AppearanceActionModifier", path: "modifier|disappear",
            type: (() -> Void).self, call: "onDisappear")
        callback()
    }
}
