// MARK: - ViewEvents

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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

    func callOnChange<E: Equatable>(newValue value: E, index: UInt = 0) throws {
        let modifierName = "_ValueActionModifier<\(type(of: value))>"
        let path = "modifier|action"
        let call = "onChange"

        let callback = try modifierAttribute(
            modifierName: modifierName,
            path: path,
            type: ((E) -> Void).self,
            call: call,
            index: Int(index))

        callback(value)
    }
}
