// MARK: - ViewEvents

public extension InspectableView {
    
    func callOnAppear() throws {
        let onAppear = try attribute("_AppearanceActionModifier", path: "modifier|appear",
                                     type: (() -> Void).self, call: "onAppear")
        onAppear()
    }
    
    func callOnDisappear() throws {
        let onDisappear = try attribute("_AppearanceActionModifier", path: "modifier|disappear",
                                        type: (() -> Void).self, call: "onDisappear")
        onDisappear()
    }
}
