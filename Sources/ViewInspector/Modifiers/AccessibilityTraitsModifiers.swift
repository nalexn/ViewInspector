import SwiftUI

// MARK: - Accessibility traits

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    /**
     The accessibility traits applied to the view with `accessibilityAddTraits`
     and `accessibilityRemoveTraits`. Traits that are unknown to ViewInspector
     are omitted from the resulting set.
     */
    func accessibilityTraits() throws -> AccessibilityTraits {
        let call = "accessibilityAddTraits"
        let traitSets = accessibilityTraitSets()
        guard !traitSets.isEmpty else {
            throw InspectionError
                .modifierNotFound(parent: Inspector.typeName(value: content.view),
                                  modifier: call, index: 0)
        }
        let rawValue = traitSets.reduce(UInt64(0)) { result, traitSet in
            (result & ~traitSet.mask) | (traitSet.value & traitSet.mask)
        }
        return AccessibilityTraits(rawTraitsValue: rawValue)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct AccessibilityTraitSetValue {
    
    /// The bits of the traits that are turned on
    let value: UInt64
    /// The bits of the traits the modifier has an opinion about
    let mask: UInt64
    
    /**
     The traits are stored differently depending on the OS version: as a pair of
     `value` and `mask` option sets, or as a standalone option set. The layout of
     the enclosing `AccessibilityAttachmentModifier` changed a few times as well,
     so instead of hardcoding the paths we look the values up by their type.
     */
    init?(anyValue: Any) {
        let typeName = Inspector.typeName(value: anyValue)
        if typeName.contains("NullableOptionSet"),
           let value = try? Inspector.attribute(
            path: "value|rawValue", value: anyValue, type: UInt64.self),
           let mask = try? Inspector.attribute(
            path: "mask|rawValue", value: anyValue, type: UInt64.self) {
            self.value = value
            self.mask = mask
        } else if typeName.contains("AccessibilityTrait"),
                  let rawValue = accessibilityTraitsRawValue(of: anyValue) {
            self.value = rawValue
            self.mask = rawValue
        } else {
            return nil
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private func accessibilityTraitsRawValue(of value: Any) -> UInt64? {
    if let rawValue = try? Inspector.attribute(
        path: "traitSet|rawValue", value: value, type: UInt64.self) {
        return rawValue
    }
    return try? Inspector.attribute(label: "rawValue", value: value, type: UInt64.self)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension AccessibilityTraits {
    
    static var knownTraits: [AccessibilityTraits] {
        var traits: [AccessibilityTraits] = [
            .isButton, .isHeader, .isSelected, .isLink, .isSearchField, .isImage,
            .playsSound, .isKeyboardKey, .isStaticText, .isSummaryElement,
            .updatesFrequently, .startsMediaSession, .allowsDirectInteraction,
            .causesPageTurn, .isModal]
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            traits.append(contentsOf: [.isToggle, .isTabBar])
        }
        return traits
    }
    
    init(rawTraitsValue rawValue: UInt64) {
        self = AccessibilityTraits.knownTraits.reduce(into: AccessibilityTraits()) { result, trait in
            guard let traitValue = accessibilityTraitsRawValue(of: trait),
                  traitValue != 0, rawValue & traitValue == traitValue
            else { return }
            result.formUnion(trait)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension InspectableView {
    
    /// The traits from every `AccessibilityAttachmentModifier`, in the order they were applied
    func accessibilityTraitSets() -> [AccessibilityTraitSetValue] {
        return modifiersMatching { $0.modifierType.contains("AccessibilityAttachmentModifier") }
            .reversed()
            .flatMap { InspectableView.accessibilityTraitSets(in: $0, depth: 0) }
    }
    
    private static func accessibilityTraitSets(in value: Any, depth: Int) -> [AccessibilityTraitSetValue] {
        if let traitSet = AccessibilityTraitSetValue(anyValue: value) {
            return [traitSet]
        }
        guard depth < 8 else { return [] }
        return Mirror(reflecting: value).children.flatMap {
            accessibilityTraitSets(in: $0.value, depth: depth + 1)
        }
    }
}
