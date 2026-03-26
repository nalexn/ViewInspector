import SwiftUI

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

    func callOnChange<E: Equatable>(newValue value: E, index: Int = 0) throws {
        let typeName = Inspector.typeName(type: E.self)
        if let callback = try? modifierAttribute(
            modifierName: "_ValueActionModifier<\(typeName)>",
            path: "modifier|action",
            type: ((E) -> Void).self,
            call: "onChange", index: index) {
            callback(value)
            return
        }
        let callback = try modifierAttribute(
            modifierName: "_ValueActionModifier<Optional<\(typeName)>>",
            path: "modifier|action",
            type: ((E?) -> Void).self,
            call: "onChange", index: index)
        callback(value)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    func callOnChange<E: Equatable>(oldValue: E, newValue: E, index: Int = 0) throws {
        let typeName = Inspector.typeName(type: E.self)
        let callback = try modifierAttribute(
            modifierName: "_ValueActionModifier2<\(typeName)>",
            path: "modifier|action",
            type: ((E, E) -> Void).self,
            call: "onChange", index: index)
        callback(oldValue, newValue)
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public extension InspectableView {

    func callRefreshable() async throws {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            let callback = try modifierAttribute(
                modifierName: "RefreshableModifier", path: "modifier|action",
                type: (@Sendable () async -> Void).self, call: "refreshable")
            await callback()
        } else {
            guard let modifier = content.medium.environmentModifiers.last(where: { modifier in
                (try? modifier.keyPath() as? KeyPath<EnvironmentValues, RefreshAction?>) == \.refresh
            }) else {
                throw InspectionError.modifierNotFound(
                    parent: Inspector.typeName(value: content.view), modifier: "refreshable", index: 0)
            }
            try await Inspector.cast(value: try modifier.value(), type: RefreshAction?.self)?.callAsFunction()
        }
    }

    func callOnSubmit(of triggers: SubmitTriggers = .text) throws {
        let callback = try modifierAttribute(
            modifierLookup: { modifier -> Bool in
                guard modifier.modifierType.contains("OnSubmitModifier"),
                      let modifierTriggers = try? Inspector
                    .attribute(path: "modifier|allowed", value: modifier, type: SubmitTriggers.self)
                else { return false }
                return modifierTriggers.contains(triggers)
            },
            path: "modifier|action",
            type: (() -> Void).self,
            call: "onSubmit")
        callback()
    }
    
    func callTask() async throws {
        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *) {
            let callback = try modifierAttribute(
                modifierName: "_TaskModifier2", path: "modifier|action",
                type: (@isolated(any) () async -> Void).self, call: "task")
            await callback()
        } else {
            let callback = try modifierAttribute(
                modifierName: "_TaskModifier", path: "modifier|action",
                type: (@Sendable () async -> Void).self, call: "task")
            await callback()
        }
    }

    func callTask(id: some Equatable, index: Int = 0) async throws {
        let typeName = Inspector.typeName(type: type(of: id))
        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *) {
            let callback = try modifierAttribute(
                modifierName: "_TaskValueModifier2<\(typeName)>",
                path: "modifier|action",
                type: (@isolated(any) () async -> Void).self,
                call: "task",
                index: index)
            await callback()
        } else {
            let callback = try modifierAttribute(
                modifierName: "_TaskValueModifier<\(typeName)>",
                path: "modifier|action",
                type: (@Sendable () async -> Void).self,
                call: "task",
                index: index)
            await callback()
        }
    }
}
