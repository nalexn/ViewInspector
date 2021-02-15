import SwiftUI

// MARK: - Custom Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func customModifier<T>(keyPath: WritableKeyPath<EnvironmentValues, T>) throws -> T {
        let environmentValues = EnvironmentValues()
        let defaultValue = environmentValues[keyPath: keyPath]
        let reference = EmptyView().environment(keyPath, defaultValue)
        let keyPath = try Inspector.environmentKeyPath(T.self, reference)
        return try environmentModifier(keyPath: keyPath, call: "")
    }
}
