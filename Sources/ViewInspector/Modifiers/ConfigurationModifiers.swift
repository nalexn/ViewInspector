import SwiftUI

// MARK: - ViewControlAttributesTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func labelsHidden() -> Bool {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return (try? modifierAttribute(
                modifierName: "LabelsHiddenModifier", transitive: true,
                path: "modifier", type: Any.self, call: "labelsHidden")) != nil
        }
        return (try? modifierAttribute(modifierLookup: { modifier -> Bool in
            modifier.modifierType.hasPrefix("_LabeledViewStyleModifier<HiddenLabel")
        }, transitive: true, path: "modifier|style",
        type: Any.self, call: "labelsHidden")) != nil
    }
    
    #if os(macOS)
    func horizontalRadioGroupLayout() throws -> Bool {
        _ = try modifier({ modifier -> Bool in
            return [
                "RadioGroupStyleModifier<LayoutRadioGroupStyle<_HStackLayout>>",
                "RadioGroupLayoutModifier<_HStackLayout>",
            ].contains(where: { modifier.modifierType == $0 })
        }, call: "horizontalRadioGroupLayout")
        return true
    }
    
    func controlSize() throws -> ControlSize {
        let reference = EmptyView().controlSize(.regular)
        let keyPath = try Inspector.environmentKeyPath(ControlSize.self, reference)
        return try environment(keyPath, call: "controlSize")
    }
    #endif
}
